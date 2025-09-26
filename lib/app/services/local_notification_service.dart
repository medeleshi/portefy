import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 🔹 دالة خاصة بالـ background لازم تكون Top-level
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  if (response.payload != null) {
    try {
      final data = json.decode(response.payload!);
      if (data['type'] == 'post' && data['postId'] != null) {
        Get.toNamed('/post-details', arguments: {'postId': data['postId']});
      } else if (data['type'] == 'profile' && data['userId'] != null) {
        Get.toNamed('/profile', arguments: {'userId': data['userId']});
      }
    } catch (e) {
      print("خطأ في معالجة payload بالخلفية: $e");
    }
  }
}

class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          _handleNotificationPayload(response.payload!);
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    await _createNotificationChannels();
  }

  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel generalChannel =
        AndroidNotificationChannel(
      'general_channel',
      'الإشعارات العامة',
      description: 'قناة للإشعارات العامة',
      importance: Importance.defaultImportance,
    );

    const AndroidNotificationChannel importantChannel =
        AndroidNotificationChannel(
      'important_channel',
      'الإشعارات المهمة',
      description: 'قناة للإشعارات المهمة',
      importance: Importance.high,
    );

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(generalChannel);
      await androidPlugin.createNotificationChannel(importantChannel);
    }
  }

  void _handleNotificationPayload(String payload) {
    try {
      final data = json.decode(payload);

      if (data['type'] == 'post' && data['postId'] != null) {
        Get.toNamed('/post-details', arguments: {'postId': data['postId']});
      } else if (data['type'] == 'profile' && data['userId'] != null) {
        Get.toNamed('/profile', arguments: {'userId': data['userId']});
      }
    } catch (e) {
      print('خطأ في معالجة payload: $e');
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? channelId,
    String? payload,
    String? imageUrl,
  }) async {
    final String effectiveChannelId = channelId ?? 'general_channel';
    final String channelName = effectiveChannelId == 'important_channel'
        ? 'الإشعارات المهمة'
        : 'الإشعارات العامة';
    final String channelDescription = effectiveChannelId == 'important_channel'
        ? 'قناة للإشعارات المهمة'
        : 'قناة للإشعارات العامة';
    final Importance importance = effectiveChannelId == 'important_channel'
        ? Importance.high
        : Importance.defaultImportance;
    final Priority priority = effectiveChannelId == 'important_channel'
        ? Priority.high
        : Priority.defaultPriority;

    BigPictureStyleInformation? bigPictureStyleInformation;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      bigPictureStyleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(imageUrl),
        largeIcon: FilePathAndroidBitmap(imageUrl),
        contentTitle: title,
        htmlFormatContentTitle: true,
        summaryText: body,
        htmlFormatSummaryText: true,
      );
    }

    final NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        effectiveChannelId,
        channelName,
        channelDescription: channelDescription,
        importance: importance,
        priority: priority,
        color: Colors.blue,
        playSound: true,
        styleInformation:
            bigPictureStyleInformation ?? DefaultStyleInformation(true, true),
      ),
      iOS: const DarwinNotificationDetails(
        sound: 'default.wav',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? channelId,
    String? payload,
  }) async {
    final String effectiveChannelId = channelId ?? 'general_channel';
    final String channelName = effectiveChannelId == 'important_channel'
        ? 'الإشعارات المهمة'
        : 'الإشعارات العامة';
    final String channelDescription = effectiveChannelId == 'important_channel'
        ? 'قناة للإشعارات المهمة'
        : 'قناة للإشعارات العامة';

    final NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        effectiveChannelId,
        channelName,
        channelDescription: channelDescription,
      ),
      iOS: const DarwinNotificationDetails(
        sound: 'default.wav',
      ),
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> periodicallyShowNotification({
    required int id,
    required String title,
    required String body,
    required RepeatInterval repeatInterval,
    String? channelId,
    String? payload,
  }) async {
    final String effectiveChannelId = channelId ?? 'general_channel';
    final String channelName = effectiveChannelId == 'important_channel'
        ? 'الإشعارات المهمة'
        : 'الإشعارات العامة';
    final String channelDescription = effectiveChannelId == 'important_channel'
        ? 'قناة للإشعارات المهمة'
        : 'قناة للإشعارات العامة';

    final NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        effectiveChannelId,
        channelName,
        channelDescription: channelDescription,
      ),
      iOS: const DarwinNotificationDetails(
        sound: 'default.wav',
      ),
    );

    await _notificationsPlugin.periodicallyShow(
      id,
      title,
      body,
      repeatInterval,
      notificationDetails,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
    );
  }

  Future<void> showBigPictureNotification({
    required int id,
    required String title,
    required String body,
    required String imagePath,
    String? channelId,
    String? payload,
  }) async {
    final String effectiveChannelId = channelId ?? 'important_channel';

    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
      FilePathAndroidBitmap(imagePath),
      largeIcon: FilePathAndroidBitmap(imagePath),
      contentTitle: title,
      htmlFormatContentTitle: true,
      summaryText: body,
      htmlFormatSummaryText: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        effectiveChannelId,
        'الإشعارات المصورة',
        channelDescription: 'قناة للإشعارات التي تحتوي على صور',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: bigPictureStyleInformation,
      ),
      iOS: const DarwinNotificationDetails(
        sound: 'default.wav',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> showProgressNotification({
    required int id,
    required String title,
    required String body,
    required int progress,
    required int maxProgress,
    String? channelId,
    String? payload,
  }) async {
    final String effectiveChannelId = channelId ?? 'general_channel';

    final NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        effectiveChannelId,
        'إشعارات التقدم',
        channelDescription: 'قناة لإشعارات التقدم',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        showProgress: true,
        maxProgress: maxProgress,
        progress: progress,
        onlyAlertOnce: true,
      ),
      iOS: const DarwinNotificationDetails(
        sound: 'default.wav',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> updateProgressNotification({
    required int id,
    required String title,
    required String body,
    required int progress,
    required int maxProgress,
    String? channelId,
    String? payload,
  }) async {
    final String effectiveChannelId = channelId ?? 'general_channel';

    final NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        effectiveChannelId,
        'إشعارات التقدم',
        channelDescription: 'قناة لإشعارات التقدم',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        showProgress: true,
        maxProgress: maxProgress,
        progress: progress,
        onlyAlertOnce: true,
      ),
      iOS: const DarwinNotificationDetails(
        sound: 'default.wav',
      ),
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<bool> getNotificationPermissionStatus() async {
    final settings = await _notificationsPlugin.getNotificationAppLaunchDetails();
    return settings?.didNotificationLaunchApp ?? false;
  }

  Future<void> requestIOSPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> requestAndroidPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
  }
}
