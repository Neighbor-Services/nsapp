part of 'notification_bloc.dart';

abstract class NotificationEvent {}

class AddNotificationEvent extends NotificationEvent {
  final not.Notification notification;
  AddNotificationEvent({required this.notification});
}

class GetMyNotificationsEvent extends NotificationEvent {
  final int page;
  GetMyNotificationsEvent({this.page = 1});
}

class LoadMoreNotificationsEvent extends NotificationEvent {
  final int page;
  LoadMoreNotificationsEvent({required this.page});
}

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
