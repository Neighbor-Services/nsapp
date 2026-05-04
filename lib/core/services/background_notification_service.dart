import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:nsapp/core/constants/urls.dart';
import 'package:nsapp/core/services/local_notification_service.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

class BackgroundNotificationService {
  // --- Foreground WebSocket (for real-time updates when app is open) ---
  static IOWebSocketChannel? _foregroundChannel;
  static Timer? _foregroundReconnectTimer;
  static bool _foregroundConnected = false;

  /// Initialize Firebase Messaging handlers
  static Future<void> initializeService() async {
    // 1. Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("DEBUG [FCM]: Foreground message received: ${message.data}");
      _showLocalNotification(message);
    });

    // 3. Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("DEBUG [FCM]: App opened via notification: ${message.data}");
    });
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // This runs in a separate isolate
    debugPrint("DEBUG [FCM]: Background message received: ${message.messageId}");
    // No need to show notification manually here if it has a 'notification' payload,
    // but if it's data-only, we might need LocalNotificationService.
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

  /// Call this after login to connect the foreground WebSocket.
  static Future<void> connectForeground() async {
    _disconnectForeground();
    _foregroundConnected = true;
    await _connectForegroundWebSocket();
  }

  /// Call this on logout to cleanly disconnect.
  static void disconnectForeground() {
    _foregroundConnected = false;
    _disconnectForeground();
  }

  static void _disconnectForeground() {
    _foregroundReconnectTimer?.cancel();
    _foregroundChannel?.sink.close(status.goingAway);
    _foregroundChannel = null;
  }

  static Future<void> _connectForegroundWebSocket() async {
    if (!_foregroundConnected) return;

    try {
      final token = await Helpers.getString("token");
      if (token.isEmpty) {
        debugPrint("DEBUG [Foreground WS]: No token. Aborting reconnection loop.");
        _foregroundConnected = false;
        return;
      }

      final wsUrl = _buildWsUrl(token);
      if (wsUrl == null) return;
      debugPrint("DEBUG [Foreground WS]: Connecting to $wsUrl");

      _foregroundChannel = IOWebSocketChannel.connect(
        Uri.parse(wsUrl),
        connectTimeout: const Duration(seconds: 10),
      );

      _foregroundChannel!.stream.listen(
        (message) {
          debugPrint("DEBUG [Foreground WS]: Message received: $message");
          try {
            final data = json.decode(message) as Map<String, dynamic>;
            // WebSocket messages are typically "data-only" and we handle them here
            LocalNotificationService.showNotification(
              id: DateTime.now().microsecondsSinceEpoch % 1000000,
              title: data['title'] as String? ?? "Neighbor Services",
              body: data['message'] as String? ?? "",
              payload: message,
            );
          } catch (e) {
            debugPrint("DEBUG [Foreground WS]: Error parsing message: $e");
          }
        },
        onError: (e) {
          debugPrint("DEBUG [Foreground WS]: Error: $e. Retrying...");
          _retryForeground();
        },
        onDone: () {
          debugPrint("DEBUG [Foreground WS]: Closed. Retrying...");
          _retryForeground();
        },
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint("DEBUG [Foreground WS]: Critical error: $e");
      _retryForeground();
    }
  }

  static void _retryForeground() {
    if (!_foregroundConnected) return;
    _foregroundChannel?.sink.close(status.goingAway);
    _foregroundChannel = null;
    _foregroundReconnectTimer?.cancel();
    _foregroundReconnectTimer = Timer(
      const Duration(seconds: 15),
      _connectForegroundWebSocket,
    );
  }

  // --- Shared helper ---
  static String? _buildWsUrl(String token) {
    try {
      String cleanBaseUrl = baseUrl;
      if (cleanBaseUrl.endsWith('/')) {
        cleanBaseUrl = cleanBaseUrl.substring(0, cleanBaseUrl.length - 1);
      }
      final uri = Uri.parse(cleanBaseUrl);
      final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
      final portPart = uri.hasPort ? ":${uri.port}" : "";
      return "$scheme://${uri.host}$portPart/ws/notifications/?token=$token";
    } catch (e) {
      debugPrint("DEBUG: Error building WebSocket URL: $e");
      return null;
    }
  }
}


