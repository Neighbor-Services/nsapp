import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:nsapp/core/services/local_notification_service.dart';
import 'package:nsapp/core/services/notification_navigator.dart';

/// MUST be a top-level function (NOT a static class method) so Firebase can
/// invoke it in a separate background isolate when the app is terminated or
/// in the background. Any static method would be silently ignored.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Note: Firebase is already initialised by the time this is called, but
  // FlutterLocalNotificationsPlugin is NOT — calling showNotification here
  // would require re-initialising it. For now we log and let the system
  // notification tray handle notification-type messages automatically.
  // Data-only (silent) messages that arrive in the background must be
  // processed here if they require local storage updates, etc.
  debugPrint(
    "DEBUG [FCM BG]: Background message received — id: ${message.messageId}, "
    "type: ${message.data['notification_type']}",
  );
}

class BackgroundNotificationService {

  /// Initialize Firebase Messaging handlers. Call once from main().
  static Future<void> initializeService() async {
    // 1. Register the top-level background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 2. Request notification permission (required on iOS and Android 13+)
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    // Set foreground notification options for iOS
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint(
      "DEBUG [FCM]: Permission status: ${settings.authorizationStatus}",
    );

    // 3. Handle foreground messages — show a local notification banner
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("DEBUG [FCM]: Foreground message received: ${message.data}");
      _showLocalNotification(message);
    });

    // 4. Handle notification tap when app is in background (not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
        "DEBUG [FCM]: App opened via notification tap: ${message.data}",
      );
      // Navigate to the relevant screen. The app is already running so
      // NotificationNavigator can route immediately if /home is in the stack,
      // or stash the data for the home page to consume after mounting.
      NotificationNavigator.handleTap(message.data);
    });

    // 5. Handle cold-start (app launched from a terminated state by tapping a notification)
    FirebaseMessaging.instance.getInitialMessage().then((initialMessage) {
      if (initialMessage != null) {
        debugPrint(
          "DEBUG [FCM]: App launched via notification tap (cold start): "
          "${initialMessage.data}",
        );
        // Store the data in PendingNotificationStore. The home screen will
        // consume it in initState once BLoCs are ready and navigate accordingly.
        NotificationNavigator.handleTap(initialMessage.data, isColdStart: true);
      }
    }).catchError((e) {
      debugPrint("DEBUG [FCM]: Error getting initial message: $e");
    });
  }

  static void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;

    LocalNotificationService.showNotification(
      id: DateTime.now().microsecondsSinceEpoch % 1000000,
      title: notification?.title ?? data['title'] ?? "Neighbor Services",
      body: notification?.body ?? data['message'] ?? "",
      payload: json.encode(data),
    );
  }
}
