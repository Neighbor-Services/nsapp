part of 'notification_bloc.dart';

abstract class NotificationEvent {}

class AddNotificationEvent extends NotificationEvent {
  final not.Notification notification;
  AddNotificationEvent({required this.notification});
}

class GetMyNotificationsEvent extends NotificationEvent {}

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
