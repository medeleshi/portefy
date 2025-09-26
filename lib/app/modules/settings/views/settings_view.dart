import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portefy/app/modules/auth/controllers/auth_controller.dart';
import 'package:portefy/app/modules/settings/widgets/copyright_widget.dart';
import 'package:portefy/app/routes/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('الإعدادات'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(),

            SizedBox(height: 20),

            // Settings Sections
            _buildAccountSection(),
            _buildNotificationsSection(),
            _buildPrivacySection(),
            _buildAppSection(),
            _buildDataSection(),
            _buildSupportSection(),
            _buildDangerZoneSection(),

            SizedBox(height: 40),
            CopyRightWidget(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        UserModel? user = Get.find<AuthService>().appUser.value;
        if (user == null) return SizedBox.shrink();

        return Row(
          children: [
            Stack(
              children: [
                Obx(
                  () => CircleAvatar(
                    radius: 35,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage:
                        controller.selectedProfileImage.value != null
                        ? FileImage(controller.selectedProfileImage.value!)
                        : (user.photoURL != null
                              ? NetworkImage(user.photoURL!)
                              : null),
                    child:
                        (controller.selectedProfileImage.value == null &&
                            user.photoURL == null)
                        ? Icon(Icons.person, size: 35, color: AppColors.primary)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _showImagePicker(),
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (user.university != null) ...[
                    SizedBox(height: 4),
                    Text(
                      user.university!,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                  if (user.major != null) ...[
                    SizedBox(height: 2),
                    Text(
                      user.major!,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  SizedBox(height: 8),
                  Row(
                    children: [
                      // Icon(Icons.star, color: Colors.amber, size: 16),
                      // SizedBox(width: 4),
                      // Text(
                      //   '${user.points ?? 0} نقطة',
                      //   style: TextStyle(
                      //     color: AppColors.primary,
                      //     fontWeight: FontWeight.w500,
                      //   ),
                      // ),
                      // Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: user.isProfileComplete == true
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          user.isProfileComplete == true
                              ? 'مكتمل'
                              : 'غير مكتمل',
                          style: TextStyle(
                            color: user.isProfileComplete == true
                                ? Colors.green
                                : Colors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: () => Get.toNamed(AppRoutes.EDIT_PROFILE),
              icon: Icon(Icons.edit, color: AppColors.primary),
              tooltip: 'تعديل الملف الشخصي',
            ),
          ],
        );
      }),
    );
  }

  Widget _buildAccountSection() {
    return _buildSection(
      title: 'الحساب',
      icon: Icons.person_outline,
      children: [
        _buildSettingsTile(
          icon: Icons.person_outline,
          title: 'تعديل الملف الشخصي',
          subtitle: 'تحديث معلوماتك الشخصية',
          onTap: () => Get.toNamed('/edit-profile'),
        ),
        _buildSettingsTile(
          icon: Icons.lock_outline,
          title: 'تغيير كلمة المرور',
          subtitle: 'تحديث كلمة المرور الخاصة بك',
          onTap: () => _showChangePasswordDialog(),
        ),
        _buildSettingsTile(
          icon: Icons.email_outlined,
          title: 'تغيير البريد الإلكتروني',
          subtitle: 'تحديث عنوان البريد الإلكتروني',
          onTap: () => _showChangeEmailDialog(),
        ),
        _buildSettingsTile(
          icon: Icons.verified_outlined,
          title: 'تحقق من الهوية',
          subtitle: 'تأكيد حسابك',
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () =>
              Get.snackbar('قريباً', 'التحقق من الهوية سيكون متاح قريباً'),
        ),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    return _buildSection(
      title: 'الإشعارات',
      icon: Icons.notifications_outlined,
      children: [
        Obx(
          () => _buildSwitchTile(
            icon: Icons.notifications_outlined,
            title: 'الإشعارات العامة',
            subtitle: 'تفعيل أو إلغاء جميع الإشعارات',
            value: controller.notificationsEnabled.value,
            onChanged: (value) {
              controller.notificationsEnabled.value = value;
              // If disabled, disable all other notifications
              if (!value) {
                controller.emailNotifications.value = false;
                controller.pushNotifications.value = false;
                controller.soundEnabled.value = false;
              }
              controller.updateNotificationSettings();
            },
          ),
        ),
        Obx(
          () => _buildSwitchTile(
            icon: Icons.email_outlined,
            title: 'إشعارات البريد الإلكتروني',
            subtitle: 'استقبال الإشعارات عبر البريد',
            value: controller.emailNotifications.value,
            enabled: controller.notificationsEnabled.value,
            onChanged: (value) {
              controller.emailNotifications.value = value;
              controller.updateNotificationSettings();
            },
          ),
        ),
        Obx(
          () => _buildSwitchTile(
            icon: Icons.push_pin_outlined,
            title: 'الإشعارات المباشرة',
            subtitle: 'إشعارات فورية على الجهاز',
            value: controller.pushNotifications.value,
            enabled: controller.notificationsEnabled.value,
            onChanged: (value) {
              controller.pushNotifications.value = value;
              controller.updateNotificationSettings();
            },
          ),
        ),
        Obx(
          () => _buildSwitchTile(
            icon: Icons.volume_up_outlined,
            title: 'أصوات الإشعارات',
            subtitle: 'تشغيل أصوات مع الإشعارات',
            value: controller.soundEnabled.value,
            enabled: controller.notificationsEnabled.value,
            onChanged: (value) {
              controller.soundEnabled.value = value;
              controller.updateNotificationSettings();
            },
          ),
        ),
        _buildSettingsTile(
          icon: Icons.schedule,
          title: 'أوقات الإشعارات',
          subtitle: 'تحديد أوقات استقبال الإشعارات',
          trailing: Text(
            '9 ص - 9 م',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          onTap: () => Get.snackbar(
            'قريباً',
            'إعدادات أوقات الإشعارات ستكون متاحة قريباً',
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return _buildSection(
      title: 'الخصوصية والأمان',
      icon: Icons.privacy_tip_outlined,
      children: [
        Obx(
          () => _buildSwitchTile(
            icon: Icons.public,
            title: 'ملف عام',
            subtitle: 'جعل ملفك الشخصي مرئي للآخرين',
            value: controller.profilePublic.value,
            onChanged: (value) {
              controller.profilePublic.value = value;
              controller.updatePrivacySettings();
            },
          ),
        ),
        Obx(
          () => _buildSwitchTile(
            icon: Icons.email_outlined,
            title: 'إظهار البريد الإلكتروني',
            subtitle: 'عرض بريدك في الملف الشخصي',
            value: controller.showEmail.value,
            enabled: controller.profilePublic.value,
            onChanged: (value) {
              controller.showEmail.value = value;
              controller.updatePrivacySettings();
            },
          ),
        ),
        Obx(
          () => _buildSwitchTile(
            icon: Icons.phone_outlined,
            title: 'إظهار رقم الهاتف',
            subtitle: 'عرض هاتفك في الملف الشخصي',
            value: controller.showPhone.value,
            enabled: controller.profilePublic.value,
            onChanged: (value) {
              controller.showPhone.value = value;
              controller.updatePrivacySettings();
            },
          ),
        ),
        Obx(
          () => _buildSwitchTile(
            icon: Icons.message_outlined,
            title: 'السماح بالرسائل',
            subtitle: 'استقبال رسائل من المستخدمين',
            value: controller.allowMessages.value,
            onChanged: (value) {
              controller.allowMessages.value = value;
              controller.updatePrivacySettings();
            },
          ),
        ),
        _buildSettingsTile(
          icon: Icons.block,
          title: 'قائمة المحظورين',
          subtitle: 'إدارة المستخدمين المحظورين',
          onTap: () =>
              Get.snackbar('قريباً', 'قائمة المحظورين ستكون متاحة قريباً'),
        ),
        _buildSettingsTile(
          icon: Icons.history,
          title: 'سجل النشاط',
          subtitle: 'عرض تاريخ أنشطتك',
          onTap: () => Get.snackbar('قريباً', 'سجل النشاط سيكون متاح قريباً'),
        ),
      ],
    );
  }

  Widget _buildAppSection() {
    return _buildSection(
      title: 'إعدادات التطبيق',
      icon: Icons.settings_outlined,
      children: [
        _buildSettingsTile(
          icon: Icons.language_outlined,
          title: 'اللغة',
          subtitle: controller.selectedLanguage.value,
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => controller.showLanguageDialog(),
        ),
        _buildSettingsTile(
          icon: Icons.dark_mode_outlined,
          title: 'المظهر',
          subtitle: controller.currentThemeName,
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => controller.showThemeDialog(),
        ),
        Obx(
          () => _buildSwitchTile(
            icon: Icons.auto_mode,
            title: 'النسخ الاحتياطي التلقائي',
            subtitle: 'نسخ البيانات تلقائياً',
            value: controller.autoBackupEnabled.value,
            onChanged: (value) {
              controller.autoBackupEnabled.value = value;
              controller.updateAppSettings();
            },
          ),
        ),
        Obx(
          () => _buildSwitchTile(
            icon: Icons.analytics_outlined,
            title: 'الإحصائيات والتحليلات',
            subtitle: 'مساعدة في تحسين التطبيق',
            value: controller.analyticsEnabled.value,
            onChanged: (value) {
              controller.analyticsEnabled.value = value;
              controller.updateAppSettings();
            },
          ),
        ),
        _buildSettingsTile(
          icon: Icons.font_download_outlined,
          title: 'حجم الخط',
          subtitle: 'متوسط',
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () =>
              Get.snackbar('قريباً', 'إعدادات حجم الخط ستكون متاحة قريباً'),
        ),
      ],
    );
  }

  Widget _buildDataSection() {
    return _buildSection(
      title: 'البيانات والتخزين',
      icon: Icons.storage_outlined,
      children: [
        Obx(
          () => _buildSettingsTile(
            icon: Icons.storage_outlined,
            title: 'ذاكرة التخزين المؤقت',
            subtitle: 'الحجم: ${controller.cacheSize.value}',
            trailing: TextButton(
              onPressed: controller.clearCache,
              child: Text('مسح'),
            ),
            onTap: controller.clearCache,
          ),
        ),
        Obx(
          () => _buildSettingsTile(
            icon: Icons.backup_outlined,
            title: 'النسخ الاحتياطي',
            subtitle: 'نسخ بياناتك إلى السحابة',
            trailing: controller.isLoading.value
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            onTap: controller.backupData,
          ),
        ),
        Obx(
          () => _buildSettingsTile(
            icon: Icons.file_download_outlined,
            title: 'تصدير البيانات',
            subtitle: 'تحميل نسخة من بياناتك',
            trailing: controller.isLoading.value
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            onTap: controller.exportData,
          ),
        ),
        _buildSettingsTile(
          icon: Icons.restore,
          title: 'استرجاع البيانات',
          subtitle: 'استعادة نسخة احتياطية',
          onTap: () =>
              Get.snackbar('قريباً', 'استرجاع البيانات سيكون متاح قريباً'),
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return _buildSection(
      title: 'المساعدة والدعم',
      icon: Icons.help_outline,
      children: [
        _buildSettingsTile(
          icon: Icons.help_outline,
          title: 'الأسئلة الشائعة',
          subtitle: 'إجابات للأسئلة المتكررة',
          onTap: () => Get.toNamed(AppRoutes.FAQ),
        ),
        _buildSettingsTile(
          icon: Icons.support_agent_outlined,
          title: 'تواصل معنا',
          subtitle: 'احصل على المساعدة',
          onTap: () => Get.toNamed(AppRoutes.CONTACT_SUPPORT),
        ),
        _buildSettingsTile(
          icon: Icons.bug_report_outlined,
          title: 'الإبلاغ عن مشكلة',
          subtitle: 'أرسل تقرير عن خطأ أو مشكلة',
          onTap: () => Get.toNamed(AppRoutes.CONTACT_SUPPORT),
        ),
        _buildSettingsTile(
          icon: Icons.star_outline,
          title: 'قيم التطبيق',
          subtitle: 'ساعدنا في تحسين التطبيق',
          onTap: () =>
              Get.snackbar('شكراً', 'شكراً لك على اهتمامك بتقييم التطبيق'),
        ),
        _buildSettingsTile(
          icon: Icons.info_outline,
          title: 'حول التطبيق',
          subtitle: 'معلومات عن التطبيق والإصدار',
          onTap: () => Get.toNamed(AppRoutes.ABOUT),
        ),
        _buildSettingsTile(
          icon: Icons.policy_outlined,
          title: 'سياسة الخصوصية',
          subtitle: 'اقرأ سياسة الخصوصية',
          onTap: () =>
              Get.snackbar('قريباً', 'سياسة الخصوصية ستكون متاحة قريباً'),
        ),
        _buildSettingsTile(
          icon: Icons.gavel_outlined,
          title: 'شروط الاستخدام',
          subtitle: 'اطلع على شروط الاستخدام',
          onTap: () =>
              Get.snackbar('قريباً', 'شروط الاستخدام ستكون متاحة قريباً'),
        ),
      ],
    );
  }

  Widget _buildDangerZoneSection() {
    return _buildSection(
      title: 'منطقة الخطر',
      titleColor: Colors.red,
      icon: Icons.warning_outlined,
      children: [
        _buildSettingsTile(
          icon: Icons.restart_alt,
          title: 'إعادة تعيين الإعدادات',
          subtitle: 'استرجاع الإعدادات الافتراضية',
          textColor: Colors.orange,
          onTap: controller.resetToDefaults,
        ),
        _buildSettingsTile(
          icon: Icons.logout,
          title: 'تسجيل الخروج',
          subtitle: 'الخروج من الحساب',
          textColor: Colors.red,
          onTap: () => _showLogoutDialog(),
        ),
        _buildSettingsTile(
          icon: Icons.delete_forever,
          title: 'حذف الحساب',
          subtitle: 'حذف حسابك نهائياً - لا يمكن التراجع',
          textColor: Colors.red,
          onTap: controller.deleteAccount,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    Color? titleColor,
    IconData? icon,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: titleColor ?? AppColors.primary),
                  SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: titleColor ?? AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (textColor ?? AppColors.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: textColor ?? AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      trailing:
          trailing ??
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textSecondary,
          ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    bool enabled = true,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(enabled ? 0.1 : 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.primary : AppColors.textSecondary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
        activeColor: AppColors.primary,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      enabled: enabled,
    );
  }

  void _showImagePicker() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'تغيير صورة الملف الشخصي',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.photo_library, color: AppColors.primary),
              ),
              title: Text('اختيار من المعرض'),
              onTap: () {
                Get.back();
                controller.pickProfileImage();
              },
            ),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.camera_alt, color: AppColors.primary),
              ),
              title: Text('التقاط صورة'),
              onTap: () {
                Get.back();
                controller.takePhoto();
              },
            ),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.delete, color: Colors.red),
              ),
              title: Text('إزالة الصورة'),
              onTap: () {
                Get.back();
                controller.removeProfileImage();
              },
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lock_outline, color: AppColors.primary),
            SizedBox(width: 8),
            Text('تغيير كلمة المرور'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller.currentPasswordController,
              decoration: InputDecoration(
                labelText: 'كلمة المرور الحالية',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: controller.newPasswordController,
              decoration: InputDecoration(
                labelText: 'كلمة المرور الجديدة',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
                helperText: 'يجب أن تكون 6 أحرف على الأقل',
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: controller.confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'تأكيد كلمة المرور الجديدة',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearPasswordForm();
              Get.back();
            },
            child: Text('إلغاء'),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: controller.isChangingPassword.value
                  ? null
                  : () => controller.changePassword(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: controller.isChangingPassword.value
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text('تغيير', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangeEmailDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.email_outlined, color: AppColors.primary),
            SizedBox(width: 8),
            Text('تغيير البريد الإلكتروني'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني الجديد',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'كلمة المرور الحالية',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
                helperText: 'مطلوبة لتأكيد هويتك',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement email change
              Get.back();
              Get.snackbar(
                'قريباً',
                'تغيير البريد الإلكتروني سيكون متاح قريباً',
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('تغيير', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('تسجيل الخروج'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.logout, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text('هل أنت متأكد من تسجيل الخروج؟', textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.put(AuthController()).signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('خروج', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
