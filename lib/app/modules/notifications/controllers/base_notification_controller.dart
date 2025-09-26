// controllers/base_notification_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/notification_model.dart';
import '../../../services/notification_service.dart';
import '../../../services/auth_service.dart';

abstract class BaseNotificationController extends GetxController {
  final NotificationService _notificationService = Get.find<NotificationService>();
  final AuthService _authService = Get.find<AuthService>();

  // Observables لكل تبويب
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadMore = false.obs;
  final RxInt unreadCount = 0.obs;
  final RxBool hasMoreData = true.obs;
  
  DocumentSnapshot? _lastDocument;
  final int _pageSize = 15;

  // يجب تنفيذ هذه الدالة في كل تبويب
  NotificationType? get notificationType;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    _setupRealtimeListener();
  }

  // إعداد مستمع realtime للإشعارات
  void _setupRealtimeListener() {
    String? userId = _authService.currentUserId;
    if (userId != null) {
      _notificationService.getUserNotificationsStream(userId)
          .listen((List<NotificationModel> realtimeNotifications) {
        // تحديث القائمة مع الحفاظ على حالة Pagination
        _updateNotificationsList(realtimeNotifications);
      });
    }
  }

  // تحديث القائمة مع الحفاظ على الـ Pagination
  void _updateNotificationsList(List<NotificationModel> newNotifications) {
    // هنا يمكنك إضافة منطق لدمج الإشعارات الجديدة مع القائمة الحالية
    // حسب احتياجك (إما استبدال كامل أو إضافة الجديد فقط)
    notifications.assignAll(newNotifications);
    
    // تحديث عدد الإشعارات غير المقروءة
    _updateUnreadCount();
  }

  // تحديث عدد الإشعارات غير المقروءة
  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }


  // تحميل الإشعارات مع pagination
  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      String? userId = _authService.currentUserId;
      if (userId == null) return;

      List<NotificationModel> loadedNotifications = 
          await _notificationService.getUserNotifications(
        userId, 
        limit: _pageSize,
        lastDocument: null,
        type: notificationType,
      );

      notifications.assignAll(loadedNotifications);
      _lastDocument = await _getLastDocument();
      hasMoreData.value = loadedNotifications.length == _pageSize;
      _updateUnreadCount();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحميل الإشعارات: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // تحميل المزيد من الإشعارات
  Future<void> loadMoreNotifications() async {
    if (isLoadMore.value || !hasMoreData.value) return;

    try {
      isLoadMore.value = true;
      String? userId = _authService.currentUserId;
      if (userId == null) return;

      List<NotificationModel> loadedNotifications = 
          await _notificationService.getUserNotifications(
        userId, 
        limit: _pageSize,
        lastDocument: _lastDocument,
        type: notificationType,
      );

      if (loadedNotifications.isNotEmpty) {
        notifications.addAll(loadedNotifications);
        _lastDocument = await _getLastDocument();
        hasMoreData.value = loadedNotifications.length == _pageSize;
      } else {
        hasMoreData.value = false;
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحميل المزيد من الإشعارات');
    } finally {
      isLoadMore.value = false;
    }
  }

  // تحديث الإشعارات
  Future<void> refreshNotifications() async {
    _lastDocument = null;
    hasMoreData.value = true;
    await loadNotifications();
    await loadUnreadCount();
  }

  // تحميل عدد الإشعارات غير المقروءة
  Future<void> loadUnreadCount() async {
    try {
      String? userId = _authService.currentUserId;
      if (userId == null) return;

      int count = await _notificationService.getUnreadCount(
        userId, 
        type: notificationType
      );
      unreadCount.value = count;
    } catch (e) {
      print('خطأ في تحميل عدد الإشعارات غير المقروءة: $e');
    }
  }

  // وضع علامة مقروء على إشعار
  Future<void> markAsRead(NotificationModel notification, int index) async {
    if (notification.isRead) return;

    try {
      await _notificationService.markAsRead(notification.id);
      notifications[index] = notification.copyWith(isRead: true);
      unreadCount.value = (unreadCount.value - 1).clamp(0, double.infinity).toInt();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحديث الإشعار');
    }
  }

  // حذف إشعار
  Future<void> deleteNotification(String notificationId, int index) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      NotificationModel deletedNotification = notifications[index];
      notifications.removeAt(index);
      
      if (!deletedNotification.isRead) {
        unreadCount.value = (unreadCount.value - 1).clamp(0, double.infinity).toInt();
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل حذف الإشعار');
    }
  }

  // الحصول على آخر وثيقة للـ pagination
  Future<DocumentSnapshot?> _getLastDocument() async {
    if (notifications.isEmpty) return null;
    
    try {
      String? userId = _authService.currentUserId;
      if (userId == null) return null;

      final query = _notificationService.getNotificationsQuery(
        userId: userId,
        type: notificationType,
        limit: 1,
        startAfter: null,
      );

      final snapshot = await query.get();
      return snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    } catch (e) {
      return null;
    }
  }

  // تجميع الإشعارات حسب التاريخ
  Map<String, List<NotificationModel>> get groupedNotifications {
    Map<String, List<NotificationModel>> grouped = {};
    
    for (NotificationModel notification in notifications) {
      String dateKey = _getDateKey(notification.createdAt);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(notification);
    }
    
    return grouped;
  }

  String _getDateKey(DateTime date) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime notificationDate = DateTime(date.year, date.month, date.day);
    
    if (notificationDate == today) {
      return 'اليوم';
    } else if (notificationDate == today.subtract(Duration(days: 1))) {
      return 'أمس';
    } else if (now.difference(notificationDate).inDays < 7) {
      return 'هذا الأسبوع';
    } else if (now.difference(notificationDate).inDays < 30) {
      return 'هذا الشهر';
    } else {
      return 'أقدم';
    }
  }
}