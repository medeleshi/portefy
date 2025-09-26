// controllers/posts_notifications_controller.dart
import 'package:get/get.dart';
import './base_notification_controller.dart';
import '../../../models/notification_model.dart';

class PostsNotificationsController extends BaseNotificationController {
  @override
  NotificationType? get notificationType => NotificationType.newPost;
}