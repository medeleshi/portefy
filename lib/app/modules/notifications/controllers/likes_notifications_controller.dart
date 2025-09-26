// controllers/likes_notifications_controller.dart
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../services/notification_service.dart';
import './base_notification_controller.dart';
import '../../../models/notification_model.dart';

class LikesNotificationsController extends BaseNotificationController {
  @override
  NotificationType? get notificationType {
    return null; // سيعود null وسنقوم بالتصفية يدوياً
  }

  @override
  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      String? userId = Get.find<AuthService>().currentUserId;
      if (userId == null) return;

      List<NotificationModel> allNotifications = 
          await Get.find<NotificationService>().getUserNotifications(userId);

      // تصفية الإعجابات فقط
      List<NotificationModel> likeNotifications = allNotifications.where((notification) {
        return notification.type == NotificationType.postLike ||
               notification.type == NotificationType.commentLike;
      }).toList();

      notifications.assignAll(likeNotifications);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحميل الإشعارات: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}