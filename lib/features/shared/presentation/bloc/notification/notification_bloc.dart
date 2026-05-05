import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/models/notification.dart' as not;
import 'package:nsapp/features/shared/domain/usecase/add_notification_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/get_my_notifications_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/set_seen_notification_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/get_token_usecase.dart';
import 'package:nsapp/core/services/background_notification_service.dart';
import 'package:nsapp/core/models/notify.dart';
import 'package:nsapp/core/services/local_notification_service.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
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
      final results = await getMyNotificationsUseCase(null);
      results.fold(
        (l) => emit(NotificationFailure(l.message)),
        (r) {
          emit(SuccessGetMyNotificationsState(
            notifications: r,
            unreadCount: r.where((n) => n.notification?.isRead == false).length,
          ));
        },
      );
    }, transformer: sequential());

    on<SetNotificationSeenEvent>((event, emit) async {
      final results = await seenNotificationUseCase(event.notificationID);
      results.fold(
        (l) => emit(NotificationFailure(l.message)),
        (r) {
          add(GetMyNotificationsEvent());
          emit(SuccessSetSeentState());
        },
      );
    });

    on<ConnectNotificationSocketEvent>((event, emit) async {
      await BackgroundNotificationService.connectForeground();
    });

    on<DisconnectNotificationSocketEvent>((event, emit) {
      BackgroundNotificationService.disconnectForeground();
    });

    on<GetTokenEvent>((event, emit) async {
      final token = await getTokenUsecase(null);
      token.fold((l) => null, (r) => emit(SuccessTokenState(token: r)));
    });

    on<SendNotificationEvent>((event, emit) {
      LocalNotificationService.showNotification(
        id: DateTime.now().microsecondsSinceEpoch % 1000000,
        title: event.notificationModel.title ?? "New Notification",
        body: event.notificationModel.body ?? "",
      );
    });
  }
}
