// controllers/notifications_controller.dart
import 'package:get/get.dart';
import './base_notification_controller.dart';
import './all_notifications_controller.dart';
import './posts_notifications_controller.dart';
import './comments_notifications_controller.dart';
import './likes_notifications_controller.dart';
import './follows_notifications_controller.dart';

class NotificationsController extends GetxController {
  final RxInt currentTabIndex = 0.obs;

  final List<BaseNotificationController> tabControllers = [
    AllNotificationsController(),
    PostsNotificationsController(),
    CommentsNotificationsController(),
    LikesNotificationsController(),
    // FollowsNotificationsController(),
  ];

  final List<String> tabTitles = [
    'الكل',
    'المنشورات',
    'التعليقات',
    'الإعجابات',
    // 'المتابعة',
  ];

  @override
  void onInit() {
    super.onInit();
    // تهيئة جميع الكونترولرز
    for (var controller in tabControllers) {
      Get.put(controller, tag: controller.runtimeType.toString());
    }
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  // وضع علامة مقروء على الكل في جميع التبويبات
  Future<void> markAllAsRead() async {
    for (var controller in tabControllers) {
      await controller.refreshNotifications();
    }
  }

  // حذف الكل في جميع التبويبات
  Future<void> deleteAllNotifications() async {
    try {
      // تنفيذ الحذف من الخدمة
      // ثم تحديث جميع التبويبات
      for (var controller in tabControllers) {
        await controller.refreshNotifications();
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل حذف جميع الإشعارات');
    }
  }

  BaseNotificationController get currentController =>
      tabControllers[currentTabIndex.value];
}
