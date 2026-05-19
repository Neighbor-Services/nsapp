part of 'notification_bloc.dart';

abstract class NotificationEvent {}

class AddNotificationEvent extends NotificationEvent {
  final not.Notification notification;
  AddNotificationEvent({required this.notification});
}

<<<<<<< HEAD
class GetMyNotificationsEvent extends NotificationEvent {}
=======
class GetMyNotificationsEvent extends NotificationEvent {
  final int page;
  GetMyNotificationsEvent({this.page = 1});
}

class LoadMoreNotificationsEvent extends NotificationEvent {
  final int page;
  LoadMoreNotificationsEvent({required this.page});
}
>>>>>>> cc9c85db158902495bd6a3b3dbcc216bd8feb0e7

class SetNotificationSeenEvent extends NotificationEvent {
  final String notificationID;
  SetNotificationSeenEvent({required this.notificationID});
}

class ConnectNotificationSocketEvent extends NotificationEvent {}

class DisconnectNotificationSocketEvent extends NotificationEvent {}

class GetTokenEvent extends NotificationEvent {}

class SendNotificationEvent extends NotificationEvent {
  final Notify notificationModel;
  SendNotificationEvent({required this.notificationModel});
}
