part of 'notification_bloc.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationFailure extends NotificationState {
  final String? message;
  NotificationFailure(this.message);
}

class SuccessGetMyNotificationsState extends NotificationState {
  final List<not.NotificationData> notifications;
  final int unreadCount;

  SuccessGetMyNotificationsState({
    required this.notifications,
    required this.unreadCount,
  });
}

class SuccessAddNotificationsState extends NotificationState {}

class SuccessSetSeentState extends NotificationState {}

class SuccessTokenState extends NotificationState {
  final String token;
  SuccessTokenState({required this.token});
}
