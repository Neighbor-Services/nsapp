import 'dart:convert';
import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:nsapp/core/constants/urls.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class DeviceTokenService {
  static const MethodChannel _channel = MethodChannel('com.nsapp/notifications');

  /// Initialize and listen for native token updates (iOS only)
  static void initialize() {
    if (Platform.isIOS) {
       _channel.setMethodCallHandler((call) async {
        if (call.method == "onTokenReceived") {
          final String token = call.arguments;
          debugPrint("DEBUG [Dart]: Received APNs token from iOS: $token");
          
          // Save it locally first
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("apns_token", token);
          
          await registerToken(token, 'IOS');
        }
      });
    }
  }

  /// Attempts to register a previously saved token (called after login)
  static Future<void> tryRegisterStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("apns_token");
    if (token != null && token.isNotEmpty) {
      await registerToken(token, 'IOS');
    }
  }

  /// Sends the device token to the Django backend
  static Future<void> registerToken(String token, String platform) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString("token") ?? "";

      if (userToken.isEmpty) {
        debugPrint("DEBUG [DeviceTokenService]: No user auth token yet. Skipping registration.");
        return;
      }

      final deviceId = await _getDeviceId();
      final url = Uri.parse("$baseUrl/api/notifications/tokens/");
      
      debugPrint("DEBUG [DeviceTokenService]: Registering $platform token on backend...");
      
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $userToken",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "token": token,
          "platform": platform, // Should match 'IOS' or 'ANDROID' choices in Django
          "device_id": deviceId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("DEBUG [DeviceTokenService]: Token registered successfully.");
      } else {
        debugPrint("DEBUG [DeviceTokenService]: Failed to register token: ${response.body}");
      }
    } catch (e) {
      debugPrint("DEBUG [DeviceTokenService]: Error registering token: $e");
    }
  }

  static Future<String?> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor;
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      }
    } catch (e) {
      debugPrint("DEBUG: Failed to get device ID: $e");
    }
    return null;
  }
}
