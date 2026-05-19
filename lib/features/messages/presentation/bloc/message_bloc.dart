import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nsapp/core/constants/urls.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/chat.dart';
import 'package:nsapp/core/models/message.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/core/models/user.dart';
import 'package:nsapp/features/messages/domain/usecase/delete_message_use_case.dart';
import 'package:nsapp/features/messages/domain/usecase/get_messages_use_case.dart';
import 'package:nsapp/features/messages/domain/usecase/get_my_messages_use_case.dart';
import 'package:nsapp/features/messages/domain/usecase/reload_message_receiver_use_case.dart';
import 'package:nsapp/features/messages/domain/usecase/set_seen_use_case.dart';
import 'package:nsapp/features/messages/domain/usecase/update_message_use_case.dart';
import 'package:nsapp/core/services/hive_service.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends HydratedBloc<MessageEvent, MessageState> {
  final GetMessagesUseCase getMessagesUseCase;
  final GetMyMessagesUseCase getMyMessagesUseCase;
  final ReloadMessageReceiverUseCase reloadMessageReceiverUseCase;
  final DeleteMessageUseCase deleteMessageUseCase;
  final UpdateMessageUseCase updateMessageUseCase;
  final SetSeenUseCase setSeenUseCase;
  final HiveService hiveService;

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
  bool _isConnected = false;

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
    this.hiveService,
  ) : super(MessageInitial()) {
    
    on<ConnectWebSocketEvent>((event, emit) async {
      debugPrint("DEBUG: ConnectWebSocketEvent for receiver: ${event.receiver}");
      if (_targetUserId != event.receiver) {
        _currentMessages = [];
        _isTyping = false;
        _isOnline = false;
      }
      await _closeWebSocket();
      _currentSenderId = event.sender;
      _targetUserId = event.receiver;
      _retryCount = 0;

      // Load from Hive for instant UI
      final roomId = Helpers.createChatRoom(sender: _currentSenderId!, receiver: _targetUserId!);
      _currentMessages = _loadMessagesFromHive(roomId);

      _connectChat();
      
      emit(SuccessGetMessageState(messages: List.from(_currentMessages)));
    });

    on<SendTypingEvent>((event, emit) async {
      if (_messageChannel != null && _isConnected) {
        _messageChannel?.sink.add(
          json.encode({'type': 'typing', 'is_typing': event.isTyping}),
        );
      }
    });

    on<GetChatStatusEvent>((event, emit) async {
      emit(ChatStatusState(
        isTyping: _isTyping,
        isOnline: _isOnline,
        targetUserId: _targetUserId,
        isConnected: _isConnected,
      ));
      // Always emit the current message list so the UI stays in sync,
      // even when the list is empty (e.g. after deleting the last message).
      emit(SuccessGetMessageState(messages: List.from(_currentMessages)));
    });

    on<ChatEvent>((event, emit) async {
      if (_messageChannel == null || !_isConnected) {
        debugPrint("DEBUG: Cannot send message, WebSocket not connected. Attempting reconnection...");
        _connectChat();
      }
      
      // Optimistic update: Add to local list immediately
      final tempId = "temp_${DateTime.now().millisecondsSinceEpoch}";
      final optimisticMsg = ChatMessage(
        message: event.message.copyWith(
          id: tempId,
          isDelivered: false,
          createdAt: DateTime.now(),
        ),
        // Use a minimal profile for the sender (Me)
        sender: Profile(user: User(id: _currentSenderId)),
        receiver: _receiverProfile,
      );

      _currentMessages = List.from(_currentMessages)..add(optimisticMsg);
      // Emit directly to avoid event-queue race conditions
      emit(SuccessGetMessageState(messages: List.from(_currentMessages)));

      // Save optimistic update to Hive
      final roomId = Helpers.createChatRoom(sender: _currentSenderId!, receiver: _targetUserId!);
      _saveMessagesToHive(roomId, _currentMessages);

      try {
        final jsonMsg = json.encode(event.message.toJson());
        debugPrint("DEBUG: Sending message JSON: $jsonMsg");
        _messageChannel?.sink.add(jsonMsg);
      } catch (e) {
        debugPrint("DEBUG: Error sending message via WS: $e");
        // Remove optimistic message on hard error
        _currentMessages.removeWhere((m) => m.message?.id == tempId);
        emit(SuccessGetMessageState(messages: List.from(_currentMessages)));
      }
    });

    on<DeleteMessageEvent>((event, emit) async {
      if (_messageChannel != null && _isConnected) {
        _messageChannel?.sink.add(json.encode({
          'type': 'delete_message',
          'message_id': event.message.id
        }));
      }
    });

    on<UpdateMessageEvent>((event, emit) async {
       if (_messageChannel != null && _isConnected) {
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
          // Sync with API and update Hive
          _currentMessages = r;
          final roomId = Helpers.createChatRoom(sender: _currentSenderId!, receiver: event.receiver);
          _saveMessagesToHive(roomId, _currentMessages);
          emit(SuccessGetMessageState(messages: List.from(_currentMessages)));
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
      if (_messageChannel != null && _isConnected) {
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
    if (token.isEmpty) {
      debugPrint("DEBUG: Token is empty, skipping Chat WS connection");
      return;
    }

    final roomId = Helpers.createChatRoom(sender: _currentSenderId!, receiver: _targetUserId!);
    final url = '$baseMessagesWsUrl/ws/$roomId/?token=$token';
    
    debugPrint("DEBUG: Connecting to Chat WS: $url");
    
    try {
      // Close existing before opening new one
      await _closeWebSocket();
      
      _messageChannel = IOWebSocketChannel.connect(Uri.parse(url));
      _isConnected = true; // Optimistic, will be verified on first message or listen
      
      _wsSubscription = _messageChannel?.stream.listen(
        (dataString) {
          debugPrint("DEBUG: Chat WS Data received: $dataString");
          _retryCount = 0;
          _isConnected = true;
          
          final data = json.decode(dataString);
          final type = data['type'];

          if (type == 'message') {
            final chatMessage = ChatMessage.fromJson(data);
            
            // Deduplication/Replacement logic for optimistic updates
            final tempIndex = _currentMessages.indexWhere((m) => 
              m.message?.id?.startsWith("temp_") == true && 
              m.message?.message == chatMessage.message?.message &&
              m.message?.sender == chatMessage.message?.sender
            );

            if (tempIndex != -1) {
              // Replace the optimistic message with the real one from server
              _currentMessages = List.from(_currentMessages);
              _currentMessages[tempIndex] = chatMessage;
            } else {
              // Only add if it doesn't already exist (rare race condition)
              final exists = _currentMessages.any((m) => m.message?.id == chatMessage.message?.id);
              if (!exists) {
                _currentMessages = List.from(_currentMessages)..add(chatMessage);
              }
            }

            // Save to Hive on every new message
            final roomId = Helpers.createChatRoom(sender: _currentSenderId!, receiver: _targetUserId!);
            _saveMessagesToHive(roomId, _currentMessages);

            if (chatMessage.message?.sender == _targetUserId && chatMessage.message?.id != null) {
                add(SendMessageStatusEvent(messageId: chatMessage.message!.id!, status: "seen"));
            }
            add(GetChatStatusEvent());
          } else if (type == 'message_status') {
            final msgId = data['message_id'];
            final status = data['status'];
            final idx = _currentMessages.indexWhere((m) => m.message?.id == msgId);
            if (idx != -1) {
              _currentMessages = List.from(_currentMessages);
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
            _currentMessages = List.from(_currentMessages);
            _currentMessages.removeWhere((m) => m.message?.id == msgId);
            add(GetChatStatusEvent());
          } else if (type == 'update_message') {
            final updatedData = data['message'];
            final updatedChatMsg = ChatMessage.fromJson(updatedData);
            final index = _currentMessages.indexWhere((m) => m.message?.id == updatedChatMsg.message?.id);
            if (index != -1) {
              _currentMessages = List.from(_currentMessages);
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
          debugPrint("DEBUG: Chat WS Error: $error");
          _isConnected = false;
          add(GetChatStatusEvent());
          _reconnectChat();
        },
        onDone: () {
          debugPrint("DEBUG: Chat WS Closed");
          _isConnected = false;
          add(GetChatStatusEvent());
          _reconnectChat();
        },
      );
    } catch (e) {
      debugPrint("DEBUG: Chat WS Connect Error: $e");
      _isConnected = false;
      add(GetChatStatusEvent());
      _reconnectChat();
    }
  }

  void _reconnectChat() {
    _reconnectTimer?.cancel();
    _retryCount++;
    if (_retryCount > 10) {
      debugPrint("DEBUG: Chat WS max retries reached. Stopping reconnection.");
      return;
    }
    final delay = min(pow(2, _retryCount).toInt(), 30);
    debugPrint("DEBUG: Reconnecting Chat WS in $delay seconds... (attempt $_retryCount/10)");
    _reconnectTimer = Timer(Duration(seconds: delay), () {
      _connectChat();
    });
  }

  void _connectPresence() async {
    final token = await Helpers.getString("token");
    if (token.isEmpty) return;
    
    final url = '$baseMessagesWsUrl/ws/presence/?token=$token';
    debugPrint("DEBUG: Connecting to Presence WS: $url");
    
    try {
      await _closePresenceWebSocket();
      _presenceChannel = IOWebSocketChannel.connect(Uri.parse(url));
      _presenceSubscription = _presenceChannel?.stream.listen(
        (data) {
          _presenceRetryCount = 0;
        },
        onError: (error) {
          debugPrint("DEBUG: Presence WS Error: $error");
          _reconnectPresence();
        },
        onDone: () {
          debugPrint("DEBUG: Presence WS Closed");
          _reconnectPresence();
        },
      );
    } catch (e) {
      debugPrint("DEBUG: Presence WS Connect Error: $e");
      _reconnectPresence();
    }
  }

  void _reconnectPresence() {
    _presenceReconnectTimer?.cancel();
    _presenceRetryCount++;
    if (_presenceRetryCount > 10) {
      debugPrint("DEBUG: Presence WS max retries reached. Stopping reconnection.");
      return;
    }
    final delay = min(pow(2, _presenceRetryCount).toInt(), 30);
    debugPrint("DEBUG: Reconnecting Presence WS in $delay seconds... (attempt $_presenceRetryCount/10)");
    _presenceReconnectTimer = Timer(Duration(seconds: delay), () {
      _connectPresence();
    });
  }

  Future<void> _closeWebSocket() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _wsSubscription?.cancel();
    _wsSubscription = null;
    await _messageChannel?.sink.close();
    _messageChannel = null;
    _isConnected = false;
  }

  Future<void> _closePresenceWebSocket() async {
    _presenceReconnectTimer?.cancel();
    _presenceReconnectTimer = null;
    await _presenceSubscription?.cancel();
    _presenceSubscription = null;
    await _presenceChannel?.sink.close();
    _presenceChannel = null;
  }

  @override
  MessageState? fromJson(Map<String, dynamic> json) {
    try {
      if (json.containsKey('myChats')) {
        _myChats = (json['myChats'] as List)
            .map((e) => Chat.fromJson(e))
            .toList();
      }
      if (json.containsKey('currentMessages')) {
        _currentMessages = (json['currentMessages'] as List)
            .map((e) => ChatMessage.fromJson(e))
            .toList();
      }
      if (json.containsKey('receiverProfile')) {
        _receiverProfile = Profile.fromJson(json['receiverProfile']);
      }
      if (json.containsKey('unreadCount')) {
        _unreadCount = json['unreadCount'];
      }
      if (json.containsKey('targetUserId')) {
        _targetUserId = json['targetUserId'];
      }

      if (_currentMessages.isNotEmpty) {
        return SuccessGetMessageState(messages: List.from(_currentMessages));
      }
      if (_myChats.isNotEmpty) {
        return SuccessGetMyMessagesState(
          myMessages: _myChats,
          unreadMessageCount: _unreadCount,
        );
      }
    } catch (e) {
      debugPrint("DEBUG: MessageBloc fromJson error: $e");
    }
    return null;
  }

  @override
  Map<String, dynamic>? toJson(MessageState state) {
    return {
      'myChats': _myChats.map((e) => e.toJson()).toList(),
      'currentMessages': _currentMessages.map((e) => e.toJson()).toList(),
      'receiverProfile': _receiverProfile.toJson(),
      'unreadCount': _unreadCount,
      'targetUserId': _targetUserId,
    };
  }

  List<ChatMessage> _loadMessagesFromHive(String roomId) {
    try {
      final box = hiveService.getBox(HiveService.messageBox);
      final dynamic data = box.get(roomId);
      if (data != null && data is List) {
        return List<ChatMessage>.from(data);
      }
    } catch (e) {
      debugPrint("DEBUG: Error loading messages from Hive: $e");
    }
    return [];
  }

  void _saveMessagesToHive(String roomId, List<ChatMessage> messages) {
    try {
      final box = hiveService.getBox(HiveService.messageBox);
      // Limit local storage to last 100 messages per room to keep box size optimal
      final listToSave = messages.length > 100 ? messages.sublist(messages.length - 100) : messages;
      box.put(roomId, listToSave);
    } catch (e) {
      debugPrint("DEBUG: Error saving messages to Hive: $e");
    }
  }

  @override
  Future<void> close() async {
    await _closeWebSocket();
    await _closePresenceWebSocket();
    return super.close();
  }
}
