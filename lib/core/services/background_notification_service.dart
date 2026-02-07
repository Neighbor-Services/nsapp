import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:nsapp/core/constants/urls.dart';
import 'package:nsapp/core/services/local_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

class BackgroundNotificationService {
  static Future<void> initializeService() async {
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
        autoStart: true,
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
      _retryConnection(service);
    });

    // Initialize Local Notifications within the background isolate
    await LocalNotificationService.initialize();

    _connectWebSocket(service);
  }

  static IOWebSocketChannel? _channel;
  static Timer? _reconnectTimer;

  static void _connectWebSocket(ServiceInstance service) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    if (token.isEmpty) {
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(
        const Duration(minutes: 1),
        () => _connectWebSocket(service),
      );
      return;
    }

    String wsUrl = "";
    try {
      final uri = Uri.parse(baseUrl);
      final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
      final portPart = uri.hasPort ? ":${uri.port}" : "";
      wsUrl = "$scheme://${uri.host}$portPart/ws/notifications/?token=$token";
      debugPrint("DEBUG: Connecting to WebSocket: $wsUrl");
    } catch (e) {
      debugPrint("DEBUG: Error parsing WebSocket URL: $e");
      return;
    }

    try {
      _channel = IOWebSocketChannel.connect(
        Uri.parse(wsUrl),
        connectTimeout: const Duration(seconds: 10),
      );

      _channel!.stream.listen(
        (message) {
          debugPrint("DEBUG: Received background message: $message");
          try {
            final data = json.decode(message);

            // Broadcast to foreground if app is open
            service.invoke('notification', data);

            // Show system tray notification
            LocalNotificationService.showNotification(
              id: DateTime.now().microsecondsSinceEpoch % 1000000,
              title: data['title'] ?? "Neighbor Services",
              body: data['message'] ?? "",
              payload: message,
            );
          } catch (e) {
            debugPrint("DEBUG: Error parsing background message: $e");
          }
        },
        onError: (e) {
          _retryConnection(service);
        },
        onDone: () {
          _retryConnection(service);
        },
        cancelOnError: true,
      );
    } catch (e) {
      _retryConnection(service);
    }
  }

  static void _retryConnection(ServiceInstance service) {
    _channel?.sink.close(status.goingAway);
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(
      const Duration(seconds: 10),
      () => _connectWebSocket(service),
    );
  }
}
