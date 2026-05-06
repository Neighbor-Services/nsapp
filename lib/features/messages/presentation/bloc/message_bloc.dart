import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nsapp/core/constants/urls.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/chat.dart';
import 'package:nsapp/core/models/message.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/features/messages/domain/usecase/delete_message_use_case.dart';
import 'package:nsapp/features/messages/domain/usecase/get_messages_use_case.dart';
import 'package:nsapp/features/messages/domain/usecase/get_my_messages_use_case.dart';
import 'package:nsapp/features/messages/domain/usecase/reload_message_receiver_use_case.dart';
import 'package:nsapp/features/messages/domain/usecase/set_seen_use_case.dart';
import 'package:nsapp/features/messages/domain/usecase/update_message_use_case.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final GetMessagesUseCase getMessagesUseCase;
  final GetMyMessagesUseCase getMyMessagesUseCase;
  final ReloadMessageReceiverUseCase reloadMessageReceiverUseCase;
  final DeleteMessageUseCase deleteMessageUseCase;
  final UpdateMessageUseCase updateMessageUseCase;
  final SetSeenUseCase setSeenUseCase;

  // Local instance-based variables
  List<ChatMessage> _currentMessages = [];
  Profile _receiverProfile = Profile();
  List<Chat> _myChats = [];
  int _unreadCount = 0;
  bool _isTyping = false;
  bool _isOnline = false;
  String? _targetUserId;
  String? _currentSenderId;
  XFile? _selectedImage;
  bool _setAppointment = false;
  bool _isWithImage = false;

  WebSocketChannel? _messageChannel;
  StreamSubscription? _wsSubscription;
  Timer? _reconnectTimer;
  int _retryCount = 0;

  WebSocketChannel? _presenceChannel;
  StreamSubscription? _presenceSubscription;
  Timer? _presenceReconnectTimer;
  int _presenceRetryCount = 0;

  MessageBloc(
    this.getMessagesUseCase,
    this.getMyMessagesUseCase,
    this.reloadMessageReceiverUseCase,
    this.deleteMessageUseCase,
    this.updateMessageUseCase,
    this.setSeenUseCase,
  ) : super(MessageInitial()) {
    
    on<ConnectWebSocketEvent>((event, emit) async {
      if (_targetUserId != event.receiver) {
        _currentMessages = [];
        _isTyping = false;
        _isOnline = false;
      }
      await _closeWebSocket();
      _currentSenderId = event.sender;
      _targetUserId = event.receiver;
      _retryCount = 0;
      _connectChat();
      
      emit(SuccessGetMessageState(messages: _currentMessages));
    });

    on<SendTypingEvent>((event, emit) async {
      _messageChannel?.sink.add(
        json.encode({'type': 'typing', 'is_typing': event.isTyping}),
      );
    });

    on<GetChatStatusEvent>((event, emit) async {
      emit(ChatStatusState(
        isTyping: _isTyping,
        isOnline: _isOnline,
        targetUserId: _targetUserId,
      ));
      if (_currentMessages.isNotEmpty) {
        emit(SuccessGetMessageState(messages: _currentMessages));
      }
    });

    on<ChatEvent>((event, emit) async {
      final jsonMsg = json.encode(event.message.toJson());
      _messageChannel?.sink.add(jsonMsg);
    });

    on<DeleteMessageEvent>((event, emit) async {
      if (_messageChannel != null) {
        _messageChannel?.sink.add(json.encode({
          'type': 'delete_message',
          'message_id': event.message.id
        }));
      }
      // Optimistic delete from local list if needed, 
      // but we'll wait for the WS confirmation for full consistency
    });

    on<UpdateMessageEvent>((event, emit) async {
       if (_messageChannel != null) {
        _messageChannel?.sink.add(json.encode({
          'type': 'update_message',
          'message_id': event.message.id,
          'message': event.message.message
        }));
      }
    });

    on<SetMessageReceiverEvent>((event, emit) async {
      _receiverProfile = event.profile;
      emit(MessageReceiverState(profile: _receiverProfile));
    });

    on<ChooseMessageImageFromGalleyEvent>((event, emit) async {
      _selectedImage = await Helpers.selectImageFromGallery();
      emit(MessageImageState(image: _selectedImage));
    });

    on<ChooseMessageImageFromCameraEvent>((event, emit) async {
      _selectedImage = await Helpers.selectImageFromCamera();
      emit(MessageImageState(image: _selectedImage));
    });

    on<ImageEvent>((event, emit) async {
      _isWithImage = event.isWithImage;
      emit(WithImageState(isWithImage: _isWithImage));
    });

    on<GetMessagesEvent>((event, emit) async {
      if (event.before == null && event.receiver != _targetUserId) {
        _currentMessages = [];
        emit(LoadingMessageState());
      }
      final results = await getMessagesUseCase(GetMessagesParams(
        receiver: event.receiver,
        before: event.before,
      ));
      results.fold(
        (l) => emit(FailureGetMessageState(message: l.message ?? "")),
        (r) {
          _currentMessages = r;
          emit(SuccessGetMessageState(messages: _currentMessages));
        },
      );
    }, transformer: sequential());

    on<CalenderAppointmentEvent>((event, emit) async {
      _setAppointment = event.setAppointment;
      emit(SetAppointmentState(setAppointment: _setAppointment));
    });

    on<ReloadMessagesEvent>((event, emit) async {
      final results = await reloadMessageReceiverUseCase(event.user);
      results.fold(
        (l) => emit(FailureGetMyMessagesState(message: l.message ?? "")),
        (r) {
          _receiverProfile = r;
          emit(MessageReceiverState(profile: _receiverProfile));
        },
      );
      emit(ReloadMessageState());
    });

    on<GetMyMessagesEvent>((event, emit) async {
      final results = await getMyMessagesUseCase(event);
      results.fold(
        (l) => emit(FailureGetMyMessagesState(message: l.message ?? "")),
        (r) {
          _myChats = r ?? [];
          _unreadCount = 0;
          for (var chat in _myChats) {
            _unreadCount += (chat.chat?.unreadCount ?? 0);
          }
          emit(SuccessGetMyMessagesState(
            myMessages: _myChats,
            unreadMessageCount: _unreadCount,
          ));
        },
      );
    }, transformer: sequential());

    on<SetSeenMessageEvent>((event, emit) async {
      final results = await setSeenUseCase(event.reciever);
      results.fold(
        (l) => emit(FailureSetSeenMessageState(message: l.message ?? "")),
        (r) {
          add(GetMyMessagesEvent());
          emit(SuccessSetSeenMessageState());
        },
      );
    });

    on<ConnectGlobalPresenceEvent>((event, emit) async {
      await _closePresenceWebSocket();
      _presenceRetryCount = 0;
      _connectPresence();
    });

    on<SendMessageStatusEvent>((event, emit) async {
      if (_messageChannel != null) {
        _messageChannel?.sink.add(json.encode({
          'type': 'message_status',
          'message_id': event.messageId,
          'status': event.status
        }));
      }
    });
  }

  void _connectChat() async {
    if (_currentSenderId == null || _targetUserId == null) return;
    
    final token = await Helpers.getString("token");
    final url = '$baseMessagesWsUrl/ws/${Helpers.createChatRoom(sender: _currentSenderId!, receiver: _targetUserId!)}/?token=$token';
    
    try {
      _messageChannel = IOWebSocketChannel.connect(Uri.parse(url));
      _wsSubscription = _messageChannel?.stream.listen(
        (dataString) {
          _retryCount = 0;
          final data = json.decode(dataString);
          final type = data['type'];

          if (type == 'message') {
            final chatMessage = ChatMessage.fromJson(data);
            _currentMessages = List.from(_currentMessages)..add(chatMessage);
            
            if (chatMessage.message?.sender == _targetUserId && chatMessage.message?.id != null) {
                add(SendMessageStatusEvent(messageId: chatMessage.message!.id!, status: "seen"));
            }
            
            add(GetChatStatusEvent());
          } else if (type == 'message_status') {
            final msgId = data['message_id'];
            final status = data['status'];
            final idx = _currentMessages.indexWhere((m) => m.message?.id == msgId);
            if (idx != -1) {
              if (status == 'delivered') {
                _currentMessages[idx].message?.isDelivered = true;
              } else if (status == 'seen') {
                _currentMessages[idx].message?.isDelivered = true;
                _currentMessages[idx].message?.read = true;
              }
              add(GetChatStatusEvent());
            }
          } else if (type == 'delete_message') {
            final msgId = data['message_id'];
            _currentMessages.removeWhere((m) => m.message?.id == msgId);
            add(GetChatStatusEvent());
          } else if (type == 'update_message') {
            final updatedData = data['message'];
            final updatedChatMsg = ChatMessage.fromJson(updatedData);
            final index = _currentMessages.indexWhere((m) => m.message?.id == updatedChatMsg.message?.id);
            if (index != -1) {
              _currentMessages[index] = updatedChatMsg;
              add(GetChatStatusEvent());
            }
          } else if (type == 'typing') {
            if (data['user_id'] == _targetUserId) {
              _isTyping = data['is_typing'];
              add(GetChatStatusEvent());
            }
          } else if (type == 'presence') {
            if (data['user_id'] == _targetUserId) {
              _isOnline = data['status'] == 'online';
              add(GetChatStatusEvent());
            }
          }
        },
        onError: (error) {
          debugPrint("Chat WS Error: $error");
          _reconnectChat();
        },
        onDone: () {
          debugPrint("Chat WS Closed");
          _reconnectChat();
        },
      );
    } catch (e) {
      debugPrint("Chat WS Connect Error: $e");
      _reconnectChat();
    }
  }

  void _reconnectChat() {
    _reconnectTimer?.cancel();
    _retryCount++;
    final delay = min(pow(2, _retryCount).toInt(), 30);
    debugPrint("Reconnecting Chat WS in $delay seconds...");
    _reconnectTimer = Timer(Duration(seconds: delay), () {
      _connectChat();
    });
  }

  void _connectPresence() async {
    final token = await Helpers.getString("token");
    if (token.isEmpty) return;
    
    final url = '$baseMessagesWsUrl/ws/presence/?token=$token';
    try {
      _presenceChannel = IOWebSocketChannel.connect(Uri.parse(url));
      _presenceSubscription = _presenceChannel?.stream.listen(
        (data) {
          _presenceRetryCount = 0;
        },
        onError: (error) {
          debugPrint("Presence WS Error: $error");
          _reconnectPresence();
        },
        onDone: () {
          debugPrint("Presence WS Closed");
          _reconnectPresence();
        },
      );
    } catch (e) {
      debugPrint("Presence WS Connect Error: $e");
      _reconnectPresence();
    }
  }

  void _reconnectPresence() {
    _presenceReconnectTimer?.cancel();
    _presenceRetryCount++;
    final delay = min(pow(2, _presenceRetryCount).toInt(), 30);
    debugPrint("Reconnecting Presence WS in $delay seconds...");
    _presenceReconnectTimer = Timer(Duration(seconds: delay), () {
      _connectPresence();
    });
  }

  Future<void> _closeWebSocket() async {
    _reconnectTimer?.cancel();
    await _wsSubscription?.cancel();
    await _messageChannel?.sink.close();
    _messageChannel = null;
    _wsSubscription = null;
  }

  Future<void> _closePresenceWebSocket() async {
    _presenceReconnectTimer?.cancel();
    await _presenceSubscription?.cancel();
    await _presenceChannel?.sink.close();
    _presenceChannel = null;
    _presenceSubscription = null;
  }

  @override
  Future<void> close() async {
    await _closeWebSocket();
    await _closePresenceWebSocket();
    return super.close();
  }
}
