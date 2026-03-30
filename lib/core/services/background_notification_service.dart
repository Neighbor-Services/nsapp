import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:nsapp/core/constants/urls.dart';
import 'package:nsapp/core/services/local_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

class BackgroundNotificationService {
  // --- Foreground WebSocket (used on both platforms while app is open) ---
  static IOWebSocketChannel? _foregroundChannel;
  static Timer? _foregroundReconnectTimer;
  static bool _foregroundConnected = false;

  /// Call this after login to connect the foreground WebSocket.
  /// Works on both Android and iOS.
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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      if (token.isEmpty) {
        debugPrint("DEBUG [Foreground WS]: No token. Retrying in 30s...");
        _foregroundReconnectTimer = Timer(
          const Duration(seconds: 30),
          _connectForegroundWebSocket,
        );
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
            // Show a local notification even while the app is in the foreground
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

  // ----------------------------------------------------------------
  // --- Background Service (Android only — iOS doesn't support it) ---
  // ----------------------------------------------------------------

  static Future<void> initializeService() async {
    // flutter_background_service does not run persistently on iOS.
    // On iOS, we rely solely on the foreground WebSocket + local notifications.
    if (Platform.isIOS) {
      debugPrint("DEBUG: Background service skipped on iOS (not supported without APNs).");
      return;
    }

    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'high_importance_channel',
        initialNotificationTitle: 'Neighbor Services',
        initialNotificationContent: 'Notification service is running',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false, // Disabled on iOS
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );

    await service.startService();
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    service.on('reconnect').listen((event) {
      _retryAndroidBackground(service);
    });

    // Initialize Local Notifications within the background isolate
    await LocalNotificationService.initialize();

    _connectAndroidBackgroundWebSocket(service);
  }

  static IOWebSocketChannel? _channel;
  static Timer? _reconnectTimer;

  static void _connectAndroidBackgroundWebSocket(ServiceInstance service) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      if (token.isEmpty) {
        debugPrint("DEBUG [Android BG WS]: No token found. Retrying in 1 minute...");
        _reconnectTimer?.cancel();
        _reconnectTimer = Timer(
          const Duration(minutes: 1),
          () => _connectAndroidBackgroundWebSocket(service),
        );
        return;
      }

      final wsUrl = _buildWsUrl(token);
      if (wsUrl == null) return;
      debugPrint("DEBUG [Android BG WS]: Connecting to $wsUrl");

      _channel = IOWebSocketChannel.connect(
        Uri.parse(wsUrl),
        connectTimeout: const Duration(seconds: 10),
      );

      _channel!.stream.listen(
        (message) {
          debugPrint("DEBUG [Android BG WS]: Message received: $message");
          try {
            final data = json.decode(message) as Map<String, dynamic>;

            // Broadcast to foreground UI if app is open
            service.invoke('notification', data);

            // Show system tray notification
            LocalNotificationService.showNotification(
              id: DateTime.now().microsecondsSinceEpoch % 1000000,
              title: data['title'] as String? ?? "Neighbor Services",
              body: data['message'] as String? ?? "",
              payload: message,
            );
          } catch (e) {
            debugPrint("DEBUG [Android BG WS]: Error parsing message: $e");
          }
        },
        onError: (e) {
          debugPrint("DEBUG [Android BG WS]: Error: $e. Retrying...");
          _retryAndroidBackground(service);
        },
        onDone: () {
          debugPrint("DEBUG [Android BG WS]: Closed. Retrying...");
          _retryAndroidBackground(service);
        },
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint("DEBUG [Android BG WS]: Critical error: $e");
      _retryAndroidBackground(service);
    }
  }

  static void _retryAndroidBackground(ServiceInstance service) {
    _channel?.sink.close(status.goingAway);
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(
      const Duration(seconds: 15),
      () => _connectAndroidBackgroundWebSocket(service),
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
