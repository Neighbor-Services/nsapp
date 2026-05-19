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
<<<<<<< HEAD
=======
  final bool hasReachedMax;
  final int currentPage;
>>>>>>> cc9c85db158902495bd6a3b3dbcc216bd8feb0e7

  SuccessGetMyNotificationsState({
    required this.notifications,
    required this.unreadCount,
<<<<<<< HEAD
=======
    this.hasReachedMax = false,
    this.currentPage = 1,
>>>>>>> cc9c85db158902495bd6a3b3dbcc216bd8feb0e7
  });
}

class SuccessAddNotificationsState extends NotificationState {}

class SuccessSetSeentState extends NotificationState {}

class SuccessTokenState extends NotificationState {
  final String token;
  SuccessTokenState({required this.token});
}
