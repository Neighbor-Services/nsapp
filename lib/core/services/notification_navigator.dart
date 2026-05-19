import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:nsapp/features/shared/presentation/bloc/settings/settings_bloc.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart' hide GetAppointmentsEvent;
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart' as provider_bloc show GetAppointmentsEvent;
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart' hide GetAppointmentsEvent;
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart' as seeker_bloc show GetAppointmentsEvent;
import 'package:nsapp/features/provider/presentation/pages/provider_request_detail_page.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_request_page.dart';

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
    final current = Get.currentRoute;
    return current == '/home' || current.startsWith('/app/');
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
    final context = Get.context;
    if (context == null) {
      debugPrint("DEBUG [NotificationNavigator]: Get.context is null, cannot navigate.");
      return;
    }

    final type = (data['notification_type'] as String? ?? '').toLowerCase();
    final requestId = data['request_id']?.toString();

    debugPrint(
      "DEBUG [NotificationNavigator]: Navigating for type=$type, request_id=$requestId",
    );

    // Make sure we are actually on the home route layout before dispatching tab events
    if (Get.currentRoute != '/home' && !Get.currentRoute.startsWith('/app/')) {
      Get.until((route) => route.settings.name == '/home');
    }

    final isProvider = context.read<SettingsBloc>().state.isProvider;

    switch (type) {
      case 'message':
        // Navigate to the Messages tab (page index 4)
        if (isProvider) {
          context.read<ProviderBloc>().add(ChangeProviderTabEvent(tabIndex: 4));
        } else {
          context.read<SeekerBloc>().add(ChangeSeekerTabEvent(tabIndex: 4));
        }
        break;

      case 'proposal':
      case 'request':
      case 'direct_request':
        if (requestId != null && requestId.isNotEmpty) {
          if (isProvider) {
            context.read<ProviderBloc>().add(
                  GetRequestDetailEvent(id: requestId),
                );
            Get.to(() => const ProviderRequestDetailPage());
          } else {
            Get.to(() => const SeekerRequestPage());
          }
        } else {
          if (isProvider) {
            context.read<ProviderBloc>().add(ChangeProviderTabEvent(tabIndex: 3));
          } else {
            Get.to(() => const SeekerRequestPage());
          }
        }
        break;

      case 'appointment':
        if (isProvider) {
          context.read<ProviderBloc>().add(provider_bloc.GetAppointmentsEvent());
          context.read<ProviderBloc>().add(ChangeProviderTabEvent(tabIndex: 5));
        } else {
          context.read<SeekerBloc>().add(seeker_bloc.GetAppointmentsEvent());
          Get.to(() => const SeekerRequestPage());
        }
        break;

      case 'system':
      default:
        // Do nothing, just stay on home
        break;
    }
  }
}
