part of 'message_bloc.dart';

sealed class MessageState {}

class ChatStatusState extends MessageState {
  static bool isTyping = false;
  static bool isOnline = false;
  static String? targetUserId;
}

final class MessageInitial extends MessageState {}

final class LoadingMessageState extends MessageState {}

final class SuccessSendMessageState extends MessageState {}

final class SuccessGetMessageState extends MessageState {
  static Future<List<ChatMessage>>? messages;
}

final class MessageReceiverState extends MessageState {
  static Profile profile = Profile();
}

final class FailureSendMessageState extends MessageState {}

final class FailureGetMessageState extends MessageState {}

class MessageImageState extends MessageState {
  static XFile? image;
}

class ClearedImageState extends MessageState {}

class SuccessGetMyMessagesState extends MessageState {
  static Future<List<Chat>>? myMessages;
  static int unreadMessageCount = 0;
}

class FailureGetMyMessagesState extends MessageState {}

class SetAppointmentState extends MessageState {
  static bool setAppointment = false;
}

class ReloadMessageState extends MessageState {}

class WithImageState extends MessageState {
  static bool isWithImage = false;
}

final class SuccessDeleteMessageState extends MessageState {}

final class SuccessUpdateMessageState extends MessageState {}

final class FailureDeleteMessageState extends MessageState {}

final class FailureUpdateMessageState extends MessageState {}

final class SuccessSetSeenMessageState extends MessageState {}

final class FailureSetSeenMessageState extends MessageState {}
