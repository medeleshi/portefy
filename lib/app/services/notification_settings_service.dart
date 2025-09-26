import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationSettingsService extends GetxService {
  static NotificationSettingsService get instance => Get.find();

  // final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  // final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // Notification preferences
  final RxBool notificationsEnabled = true.obs;
  final RxBool emailNotifications = true.obs;
  final RxBool pushNotifications = true.obs;
  final RxBool soundEnabled = true.obs;
  final RxBool vibrationEnabled = true.obs;
  final RxBool showOnLockScreen = true.obs;

  // Time preferences
  final RxString startTime = '09:00'.obs;
  final RxString endTime = '21:00'.obs;
  final RxBool quietHoursEnabled = false.obs;

  // Notification categories
  final RxBool postNotifications = true.obs;
  final RxBool commentNotifications = true.obs;
  final RxBool likeNotifications = true.obs;
  final RxBool followNotifications = true.obs;
  final RxBool messageNotifications = true.obs;
  final RxBool systemNotifications = true.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await loadSettings();
    // await initializeNotifications();
    // await setupFCM();
  }

  // Load notification settings
  Future<void> loadSettings() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      notificationsEnabled.value = prefs.getBool('notifications_enabled') ?? true;
      emailNotifications.value = prefs.getBool('email_notifications') ?? true;
      pushNotifications.value = prefs.getBool('push_notifications') ?? true;
      soundEnabled.value = prefs.getBool('sound_enabled') ?? true;
      vibrationEnabled.value = prefs.getBool('vibration_enabled') ?? true;
      showOnLockScreen.value = prefs.getBool('show_on_lock_screen') ?? true;
      
      startTime.value = prefs.getString('quiet_hours_start') ?? '09:00';
      endTime.value = prefs.getString('quiet_hours_end') ?? '21:00';
      quietHoursEnabled.value = prefs.getBool('quiet_hours_enabled') ?? false;
      
      postNotifications.value = prefs.getBool('post_notifications') ?? true;
      commentNotifications.value = prefs.getBool('comment_notifications') ?? true;
      likeNotifications.value = prefs.getBool('like_notifications') ?? true;
      followNotifications.value = prefs.getBool('follow_notifications') ?? true;
      messageNotifications.value = prefs.getBool('message_notifications') ?? true;
      systemNotifications.value = prefs.getBool('system_notifications') ?? true;
    } catch (e) {
      print('Error loading notification settings: $e');
    }
  }

  // Save notification settings
  Future<void> saveSettings() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool('notifications_enabled', notificationsEnabled.value);
      await prefs.setBool('email_notifications', emailNotifications.value);
      await prefs.setBool('push_notifications', pushNotifications.value);
      await prefs.setBool('sound_enabled', soundEnabled.value);
      await prefs.setBool('vibration_enabled', vibrationEnabled.value);
      await prefs.setBool('show_on_lock_screen', showOnLockScreen.value);
      
      await prefs.setString('quiet_hours_start', startTime.value);
      await prefs.setString('quiet_hours_end', endTime.value);
      await prefs.setBool('quiet_hours_enabled', quietHoursEnabled.value);
      
      await prefs.setBool('post_notifications', postNotifications.value);
      await prefs.setBool('comment_notifications', commentNotifications.value);
      await prefs.setBool('like_notifications', likeNotifications.value);
      await prefs.setBool('follow_notifications', followNotifications.value);
      await prefs.setBool('message_notifications', messageNotifications.value);
      await prefs.setBool('system_notifications', systemNotifications.value);
      
      print('Notification settings saved successfully');
    } catch (e) {
      print('Error saving notification settings: $e');
    }
  }

  // Initialize local notifications
  Future<void> initializeNotifications() async {
    try {
      // TODO: Uncomment when flutter_local_notifications is added
      /*
      const AndroidInitializationSettings initializationSettingsAndroid = 
          AndroidInitializationSettings('@mipmap/ic_launcher');
          
      const DarwinInitializationSettings initializationSettingsIOS = 
          DarwinInitializationSettings(
            requestSoundPermission: true,
            requestBadgePermission: true,
            requestAlertPermission: true,
          );
          
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      
      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      */
      
      print('Local notifications initialized');
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  // Setup Firebase Cloud Messaging
  Future<void> setupFCM() async {
    try {
      // TODO: Uncomment when firebase_messaging is configured
      /*
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
        
        String? token = await _fcm.getToken();
        print('FCM Token: $token');
        
        // Save token to backend
        // await _saveTokenToBackend(token);
        
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
      }
      */
      
      print('FCM setup completed');
    } catch (e) {
      print('Error setting up FCM: $e');
    }
  }

  // Handle foreground messages
  void _handleForegroundMessage(dynamic message) {
    if (!notificationsEnabled.value) return;
    
    if (_isInQuietHours()) return;
    
    // Show local notification
    _showLocalNotification(
      title: message.notification?.title ?? 'إشعار جديد',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  // Handle notification tap
  void _handleMessageOpenedApp(dynamic message) {
    // Navigate to appropriate screen based on notification data
    _handleNotificationNavigation(message.data);
  }

  // Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      // TODO: Uncomment when flutter_local_notifications is added
      /*
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'student_portfolio_channel',
        'Student Portfolio Notifications',
        channelDescription: 'Notifications for Student Portfolio app',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        playSound: soundEnabled.value,
        enableVibration: vibrationEnabled.value,
        visibility: showOnLockScreen.value 
            ? NotificationVisibility.public 
            : NotificationVisibility.private,
      );
      
      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: soundEnabled.value,
      );
      
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );
      
      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );
      */
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  // Handle notification tap
  void _onNotificationTapped(dynamic response) {
    if (response?.payload != null) {
      // Parse payload and navigate
      _handleNotificationNavigation(response.payload);
    }
  }

  // Handle notification navigation
  void _handleNotificationNavigation(dynamic data) {
    try {
      // Parse notification data and navigate to appropriate screen
      if (data is String) {
        // Handle string payload
        print('Handling notification with payload: $data');
      } else if (data is Map) {
        // Handle map payload
        String? type = data['type'];
        String? id = data['id'];
        
        switch (type) {
          case 'post':
            Get.toNamed('/post-details', parameters: {'id': id ?? ''});
            break;
          case 'message':
            Get.toNamed('/chat', parameters: {'userId': id ?? ''});
            break;
          case 'follow':
            Get.toNamed('/profile', parameters: {'userId': id ?? ''});
            break;
          default:
            Get.toNamed('/notifications');
        }
      }
    } catch (e) {
      print('Error handling notification navigation: $e');
    }
  }

  // Check if current time is in quiet hours
  bool _isInQuietHours() {
    if (!quietHoursEnabled.value) return false;
    
    try {
      final now = TimeOfDay.now();
      final start = _parseTime(startTime.value);
      final end = _parseTime(endTime.value);
      
      final nowMinutes = now.hour * 60 + now.minute;
      final startMinutes = start.hour * 60 + start.minute;
      final endMinutes = end.hour * 60 + end.minute;
      
      if (startMinutes <= endMinutes) {
        // Same day range
        return nowMinutes < startMinutes || nowMinutes > endMinutes;
      } else {
        // Cross midnight range
        return nowMinutes < startMinutes && nowMinutes > endMinutes;
      }
    } catch (e) {
      print('Error checking quiet hours: $e');
      return false;
    }
  }

  // Parse time string to TimeOfDay
  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  // Show notification for specific type
  Future<void> showNotification({
    required String type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (!notificationsEnabled.value) return;
    
    // Check type-specific settings
    switch (type) {
      case 'post':
        if (!postNotifications.value) return;
        break;
      case 'comment':
        if (!commentNotifications.value) return;
        break;
      case 'like':
        if (!likeNotifications.value) return;
        break;
      case 'follow':
        if (!followNotifications.value) return;
        break;
      case 'message':
        if (!messageNotifications.value) return;
        break;
      case 'system':
        if (!systemNotifications.value) return;
        break;
    }
    
    if (_isInQuietHours()) return;
    
    await _showLocalNotification(
      title: title,
      body: body,
      payload: data?.toString(),
    );
  }

  // Schedule notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      // TODO: Implement scheduled notifications
      /*
      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'scheduled_channel',
            'Scheduled Notifications',
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      */
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  // Cancel notification
  Future<void> cancelNotification(int id) async {
    try {
      // await _localNotifications.cancel(id);
    } catch (e) {
      print('Error canceling notification: $e');
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      // await _localNotifications.cancelAll();
    } catch (e) {
      print('Error canceling all notifications: $e');
    }
  }

  // Test notification
  Future<void> testNotification() async {
    await showNotification(
      type: 'system',
      title: 'إشعار تجريبي',
      body: 'هذا إشعار تجريبي للتأكد من عمل النظام بشكل صحيح',
      data: {'type': 'test'},
    );
  }

  // Get notification permission status
  Future<bool> hasPermission() async {
    try {
      // TODO: Check actual permission status
      return true;
    } catch (e) {
      print('Error checking notification permission: $e');
      return false;
    }
  }

  // Request notification permission
  Future<bool> requestPermission() async {
    try {
      // TODO: Request actual permission
      return true;
    } catch (e) {
      print('Error requesting notification permission: $e');
      return false;
    }
  }

  // Enable/disable all notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    notificationsEnabled.value = enabled;
    if (!enabled) {
      await cancelAllNotifications();
    }
    await saveSettings();
  }
}