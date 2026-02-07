part of 'message_bloc.dart';

sealed class MessageEvent {}

class ChatEvent extends MessageEvent {
  final Message message;

  ChatEvent({required this.message});
}

class SetMessageReceiverEvent extends MessageEvent {
  final Profile profile;

  SetMessageReceiverEvent({required this.profile});
}

class ChooseMessageImageFromGalleyEvent extends MessageEvent {}

class ChooseMessageImageFromCameraEvent extends MessageEvent {}

class ImageEvent extends MessageEvent {
  final bool isWithImage;

  ImageEvent({required this.isWithImage});
}

class GetMessagesEvent extends MessageEvent {
  final String receiver;

  GetMessagesEvent({required this.receiver});
}

class CalenderAppointmentEvent extends MessageEvent {
  final bool setAppointment;

  CalenderAppointmentEvent({required this.setAppointment});
}

class GetMyMessagesEvent extends MessageEvent {}

class ReloadMessagesEvent extends MessageEvent {
  final String user;

  ReloadMessagesEvent({required this.user});
}

class DeleteMessageEvent extends MessageEvent {
  final Message message;

  DeleteMessageEvent({required this.message});
}

class UpdateMessageEvent extends MessageEvent {
  final Message message;

  UpdateMessageEvent({required this.message});
}

class SetSeenMessageEvent extends MessageEvent {
  final String reciever;

  SetSeenMessageEvent({required this.reciever});
}

class KeyboardVisibilityEvent extends MessageEvent {
  final double keyboardHeight;
  KeyboardVisibilityEvent(this.keyboardHeight);
}

class SendTypingEvent extends MessageEvent {
  final bool isTyping;
  SendTypingEvent({required this.isTyping});
}

class GetChatStatusEvent extends MessageEvent {}

class ConnectWebSocketEvent extends MessageEvent {
  final String receiver;
  final String sender;
  ConnectWebSocketEvent({required this.sender, required this.receiver});
}

class GetChatEvent extends MessageEvent {
  final String receiver;
  final String sender;
  GetChatEvent({required this.sender, required this.receiver});
}
