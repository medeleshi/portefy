// controllers/all_notifications_controller.dart
import 'package:get/get.dart';
import './base_notification_controller.dart';
import '../../../models/notification_model.dart';

class AllNotificationsController extends BaseNotificationController {
  @override
  NotificationType? get notificationType => null; // null يعني جميع الأنواع
}