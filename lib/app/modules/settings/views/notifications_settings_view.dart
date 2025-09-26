// Additional Settings Pages (Specialized Views)
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/notification_settings_service.dart';
import '../../../theme/app_theme.dart';
import '../controllers/settings_controller.dart';

class NotificationsSettingsView extends GetView<SettingsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('إعدادات الإشعارات'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => NotificationSettingsService.instance.testNotification(),
            child: Text('اختبار'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // General Notifications
            _buildNotificationSection(
              title: 'الإشعارات العامة',
              icon: Icons.notifications_outlined,
              children: [
                Obx(() => SwitchListTile(
                  title: Text('تفعيل الإشعارات'),
                  subtitle: Text('تفعيل أو إلغاء جميع الإشعارات'),
                  value: controller.notificationsEnabled.value,
                  onChanged: (value) {
                    controller.notificationsEnabled.value = value;
                    controller.updateNotificationSettings();
                  },
                )),
                Obx(() => SwitchListTile(
                  title: Text('الصوت'),
                  subtitle: Text('تشغيل صوت مع الإشعارات'),
                  value: controller.soundEnabled.value,
                  onChanged: controller.notificationsEnabled.value
                      ? (value) {
                          controller.soundEnabled.value = value;
                          controller.updateNotificationSettings();
                        }
                      : null,
                )),
              ],
            ),

            SizedBox(height: 16),

            // Push Notifications
            _buildNotificationSection(
              title: 'الإشعارات المباشرة',
              icon: Icons.push_pin_outlined,
              children: [
                Obx(() => SwitchListTile(
                  title: Text('إشعارات المنشورات'),
                  subtitle: Text('عند نشر محتوى جديد'),
                  value: controller.pushNotifications.value,
                  onChanged: controller.notificationsEnabled.value
                      ? (value) {
                          controller.pushNotifications.value = value;
                          controller.updateNotificationSettings();
                        }
                      : null,
                )),
              ],
            ),

            SizedBox(height: 16),

            // Email Notifications
            _buildNotificationSection(
              title: 'إشعارات البريد الإلكتروني',
              icon: Icons.email_outlined,
              children: [
                Obx(() => SwitchListTile(
                  title: Text('إشعارات البريد'),
                  subtitle: Text('استقبال إشعارات عبر البريد الإلكتروني'),
                  value: controller.emailNotifications.value,
                  onChanged: controller.notificationsEnabled.value
                      ? (value) {
                          controller.emailNotifications.value = value;
                          controller.updateNotificationSettings();
                        }
                      : null,
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
