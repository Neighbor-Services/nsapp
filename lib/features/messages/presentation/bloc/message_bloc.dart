import 'dart:convert';

import 'package:bloc_concurrency/bloc_concurrency.dart';
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
import 'package:nsapp/core/di/injection_container.dart';
import 'package:nsapp/core/services/hive_service.dart';
import 'package:web_socket_channel/io.dart';
import '../../../../core/initialize/init.dart';

part 'message_event.dart';

part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final GetMessagesUseCase getMessagesUseCase;
  final GetMyMessagesUseCase getMyMessagesUseCase;
  final ReloadMessageReceiverUseCase reloadMessageReceiverUseCase;
  final DeleteMessageUseCase deleteMessageUseCase;
  final UpdateMessageUseCase updateMessageUseCase;
  final SetSeenUseCase setSeenUseCase;

  MessageBloc(
    this.getMessagesUseCase,
    this.getMyMessagesUseCase,
    this.reloadMessageReceiverUseCase,
    this.deleteMessageUseCase,
    this.updateMessageUseCase,
    this.setSeenUseCase,
  ) : super(MessageInitial()) {
    on<MessageEvent>((event, emit) {});
    on<ConnectWebSocketEvent>((event, emit) async {
      if (channel != null) {
        channel!.sink.close();
      }
      final token = await Helpers.getString("token");
      final url = '$baseMessagesWsUrl/ws/${Helpers.createChatRoom(sender: event.sender, receiver: event.receiver)}/?token=$token';
      print("Connecting to WebSocket: $url");
      channel = IOWebSocketChannel.connect(Uri.parse(url));

      ChatStatusState.targetUserId = event.receiver;

      channel?.stream.listen(
        (dataString) {
          final data = json.decode(dataString);
          final type = data['type'];

          if (type == 'message') {
            // Data is a ChatMessage structure from get_serialized_chat_message
            final chatMessage = ChatMessage.fromJson(data);
            if (SuccessGetMessageState.messages != null) {
              SuccessGetMessageState.messages!.then((currentMessages) {
                List<ChatMessage> updated = List.from(currentMessages);
                updated.add(chatMessage);
                SuccessGetMessageState.messages = Future.value(updated);
                add(GetChatStatusEvent()); // Trigger rebuild
              });
            } else {
              SuccessGetMessageState.messages = Future.value([chatMessage]);
              add(GetChatStatusEvent());
            }
          } else if (type == 'typing') {
            if (data['user_id'] == ChatStatusState.targetUserId) {
              ChatStatusState.isTyping = data['is_typing'];
              add(GetChatStatusEvent()); // Trigger a state update
            }
          } else if (type == 'presence') {
            if (data['user_id'] == ChatStatusState.targetUserId) {
              ChatStatusState.isOnline = data['status'] == 'online';
              add(GetChatStatusEvent()); // Trigger a state update
            }
          }
        },
        onError: (error) {
          print("WS Error: $error");
        },
        onDone: () async {
          print("WS Closed");
          // Reconnect logic typically handled by adding ConnectWebSocketEvent again after a delay
        },
      );
      emit(SuccessGetMessageState());
    });
    on<SendTypingEvent>((event, emit) async {
      channel?.sink.add(
        json.encode({'type': 'typing', 'is_typing': event.isTyping}),
      );
    });
    on<GetChatStatusEvent>((event, emit) async {
      emit(ChatStatusState());
    });
    on<ChatEvent>((event, emit) async {
      final jsonMsg = json.encode(event.message.toJson());
      print("Sending WS Message: $jsonMsg");
      channel?.sink.add(jsonMsg);
      // Don't emit SuccessGetMyMessagesState here as it belongs to the conversation list
      // Instead, we stay on the current state and wait for the message to return via the stream
    });
    on<DeleteMessageEvent>((event, emit) async {
      final results = await deleteMessageUseCase(event.message);
      results.fold(
        (l) => emit(FailureDeleteMessageState()),
        (r) => emit(SuccessDeleteMessageState()),
      );
    });
    on<UpdateMessageEvent>((event, emit) async {
      final results = await updateMessageUseCase(event.message);
      results.fold(
        (l) => emit(FailureUpdateMessageState()),
        (r) => emit(SuccessUpdateMessageState()),
      );
    });
    on<SetMessageReceiverEvent>((event, emit) async {
      MessageReceiverState.profile = event.profile;
      emit(MessageReceiverState());
    });
    on<ChooseMessageImageFromGalleyEvent>((event, emit) async {
      await Helpers.selectImageFromGallery();
      MessageImageState.image =
          image; // 'image' from init.dart is updated by selectImageFromGallery
      emit(MessageImageState());
    });
    on<ChooseMessageImageFromCameraEvent>((event, emit) async {
      await Helpers.selectImageFromCamera();
      // Ensure we are using the updated 'image' from init.dart
      MessageImageState.image = image;
      emit(MessageImageState());
    });
    on<ImageEvent>((event, emit) async {
      WithImageState.isWithImage = event.isWithImage;
      emit(WithImageState());
    });
    on<GetMessagesEvent>((event, emit) async {
      try {
        final cached = sl<HiveService>()
            .getBox(HiveService.messageBox)
            .get('messages_${event.receiver}');
        if (cached != null) {
          SuccessGetMessageState.messages = Future.value(List<ChatMessage>.from(cached));
          emit(SuccessGetMessageState());
        }
      } catch (e) {
        // Ignore cache read errors at this stage
      }

      final results = await getMessagesUseCase(event.receiver);
      results.fold(
        (l) {
          if (SuccessGetMessageState.messages == null) {
             SuccessGetMessageState.messages = Future.value([]);
             emit(FailureGetMessageState());
          }
        },
        (r) {
          SuccessGetMessageState.messages = Future.value(r);
          emit(SuccessGetMessageState());
        },
      );
    }, transformer: sequential());
    on<CalenderAppointmentEvent>((event, emit) async {
      SetAppointmentState.setAppointment = event.setAppointment;
      emit(SetAppointmentState());
    });
    on<ReloadMessagesEvent>((event, emit) async {
      final results = await reloadMessageReceiverUseCase(event.user);
      results.fold(
        (l) {
          emit(FailureGetMyMessagesState());
        },
        (r) {
          MessageReceiverState.profile = r;
          emit(MessageReceiverState());
        },
      );
      emit(ReloadMessageState());
    });
    on<GetMyMessagesEvent>((event, emit) async {
      final results = await getMyMessagesUseCase(event);
      results.fold(
        (l) {
          SuccessGetMyMessagesState.myMessages = Future.value([]);
          emit(FailureGetMyMessagesState());
        },
        (r) {
          SuccessGetMyMessagesState.myMessages = Future.value(r ?? []);
          int count = 0;
          if (r != null) {
            for (var chat in r) {
              count += (chat.chat?.unreadCount ?? 0);
            }
          }
          SuccessGetMyMessagesState.unreadMessageCount = count;
          emit(SuccessGetMyMessagesState());
        },
      );
    }, transformer: sequential());
    on<SetSeenMessageEvent>((event, emit) async {
      final results = await setSeenUseCase(event.reciever);
      results.fold((l) => emit(FailureSetSeenMessageState()), (r) {
        add(GetMyMessagesEvent());
        emit(SuccessSetSeenMessageState());
      });
    });
    on<GetChatEvent>((event, emit) async {});
  }
}
