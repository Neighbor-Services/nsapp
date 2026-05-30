import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nsapp/core/routes/app_router.dart';

import 'package:nsapp/features/shared/presentation/bloc/settings/settings_bloc.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart' hide GetAppointmentsEvent;
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart' as provider_bloc show GetAppointmentsEvent;
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart' hide GetAppointmentsEvent;
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart' as seeker_bloc show GetAppointmentsEvent;
import 'package:nsapp/features/messages/presentation/bloc/message_bloc.dart';


/// Holds a pending notification payload that arrived when the app was
/// terminated or in the background, so the home screen can act on it
/// after the widget tree and BLoCs are ready.
class PendingNotificationStore {
  PendingNotificationStore._();
  static final PendingNotificationStore instance = PendingNotificationStore._();

  Map<String, dynamic>? _pendingData;

  /// Save a payload to be consumed once the home screen is mounted.
  void setPending(Map<String, dynamic> data) {
    _pendingData = data;
    debugPrint(
      "DEBUG [PendingNotificationStore]: Stored pending notification: $data",
    );
  }

  /// Consume and clear the pending payload. Returns null if nothing is pending.
  Map<String, dynamic>? consumePending() {
    final data = _pendingData;
    _pendingData = null;
    return data;
  }

  bool get hasPending => _pendingData != null;
}

/// Provides context-free navigation for FCM notification taps.
class NotificationNavigator {
  NotificationNavigator._();

  /// Determine whether we can navigate right now (home page is in the stack).
  static bool get _isHomeReady {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return false;
    try {
      final location = GoRouterState.of(context).matchedLocation;
      return location == '/home' || location.startsWith('/app/');
    } catch (_) {
      return false;
    }
  }

  /// Navigate immediately or stash for later consumption by the home screen.
  static void handleTap(Map<String, dynamic> data, {bool isColdStart = false}) {
    if (isColdStart || !_isHomeReady) {
      // App was cold-started or the home page isn't mounted yet.
      PendingNotificationStore.instance.setPending(data);

      if (isColdStart && !_isHomeReady) {
        debugPrint("DEBUG [NotificationNavigator]: Cold-start tap stashed.");
      }
      return;
    }

    // App is already on the home screen — navigate directly using the global context.
    _navigate(data);
  }

  /// Consume any pending notification stored during cold-start / background.
  /// Call this from [HomePage.initState] after BLoCs are ready.
  static void consumePendingNavigation() {
    final data = PendingNotificationStore.instance.consumePending();
    if (data != null) {
      // Slight delay so the home page widget tree is fully mounted.
      Future.delayed(const Duration(milliseconds: 500), () => _navigate(data));
    }
  }

  static Future<void> _navigate(Map<String, dynamic> data) async {
    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      debugPrint("DEBUG [NotificationNavigator]: rootNavigatorKey context is null, cannot navigate.");
      return;
    }

    final type = (data['notification_type'] as String? ?? '').toLowerCase();
    final requestId = data['request_id']?.toString();

    debugPrint(
      "DEBUG [NotificationNavigator]: Navigating for type=$type, request_id=$requestId",
    );

    // If we are not on home, we might need to go there first. 
    // However, context.go('/home') might clear the stack. 
    // For now, we'll assume the home is ready as per _isHomeReady check.

    final isProvider = context.read<SettingsBloc>().state.isProvider;

    switch (type) {
      case 'message':
        final senderId = data['sender_id']?.toString();
        if (senderId != null && senderId.isNotEmpty) {
          final messageBloc = context.read<MessageBloc>();

          bool loaderDismissed = false;
          BuildContext? dialogContext;

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) {
              dialogContext = ctx;
              if (loaderDismissed) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (ctx.mounted && Navigator.of(ctx).canPop()) {
                    Navigator.of(ctx).pop();
                  }
                });
              }
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              );
            },
          );

          void dismissLoader() {
            loaderDismissed = true;
            if (dialogContext != null && Navigator.of(dialogContext!).canPop()) {
              Navigator.of(dialogContext!).pop();
            }
          }

          final reloadFuture = messageBloc.stream
              .firstWhere(
                (state) =>
                    state is MessageReceiverState ||
                    state is FailureGetMyMessagesState,
              )
              .timeout(
                const Duration(seconds: 8),
                onTimeout: () => FailureGetMyMessagesState(message: "Timeout"),
              );

          messageBloc.add(ReloadMessagesEvent(user: senderId));
          final reloadState = await reloadFuture;

          dismissLoader();

          if (reloadState is MessageReceiverState) {
            context.push('/chat');
          } else {
            if (isProvider) {
              context.read<ProviderBloc>().add(ChangeProviderTabEvent(tabIndex: 4));
            } else {
              context.read<SeekerBloc>().add(ChangeSeekerTabEvent(tabIndex: 4));
            }
          }
        } else {
          if (isProvider) {
            context.read<ProviderBloc>().add(ChangeProviderTabEvent(tabIndex: 4));
          } else {
            context.read<SeekerBloc>().add(ChangeSeekerTabEvent(tabIndex: 4));
          }
        }
        break;

      case 'proposal':
      case 'request':
      case 'direct_request':
      case 'broadcast_request':
        if (requestId != null && requestId.isNotEmpty) {
          if (isProvider) {
            context.read<ProviderBloc>().add(
                  GetRequestDetailEvent(id: requestId),
                );
            context.push('/app/provider/requests/$requestId');
          } else {
            context.push('/seeker-requests');
          }
        } else {
          if (isProvider) {
            context.read<ProviderBloc>().add(ChangeProviderTabEvent(tabIndex: 3));
          } else {
            context.push('/seeker-requests');
          }
        }
        break;

      case 'appointment':
        if (isProvider) {
          context.read<ProviderBloc>().add(provider_bloc.GetAppointmentsEvent());
          context.read<ProviderBloc>().add(ChangeProviderTabEvent(tabIndex: 5));
        } else {
          context.read<SeekerBloc>().add(seeker_bloc.GetAppointmentsEvent());
          context.push('/seeker-appointments');
        }
        break;

      case 'system':
      default:
        // Do nothing, just stay on home
        break;
    }
  }
}
