import 'dart:async';
import 'dart:convert';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
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
import 'package:nsapp/core/initialize/init.dart';
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

  // Local instance-based variables to replace static state
  List<ChatMessage> _currentMessages = [];
  Profile _receiverProfile = Profile();
  List<Chat> _myChats = [];
  int _unreadCount = 0;
  bool _isTyping = false;
  bool _isOnline = false;
  String? _targetUserId;
  XFile? _selectedImage;
  bool _setAppointment = false;
  bool _isWithImage = false;

  WebSocketChannel? _messageChannel;
  StreamSubscription? _wsSubscription;

  MessageBloc(
    this.getMessagesUseCase,
    this.getMyMessagesUseCase,
    this.reloadMessageReceiverUseCase,
    this.deleteMessageUseCase,
    this.updateMessageUseCase,
    this.setSeenUseCase,
  ) : super(MessageInitial()) {
    
    on<ConnectWebSocketEvent>((event, emit) async {
      await _closeWebSocket();
      
      final token = await Helpers.getString("token");
      final url = '$baseMessagesWsUrl/ws/${Helpers.createChatRoom(sender: event.sender, receiver: event.receiver)}/?token=$token';
      
      _messageChannel = IOWebSocketChannel.connect(Uri.parse(url));
      _targetUserId = event.receiver;

      _wsSubscription = _messageChannel?.stream.listen(
        (dataString) {
          final data = json.decode(dataString);
          final type = data['type'];

          if (type == 'message') {
            final chatMessage = ChatMessage.fromJson(data);
            _currentMessages = List.from(_currentMessages)..add(chatMessage);
            add(GetChatStatusEvent()); // Refresh state
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
        onError: (error) {},
        onDone: () {},
      );
      
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
      // Also emit current messages if we are in a chat
      if (_currentMessages.isNotEmpty) {
        emit(SuccessGetMessageState(messages: _currentMessages));
      }
    });

    on<ChatEvent>((event, emit) async {
      final jsonMsg = json.encode(event.message.toJson());
      _messageChannel?.sink.add(jsonMsg);
    });

    on<DeleteMessageEvent>((event, emit) async {
      final results = await deleteMessageUseCase(event.message);
      results.fold(
        (l) => emit(FailureDeleteMessageState(message: l.message ??"")),
        (r) => emit(SuccessDeleteMessageState()),
      );
    });

    on<UpdateMessageEvent>((event, emit) async {
      final results = await updateMessageUseCase(event.message);
      results.fold(
        (l) => emit(FailureUpdateMessageState(message: l.message ?? "")),
        (r) => emit(SuccessUpdateMessageState()),
      );
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
      // Local current messages are already loaded via HydratedBloc fromJson
      final results = await getMessagesUseCase(event.receiver);
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
  }

  Future<void> _closeWebSocket() async {
    await _wsSubscription?.cancel();
    await _messageChannel?.sink.close();
    _messageChannel = null;
    _wsSubscription = null;
  }

  @override
  Future<void> close() async {
    await _closeWebSocket();
    return super.close();
  }

  @override
  MessageState? fromJson(Map<String, dynamic> json) {
    try {
      if (json.containsKey('messages')) {
        _currentMessages = (json['messages'] as List)
            .map((e) => ChatMessage.fromJson(e))
            .toList();
      }
      if (json.containsKey('chats')) {
        _myChats = (json['chats'] as List)
            .map((e) => Chat.fromJson(e))
            .toList();
      }
      return SuccessGetMyMessagesState(
        myMessages: _myChats,
        unreadMessageCount: json['unreadCount'] ?? 0,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(MessageState state) {
    return {
      'messages': _currentMessages.map((e) => e.toJson()).toList(),
      'chats': _myChats.map((e) => e.toJson()).toList(),
      'unreadCount': _unreadCount,
    };
  }
}
