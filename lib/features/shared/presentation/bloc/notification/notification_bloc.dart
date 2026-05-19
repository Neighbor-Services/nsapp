
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:nsapp/core/models/notification.dart' as not;
import 'package:nsapp/features/shared/domain/usecase/add_notification_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/get_my_notifications_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/set_seen_notification_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/get_token_usecase.dart';
import 'package:nsapp/core/models/notify.dart';
import 'package:nsapp/core/services/local_notification_service.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends HydratedBloc<NotificationEvent, NotificationState> {

  final AddNotificationUseCase addNotificationUseCase;
  final GetMyNotificationsUseCase getMyNotificationsUseCase;
  final SetSeenNotificationUseCase seenNotificationUseCase;
  // Legacy service removed in favor of BackgroundNotificationService
  final GetTokenUsecase getTokenUsecase;

  NotificationBloc({
    required this.addNotificationUseCase,
    required this.getMyNotificationsUseCase,
    required this.seenNotificationUseCase,
    required this.getTokenUsecase,
  }) : super(NotificationInitial()) {
    on<AddNotificationEvent>((event, emit) async {
      final results = await addNotificationUseCase(event.notification);
      results.fold(
        (l) => emit(NotificationFailure(l.message)),
        (r) => emit(SuccessAddNotificationsState()),
      );
    });

    on<GetMyNotificationsEvent>((event, emit) async {
      final results = await getMyNotificationsUseCase(event.page);
      results.fold(
        (l) => emit(NotificationFailure(l.message)),
        (r) {
          emit(SuccessGetMyNotificationsState(
            notifications: r,
            unreadCount: r.where((n) => n.notification?.isRead == false).length,

            hasReachedMax: r.length < 10, // Assuming PAGE_SIZE is 10
            currentPage: event.page,
          ));
        },
      );
    }, transformer: sequential());

    on<LoadMoreNotificationsEvent>((event, emit) async {
      final currentState = state;
      if (currentState is SuccessGetMyNotificationsState && !currentState.hasReachedMax) {
        final results = await getMyNotificationsUseCase(event.page);
        results.fold(
          (l) => emit(NotificationFailure(l.message)),
          (r) {
            if (r.isEmpty) {
              emit(SuccessGetMyNotificationsState(
                notifications: currentState.notifications,
                unreadCount: currentState.unreadCount,
                hasReachedMax: true,
                currentPage: currentState.currentPage,
              ));
            } else {
              final updatedNotifications = List<not.NotificationData>.from(currentState.notifications)..addAll(r);
              emit(SuccessGetMyNotificationsState(
                notifications: updatedNotifications,
                unreadCount: updatedNotifications.where((n) => n.notification?.isRead == false).length,
                hasReachedMax: r.length < 10,
                currentPage: event.page,
              ));
            }
          },
        );
      }
    }, transformer: sequential());

    on<SetNotificationSeenEvent>((event, emit) async {
      final currentState = state;
      if (currentState is SuccessGetMyNotificationsState) {
        // Optimistic update
        final updatedNotifications = currentState.notifications.map((n) {
          if (n.notification?.id == event.notificationID) {
            // Create a new notification object with isRead = true
            final updatedNotif = not.Notification(
              id: n.notification?.id,
              notificationType: n.notification?.notificationType,
              title: n.notification?.title,
              message: n.notification?.message,
              data: n.notification?.data,
              isRead: true,
              createdAt: n.notification?.createdAt,
            );
            return not.NotificationData(
              notification: updatedNotif,
              from: n.from,
              to: n.to,
            );
          }
          return n;
        }).toList();

        emit(SuccessGetMyNotificationsState(
          notifications: updatedNotifications,
          unreadCount: (currentState.unreadCount - 1).clamp(0, 999),
          hasReachedMax: currentState.hasReachedMax,
          currentPage: currentState.currentPage,
        ));
      }

      final results = await seenNotificationUseCase(event.notificationID);
      results.fold(
        (l) {
          // If server fails, we refresh to get the true state
          add(GetMyNotificationsEvent());
          emit(NotificationFailure(l.message));
        },
        (r) {
          // No need to reload full list on success as we already updated optimistically
          emit(SuccessSetSeentState());
        },
      );
    });

    on<ConnectNotificationSocketEvent>((event, emit) async {
      // Deprecated: FCM handles foreground delivery natively.
    });

    on<DisconnectNotificationSocketEvent>((event, emit) {
      // Deprecated: FCM handles foreground delivery natively.
    });

    on<GetTokenEvent>((event, emit) async {
      final token = await getTokenUsecase(null);
      token.fold((l) => null, (r) => emit(SuccessTokenState(token: r)));
    });

    on<SendNotificationEvent>((event, emit) {
      final model = event.notificationModel;
      
      // If a userId is provided, sync it to the backend as well
      if (model.userId != null) {
        add(AddNotificationEvent(
          notification: not.Notification(
            title: model.title,
            message: model.body,
            notificationType: "SYSTEM",
            targetUserId: model.userId,
          )
        ));
      }

      LocalNotificationService.showNotification(
        id: DateTime.now().microsecondsSinceEpoch % 1000000,
        title: model.title ?? "New Notification",
        body: model.body ?? "",
      );
    });
  }

  @override
  NotificationState? fromJson(Map<String, dynamic> json) {
    try {
      if (json['notifications'] != null) {
        final notifications = (json['notifications'] as List)
            .map((e) => not.NotificationData.fromJson(e))
            .toList();
        return SuccessGetMyNotificationsState(
          notifications: notifications,
          unreadCount: json['unreadCount'] ?? 0,
          hasReachedMax: json['hasReachedMax'] ?? false,
          currentPage: json['currentPage'] ?? 1,
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(NotificationState state) {
    if (state is SuccessGetMyNotificationsState) {
      return {
        'notifications': state.notifications.map((e) => e.toJson()).toList(),
        'unreadCount': state.unreadCount,
        'hasReachedMax': state.hasReachedMax,
        'currentPage': state.currentPage,
      };
    }
    return null;
  }
}
