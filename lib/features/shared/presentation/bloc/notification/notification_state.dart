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

  final bool hasReachedMax;
  final int currentPage;

  SuccessGetMyNotificationsState({
    required this.notifications,
    required this.unreadCount,

    this.hasReachedMax = false,
    this.currentPage = 1,
  });
}

class SuccessAddNotificationsState extends NotificationState {}

class SuccessSetSeentState extends NotificationState {}

class SuccessTokenState extends NotificationState {
  final String token;
  SuccessTokenState({required this.token});
}
