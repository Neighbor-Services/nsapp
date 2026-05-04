import 'dart:convert';
import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:nsapp/core/constants/urls.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class DeviceTokenService {
  static const MethodChannel _channel = MethodChannel('com.nsapp/notifications');

  /// Initialize and listen for native token updates (iOS APNs & Android FCM)
  static void initialize() {
    if (Platform.isIOS) {
       _channel.setMethodCallHandler((call) async {
        if (call.method == "onTokenReceived") {
          final String? token = call.arguments;
          if (token != null) {
            debugPrint("DEBUG [Dart]: Received APNs token from iOS (Push): $token");
            await _handleTokenUpdate(token, 'IOS');
          }
        }
      });

      // Also pull the token immediately in case it was already generated
      _channel.invokeMethod<String>("getLatestToken").then((token) async {
        if (token != null && token.isNotEmpty) {
          debugPrint("DEBUG [Dart]: Received APNs token from iOS (Pull): $token");
          await _handleTokenUpdate(token, 'IOS');
        }
      });
    } else if (Platform.isAndroid) {
      // Initialize Firebase Messaging for Android
      FirebaseMessaging.instance.getToken().then((token) async {
        if (token != null) {
          debugPrint("DEBUG [Dart]: Received FCM token from Android: $token");
          await _handleTokenUpdate(token, 'ANDROID');
        }
      });

      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
        debugPrint("DEBUG [Dart]: FCM token refreshed: $token");
        await _handleTokenUpdate(token, 'ANDROID');
      });
    }
  }

  static Future<void> _handleTokenUpdate(String token, String platform) async {
    // Save it locally first
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("device_push_token", token);
    await prefs.setString("device_platform", platform);
    
    // Attempt registration if user is already logged in
    await registerToken(token, platform);
  }

  /// Attempts to register a previously saved token (called after login)
  static Future<void> tryRegisterStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("device_push_token");
    final platform = prefs.getString("device_platform") ?? (Platform.isIOS ? 'IOS' : 'ANDROID');
    if (token != null && token.isNotEmpty) {
      await registerToken(token, platform);
    }
  }

  /// Sends the device token to the Django backend
  static Future<void> registerToken(String token, String platform) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userAuthToken = prefs.getString("token") ?? "";

      if (userAuthToken.isEmpty) {
        debugPrint("DEBUG [DeviceTokenService]: No user auth token yet. Skipping registration.");
        return;
      }

      final deviceId = await _getDeviceId();
      // Use the centralized notifications endpoint
      final url = Uri.parse("$baseUrl/api/notifications/tokens/");
      
      debugPrint("DEBUG [DeviceTokenService]: Registering $platform token on backend...");
      
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $userAuthToken",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "token": token,
          "platform": platform, // 'IOS' or 'ANDROID'
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


