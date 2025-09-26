import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class FcmService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// Check internet availability
  static Future<bool> hasInternet() async {
    var result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Get FCM Token with retry logic
  static Future<String?> getTokenWithRetry({
    int retries = 3,
    Duration delay = const Duration(seconds: 5),
  }) async {
    for (int i = 0; i < retries; i++) {
      try {
        if (await hasInternet()) {
          String? token = await _fcm.getToken();
          if (token != null) {
            debugPrint("✅ FCM Token: $token");
            return token;
          }
        } else {
          debugPrint("⚠️ No internet connection");
        }
      } catch (e) {
        if (e.toString().contains("SERVICE_NOT_AVAILABLE")) {
          debugPrint("🌐 Weak network, retrying... (${i + 1}/$retries)");
          await Future.delayed(delay);
          continue;
        } else {
          debugPrint("❌ FCM Error: $e");
          rethrow;
        }
      }
      await Future.delayed(delay);
    }
    return null;
  }

  /// Initialize notifications
  static Future<void> initNotifications() async {
    // Request permissions (iOS mainly)
    await _fcm.requestPermission();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("📩 Foreground message: ${message.notification?.title}");
    });

    // Handle background/tapped messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("📲 Notification clicked: ${message.notification?.title}");
    });
  }
}
