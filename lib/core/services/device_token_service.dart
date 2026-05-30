import 'dart:convert';
import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:nsapp/core/constants/urls.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:flutter/material.dart';

class DeviceTokenService {
  /// Initialize and listen for native token updates (iOS APNs & Android FCM)
  static void initialize() {
    // Both iOS and Android can use FirebaseMessaging.instance.getToken()
    // once APNs is properly configured in the Firebase Console for iOS.
    Future(() async {
      try {
        if (Platform.isIOS) {
          final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          if (apnsToken == null) {
            debugPrint(
              "DEBUG [Dart]: APNS token is null. It might take a moment to be assigned. Proceeding to getToken()...",
            );
          }
        }
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          final platform = Platform.isIOS ? 'IOS' : 'ANDROID';
          debugPrint("DEBUG [Dart]: Received FCM token from $platform: $token");
          await _handleTokenUpdate(token, platform);
        }
      } catch (e) {
        debugPrint("DEBUG [Dart]: Error fetching FCM token: $e");
      }
    });

    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh
        .listen((token) async {
          final platform = Platform.isIOS ? 'IOS' : 'ANDROID';
          debugPrint("DEBUG [Dart]: FCM token refreshed: $token");
          await _handleTokenUpdate(token, platform);
        })
        .onError((error) {
          debugPrint("DEBUG [Dart]: Error on token refresh: $error");
        });
  }

  static Future<void> _handleTokenUpdate(String token, String platform) async {
    // Save it locally first
    await Helpers.saveString("device_push_token", token);
    await Helpers.saveString("device_platform", platform);

    // Attempt registration if user is already logged in
    await registerToken(token, platform);
  }

  /// Attempts to register a previously saved token (called after login)
  static Future<void> tryRegisterStoredToken() async {
    final token = await Helpers.getString("device_push_token");
    final platform = await Helpers.getString("device_platform");
    final effectivePlatform = platform.isNotEmpty
        ? platform
        : (Platform.isIOS ? 'IOS' : 'ANDROID');

    if (token.isNotEmpty) {
      await registerToken(token, effectivePlatform);
    }
  }

  /// Sends the device token to the Django backend
  static Future<void> registerToken(String token, String platform) async {
    try {
      final userAuthToken = await Helpers.getString("token");

      if (userAuthToken.isEmpty) {
        debugPrint(
          "DEBUG [DeviceTokenService]: No user auth token yet. Skipping registration.",
        );
        return;
      }

      final deviceId = await _getDeviceId();
      // Use the centralized notifications endpoint
      final url = Uri.parse("$baseUrl/notifications/tokens/");

      debugPrint(
        "DEBUG [DeviceTokenService]: Registering $platform token on backend...",
      );

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
        debugPrint(
          "DEBUG [DeviceTokenService]: Token registered successfully.",
        );
      } else {
        debugPrint(
          "DEBUG [DeviceTokenService]: Failed to register token: ${response.body}",
        );
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
