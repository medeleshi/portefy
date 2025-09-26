// controllers/follows_notifications_controller.dart
import 'package:get/get.dart';
import './base_notification_controller.dart';
import '../../../models/notification_model.dart';

class FollowsNotificationsController extends BaseNotificationController {
  @override
  NotificationType? get notificationType => NotificationType.follow;
}