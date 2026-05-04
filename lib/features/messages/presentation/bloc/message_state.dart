part of 'message_bloc.dart';

sealed class MessageState {}

class ChatStatusState extends MessageState {
  final bool isTyping;
  final bool isOnline;
  final String? targetUserId;

  ChatStatusState({
    this.isTyping = false,
    this.isOnline = false,
    this.targetUserId,
  });
}

final class MessageInitial extends MessageState {}

final class LoadingMessageState extends MessageState {}

final class SuccessSendMessageState extends MessageState {}

final class SuccessGetMessageState extends MessageState {
  final List<ChatMessage> messages;
  SuccessGetMessageState({required this.messages});
}

final class MessageReceiverState extends MessageState {
  final Profile profile;
  MessageReceiverState({required this.profile});
}

final class FailureSendMessageState extends MessageState {
  final String message;
  FailureSendMessageState({required this.message});
}

final class FailureGetMessageState extends MessageState {
  final String message;
  FailureGetMessageState({required this.message});
}

class MessageImageState extends MessageState {
  final XFile? image;
  MessageImageState({this.image});
}

class ClearedImageState extends MessageState {}

class SuccessGetMyMessagesState extends MessageState {
  static int lastUnreadMessageCount = 0;
  static Future<List<Chat>> lastMyMessages = Future.value([]);
  final List<Chat> myMessages;
  final int unreadMessageCount;
  
  SuccessGetMyMessagesState({
    required this.myMessages,
    required this.unreadMessageCount,
  }) {
    SuccessGetMyMessagesState.lastUnreadMessageCount = unreadMessageCount;
    SuccessGetMyMessagesState.lastMyMessages = Future.value(myMessages);
  }
}

class FailureGetMyMessagesState extends MessageState {
  final String message;
  FailureGetMyMessagesState({required this.message});
}

class SetAppointmentState extends MessageState {
  final bool setAppointment;
  SetAppointmentState({required this.setAppointment});
}

class ReloadMessageState extends MessageState {}

class WithImageState extends MessageState {
  final bool isWithImage;
  WithImageState({required this.isWithImage});
}

final class SuccessDeleteMessageState extends MessageState {}

final class SuccessUpdateMessageState extends MessageState {}

final class FailureDeleteMessageState extends MessageState {
  final String message;
  FailureDeleteMessageState({required this.message});
}

final class FailureUpdateMessageState extends MessageState {
  final String message;
  FailureUpdateMessageState({required this.message});
}

final class SuccessSetSeenMessageState extends MessageState {}

final class FailureSetSeenMessageState extends MessageState {
  final String message;
  FailureSetSeenMessageState({required this.message});
}


