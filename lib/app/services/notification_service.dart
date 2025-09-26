import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:portefy/app/routes/app_routes.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';
import 'auth_service.dart';
import 'user_service.dart';
import 'local_notification_service.dart';

class NotificationService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final UserService _userService = UserService();
  final LocalNotificationService _localNotificationService = LocalNotificationService();
  
  // Collections
  String get notificationsCollection => 'notifications';

  // Realtime badge count stream
  final RxInt _globalUnreadCount = 0.obs;
  RxInt get globalUnreadCount => _globalUnreadCount;

  // للإشارة إذا كان المستخدم في شاشة الإشعارات
  final RxBool _isUserInNotificationsView = false.obs;



  @override
  void onInit() {
    super.onInit();
    _initializeFirebaseMessaging();
    _setupRealtimeBadgeCounter();
  }

  // تهيئة نظام realtime لعد الإشعارات غير المقروءة
  void _setupRealtimeBadgeCounter() {
    String? userId = Get.find<AuthService>().currentUserId;
    if (userId != null) {
      _firestore
          .collection(notificationsCollection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .snapshots()
          .listen((snapshot) {
        _globalUnreadCount.value = snapshot.docs.length;
        
        // إذا كان المستخدم في شاشة الإشعارات، نقوم بوضع علامة مقروء على الكل تلقائياً
        if (_isUserInNotificationsView.value && snapshot.docs.isNotEmpty) {
          _markAllAsReadAutomatically(userId);
        }
      });
    }
  }

  // وضع علامة مقروء تلقائياً عند دخول شاشة الإشعارات
  Future<void> _markAllAsReadAutomatically(String userId) async {
    try {
      QuerySnapshot unreadNotifications = await _firestore
          .collection(notificationsCollection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      WriteBatch batch = _firestore.batch();
      for (QueryDocumentSnapshot doc in unreadNotifications.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
      print('تم وضع علامة مقروء تلقائياً على جميع الإشعارات');
    } catch (e) {
      print('خطأ في الوضع التلقائي للإشعارات مقروءة: $e');
    }
  }

  // عند دخول المستخدم لشاشة الإشعارات
  void setUserInNotificationsView(bool isInView) {
    _isUserInNotificationsView.value = isInView;
    
    // إذا دخل المستخدم للشاشة وكان هناك إشعارات غير مقروءة، نضعها مقروءة
    if (isInView && _globalUnreadCount.value > 0) {
      String? userId = Get.find<AuthService>().currentUserId;
      if (userId != null) {
        _markAllAsReadAutomatically(userId);
      }
    }
  }



  // services/notification_service.dart
// إضافة الدوال الجديدة للـ pagination والتصفية

Future<List<NotificationModel>> getUserNotifications(
  String userId, {
  int limit = 20,
  DocumentSnapshot? lastDocument,
  NotificationType? type,
}) async {
  try {
    Query query = _firestore
        .collection(notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    if (type != null) {
      query = query.where('type', isEqualTo: type.toString().split('.').last);
    }

    QuerySnapshot querySnapshot = await query.get();

    return querySnapshot.docs
        .map((doc) => NotificationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  } catch (e) {
    throw 'فشل جلب الإشعارات: ${e.toString()}';
  }
}

// دالة مساعدة للحصول على query
Query getNotificationsQuery({
  required String userId,
  NotificationType? type,
  int? limit,
  DocumentSnapshot? startAfter,
}) {
  Query query = _firestore
      .collection(notificationsCollection)
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true);

  if (type != null) {
    query = query.where('type', isEqualTo: type.toString().split('.').last);
  }

  if (limit != null) {
    query = query.limit(limit);
  }

  if (startAfter != null) {
    query = query.startAfterDocument(startAfter);
  }

  return query;
}

// الحصول على عدد الإشعارات غير المقروءة حسب النوع
Future<int> getUnreadCount(String userId, {NotificationType? type}) async {
  try {
    Query query = _firestore
        .collection(notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false);

    if (type != null) {
      query = query.where('type', isEqualTo: type.toString().split('.').last);
    }

    QuerySnapshot querySnapshot = await query.get();
    return querySnapshot.docs.length;
  } catch (e) {
    return 0;
  }
}

  // Initialize Firebase Messaging
  Future<void> _initializeFirebaseMessaging() async {
    // تهيئة الإشعارات المحلية
    await _localNotificationService.initialize();
    
    // Request permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      
      // Get FCM token
      String? token = await _messaging.getToken();
      if (token != null) {
        await _saveTokenToDatabase(token);
      }
      
      // Listen for token refresh
      _messaging.onTokenRefresh.listen(_saveTokenToDatabase);
      
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // Handle background messages
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    }
  }

  // Save FCM token to user document
  Future<void> _saveTokenToDatabase(String token) async {
    try {
      String? userId = Get.find<AuthService>().currentUserId;
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmTokens': FieldValue.arrayUnion([token]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('خطأ في حفظ رمز FCM: $e');
    }
  }

  // Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Received foreground message: ${message.notification?.title}');
    
    // عرض إشعار محلي
    if (message.notification != null) {
      await _localNotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: message.notification!.title ?? 'إشعار جديد',
        body: message.notification!.body ?? '',
        payload: json.encode(message.data),
      );
    }
  }

  // Handle background messages
  void _handleBackgroundMessage(RemoteMessage message) {
    print('Opened app from background message: ${message.notification?.title}');
    
    if (message.data['type'] == 'post') {
      Get.toNamed(AppRoutes.POST_DETAILS, arguments: {'postId': message.data['postId']});
    }
  }

  // Create notification in Firestore
  Future<void> createNotification(NotificationModel notification) async {
    try {
      await _firestore.collection(notificationsCollection).add(notification.toMap());
    } catch (e) {
      throw 'فشل إنشاء الإشعار: ${e.toString()}';
    }
  }

  
  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection(notificationsCollection).doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'فشل تحديث الإشعار: ${e.toString()}';
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      QuerySnapshot unreadNotifications = await _firestore
          .collection(notificationsCollection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      WriteBatch batch = _firestore.batch();
      for (QueryDocumentSnapshot doc in unreadNotifications.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
    } catch (e) {
      throw 'فشل تحديث جميع الإشعارات: ${e.toString()}';
    }
  }

  

  // Get notifications stream
  Stream<List<NotificationModel>> getUserNotificationsStream(String userId, {NotificationType type = NotificationType.newPost}) {
    return _firestore
        .collection(notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Send new post notification
  Future<void> sendNewPostNotification({
    required String postId,
    required String userId,
    required String authorName,
  }) async {
    try {
      NotificationModel notification = NotificationModel(
        id: '',
        userId: userId,
        type: NotificationType.newPost,
        title: 'منشور جديد',
        body: 'نشر $authorName منشوراً جديداً',
        postId: postId,
        createdAt: DateTime.now(),
      );

      await createNotification(notification);
      await _sendPushNotification(userId, notification.title, notification.body, {
        'type': 'post',
        'postId': postId,
      });
    } catch (e) {
      print('خطأ في إرسال إشعار المنشور الجديد: $e');
    }
  }

  // Send post like notification
  Future<void> sendPostLikeNotification({
    required String postId,
    required String postAuthorId,
    required String likerId,
  }) async {
    try {
      UserModel? liker = await _userService.getUserData(likerId);
      if (liker == null) return;

      NotificationModel notification = NotificationModel(
        id: '',
        userId: postAuthorId,
        senderId: likerId,
        senderName: liker.fullName,
        senderAvatar: liker.photoURL,
        type: NotificationType.postLike,
        title: 'إعجاب جديد',
        body: 'أعجب ${liker.fullName} بمنشورك',
        postId: postId,
        createdAt: DateTime.now(),
      );

      await createNotification(notification);
      await _sendPushNotification(postAuthorId, notification.title, notification.body, {
        'type': 'post',
        'postId': postId,
      });
    } catch (e) {
      print('خطأ في إرسال إشعار الإعجاب: $e');
    }
  }

  // Send post comment notification
  Future<void> sendPostCommentNotification({
    required String postId,
    required String postAuthorId,
    required String commenterId,
  }) async {
    try {
      UserModel? commenter = await _userService.getUserData(commenterId);
      if (commenter == null) return;

      NotificationModel notification = NotificationModel(
        id: '',
        userId: postAuthorId,
        senderId: commenterId,
        senderName: commenter.fullName,
        senderAvatar: commenter.photoURL,
        type: NotificationType.postComment,
        title: 'تعليق جديد',
        body: 'علق ${commenter.fullName} على منشورك',
        postId: postId,
        createdAt: DateTime.now(),
      );

      await createNotification(notification);
      await _sendPushNotification(postAuthorId, notification.title, notification.body, {
        'type': 'post',
        'postId': postId,
      });
    } catch (e) {
      print('خطأ في إرسال إشعار التعليق: $e');
    }
  }

  // Send comment like notification
  Future<void> sendCommentLikeNotification({
    required String commentId,
    required String commentAuthorId,
    required String likerId,
  }) async {
    try {
      UserModel? liker = await _userService.getUserData(likerId);
      if (liker == null) return;

      NotificationModel notification = NotificationModel(
        id: '',
        userId: commentAuthorId,
        senderId: likerId,
        senderName: liker.fullName,
        senderAvatar: liker.photoURL,
        type: NotificationType.commentLike,
        title: 'إعجاب بالتعليق',
        body: 'أعجب ${liker.fullName} بتعليقك',
        commentId: commentId,
        createdAt: DateTime.now(),
      );

      await createNotification(notification);
      await _sendPushNotification(commentAuthorId, notification.title, notification.body, {
        'type': 'comment',
        'commentId': commentId,
      });
    } catch (e) {
      print('خطأ في إرسال إشعار الإعجاب بالتعليق: $e');
    }
  }

  // Send comment reply notification
  Future<void> sendCommentReplyNotification({
    required String commentId,
    required String commentAuthorId,
    required String replierId,
  }) async {
    try {
      UserModel? replier = await _userService.getUserData(replierId);
      if (replier == null) return;

      NotificationModel notification = NotificationModel(
        id: '',
        userId: commentAuthorId,
        senderId: replierId,
        senderName: replier.fullName,
        senderAvatar: replier.photoURL,
        type: NotificationType.commentReply,
        title: 'رد جديد',
        body: 'رد ${replier.fullName} على تعليقك',
        commentId: commentId,
        createdAt: DateTime.now(),
      );

      await createNotification(notification);
      await _sendPushNotification(commentAuthorId, notification.title, notification.body, {
        'type': 'comment',
        'commentId': commentId,
      });
    } catch (e) {
      print('خطأ في إرسال إشعار الرد: $e');
    }
  }

  // Send push notification via FCM
  Future<void> _sendPushNotification(String userId, String title, String body, Map<String, dynamic> data) async {
    try {
      // Get user's FCM tokens
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        List<dynamic> fcmTokens = (userDoc.data() as Map<String, dynamic>)['fcmTokens'] ?? [];
        
        if (fcmTokens.isNotEmpty) {
          // في تطبيق حقيقي، ستقوم هنا بإرسال الإشعار إلى الخادم
          // الذي سيتكفل بإرسال الإشعارات إلى FCM
          print('Sending push notification to user: $userId');
          print('Title: $title, Body: $body');
          print('Data: $data');
          
          // عرض إشعار محلي لأغراض الاختبار
          await _localNotificationService.showNotification(
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            title: title,
            body: body,
            channelId: 'important_channel',
            payload: json.encode(data),
          );
        }
      }
    } catch (e) {
      print('خطأ في إرسال الإشعار المباشر: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection(notificationsCollection).doc(notificationId).delete();
    } catch (e) {
      throw 'فشل حذف الإشعار: ${e.toString()}';
    }
  }

  // Delete all notifications for user
  Future<void> deleteAllNotifications(String userId) async {
    try {
      QuerySnapshot notifications = await _firestore
          .collection(notificationsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      WriteBatch batch = _firestore.batch();
      for (QueryDocumentSnapshot doc in notifications.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      throw 'فشل حذف جميع الإشعارات: ${e.toString()}';
    }
  }

  // Schedule a local notification
  Future<void> scheduleLocalNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? channelId,
    String? payload,
  }) async {
    await _localNotificationService.scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      channelId: channelId,
      payload: payload,
    );
  }

  // Cancel a local notification
  Future<void> cancelLocalNotification(int id) async {
    await _localNotificationService.cancelNotification(id);
  }

  // Cancel all local notifications
  Future<void> cancelAllLocalNotifications() async {
    await _localNotificationService.cancelAllNotifications();
  }
}