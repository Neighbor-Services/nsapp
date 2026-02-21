import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';

class NotificationSocketService {
  Future<void> connect() async {
    FlutterBackgroundService().invoke('reconnect');
    FlutterBackgroundService().on('notification').listen((event) {
      if (event != null) {
        Get.snackbar(
          event['title'] ?? "New Notification",
          event['message'] ?? "",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    });
  }

  void disconnect() {
    // Background service manages its own lifecycle
  }
}
