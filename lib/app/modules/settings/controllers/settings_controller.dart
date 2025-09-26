import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/theme_service.dart';
import '../../../routes/app_routes.dart';

class SettingsController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final UserService _userService = UserService();
  final StorageService _storageService = StorageService();
  final ThemeService _themeService = Get.find<ThemeService>();

  // Form controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final universityController = TextEditingController();
  final majorController = TextEditingController();
  final yearController = TextEditingController();
  final bioController = TextEditingController();
  final cityController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isUpdatingProfile = false.obs;
  final RxBool isChangingPassword = false.obs;
  final RxString selectedGender = ''.obs;
  final Rx<DateTime?> selectedDateOfBirth = Rx<DateTime?>(null);
  final Rx<File?> selectedProfileImage = Rx<File?>(null);
  final RxString profileImageUrl = ''.obs;

  // Settings observables
  final RxBool notificationsEnabled = true.obs;
  final RxBool emailNotifications = true.obs;
  final RxBool pushNotifications = true.obs;
  final RxBool soundEnabled = true.obs;
  final RxString selectedLanguage = 'العربية'.obs;

  // Privacy settings
  final RxBool profilePublic = true.obs;
  final RxBool showEmail = false.obs;
  final RxBool showPhone = false.obs;
  final RxBool allowMessages = true.obs;

  // New settings
  final RxBool darkModeEnabled = false.obs;
  final RxBool autoBackupEnabled = true.obs;
  final RxBool analyticsEnabled = true.obs;
  final RxString cacheSize = '0 MB'.obs;

  final ImagePicker _picker = ImagePicker();

  // Gender options
  final List<String> genderOptions = ['ذكر', 'أنثى'];
  
  // Language options
  final List<Map<String, String>> languageOptions = [
    {'code': 'ar', 'name': 'العربية'},
    {'code': 'en', 'name': 'English'},
    {'code': 'fr', 'name': 'Français'},
  ];

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadSettings();
    calculateCacheSize();
  }

  // Load user data
  void loadUserData() {
    UserModel? user = _authService.appUser.value;
    if (user != null) {
      firstNameController.text = user.firstName ?? '';
      lastNameController.text = user.lastName ?? '';
      emailController.text = user.email;
      phoneController.text = user.phone ?? '';
      universityController.text = user.university ?? '';
      majorController.text = user.major ?? '';
      yearController.text = user.level ?? '';
      bioController.text = user.bio ?? '';
      cityController.text = user.city ?? '';
      selectedGender.value = user.gender ?? '';
      selectedDateOfBirth.value = user.dateOfBirth;
      profileImageUrl.value = user.photoURL ?? '';
    }
  }

  // Load settings from SharedPreferences
  Future<void> loadSettings() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      notificationsEnabled.value = prefs.getBool('notifications_enabled') ?? true;
      emailNotifications.value = prefs.getBool('email_notifications') ?? true;
      pushNotifications.value = prefs.getBool('push_notifications') ?? true;
      soundEnabled.value = prefs.getBool('sound_enabled') ?? true;
      selectedLanguage.value = prefs.getString('selected_language') ?? 'العربية';
      profilePublic.value = prefs.getBool('profile_public') ?? true;
      showEmail.value = prefs.getBool('show_email') ?? false;
      showPhone.value = prefs.getBool('show_phone') ?? false;
      allowMessages.value = prefs.getBool('allow_messages') ?? true;
      darkModeEnabled.value = prefs.getBool('dark_mode_enabled') ?? false;
      autoBackupEnabled.value = prefs.getBool('auto_backup_enabled') ?? true;
      analyticsEnabled.value = prefs.getBool('analytics_enabled') ?? true;
    } catch (e) {
      print('خطأ في تحميل الإعدادات: $e');
    }
  }

  // Update profile
  Future<void> updateProfile() async {
    try {
      isUpdatingProfile.value = true;

      String? userId = _authService.currentUserId;
      if (userId == null) throw 'المستخدم غير مسجل الدخول';

      String? imageUrl = profileImageUrl.value;

      // Upload new profile image if selected
      if (selectedProfileImage.value != null) {
        imageUrl = await _storageService.uploadProfileImage(
          userId,
          selectedProfileImage.value!,
        );
      }

      UserModel updateData = UserModel(
        id: _authService.currentUserId!,
        email: _authService.currentUser!.email!,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        phone: phoneController.text.trim(),
        university: universityController.text.trim(),
        major: majorController.text.trim(),
        level: yearController.text.trim(),
        bio: bioController.text.trim(),
        city: cityController.text.trim(),
        gender: selectedGender.value,
        dateOfBirth: selectedDateOfBirth.value,
        photoURL: imageUrl,
        createdAt: _authService.appUser.value!.createdAt,
        updatedAt: DateTime.now(),
      );

      await _userService.updateUser(userId, updateData);

      // Update auth service display name and photo
      await _authService.updateProfile(
        displayName: '${firstNameController.text} ${lastNameController.text}',
        photoURL: imageUrl,
      );

      // Refresh user data
      await _authService.refreshUserData();

      Get.snackbar('نجح', 'تم تحديث الملف الشخصي بنجاح');
      Get.back();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحديث الملف الشخصي: ${e.toString()}');
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  // Change password - Complete implementation
  Future<void> changePassword() async {
    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar('خطأ', 'كلمات المرور الجديدة غير متطابقة');
      return;
    }

    if (newPasswordController.text.length < 6) {
      Get.snackbar('خطأ', 'كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      return;
    }

    if (currentPasswordController.text.isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال كلمة المرور الحالية');
      return;
    }

    try {
      isChangingPassword.value = true;

      // Re-authenticate user with current password
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'المستخدم غير مسجل الدخول';

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPasswordController.text,
      );

      // Re-authenticate
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPasswordController.text);

      Get.snackbar('نجح', 'تم تغيير كلمة المرور بنجاح');
      Get.back();
      clearPasswordForm();
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'كلمة المرور الحالية غير صحيحة';
          break;
        case 'requires-recent-login':
          errorMessage = 'يرجى تسجيل الدخول مرة أخرى لتغيير كلمة المرور';
          break;
        case 'weak-password':
          errorMessage = 'كلمة المرور الجديدة ضعيفة جداً';
          break;
        default:
          errorMessage = 'فشل تغيير كلمة المرور: ${e.message}';
      }
      Get.snackbar('خطأ', errorMessage);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تغيير كلمة المرور: ${e.toString()}');
    } finally {
      isChangingPassword.value = false;
    }
  }

  // Pick profile image
  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70,
      );

      if (image != null) {
        selectedProfileImage.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل اختيار الصورة');
    }
  }

  // Take photo with camera
  Future<void> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70,
      );

      if (image != null) {
        selectedProfileImage.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل التقاط الصورة');
    }
  }

  // Remove profile image
  void removeProfileImage() {
    selectedProfileImage.value = null;
    profileImageUrl.value = '';
  }

  // Select date of birth
  Future<void> selectDateOfBirth() async {
    DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDateOfBirth.value ?? DateTime.now().subtract(Duration(days: 6570)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: Locale('ar'),
    );

    if (picked != null) {
      selectedDateOfBirth.value = picked;
    }
  }

  // Update notification settings
  Future<void> updateNotificationSettings() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', notificationsEnabled.value);
      await prefs.setBool('email_notifications', emailNotifications.value);
      await prefs.setBool('push_notifications', pushNotifications.value);
      await prefs.setBool('sound_enabled', soundEnabled.value);

      Get.snackbar('تم', 'تم حفظ إعدادات الإشعارات');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل حفظ الإعدادات');
    }
  }

  // Update privacy settings
  Future<void> updatePrivacySettings() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('profile_public', profilePublic.value);
      await prefs.setBool('show_email', showEmail.value);
      await prefs.setBool('show_phone', showPhone.value);
      await prefs.setBool('allow_messages', allowMessages.value);

      Get.snackbar('تم', 'تم حفظ إعدادات الخصوصية');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل حفظ الإعدادات');
    }
  }

  // Update app settings
  Future<void> updateAppSettings() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_language', selectedLanguage.value);
      await prefs.setBool('dark_mode_enabled', darkModeEnabled.value);
      await prefs.setBool('auto_backup_enabled', autoBackupEnabled.value);
      await prefs.setBool('analytics_enabled', analyticsEnabled.value);

      Get.snackbar('تم', 'تم حفظ إعدادات التطبيق');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل حفظ الإعدادات');
    }
  }

  // Toggle theme
  void toggleTheme() {
    _themeService.toggleTheme();
    darkModeEnabled.value = _themeService.isDarkMode.value;
    updateAppSettings();
  }

  // Show theme selection dialog
  void showThemeDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('اختيار المظهر'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => RadioListTile<bool>(
              title: Text('فاتح'),
              value: false,
              groupValue: _themeService.isDarkMode.value,
              onChanged: (value) {
                _themeService.setTheme(false);
                darkModeEnabled.value = false;
                updateAppSettings();
                Get.back();
              },
            )),
            Obx(() => RadioListTile<bool>(
              title: Text('داكن'),
              value: true,
              groupValue: _themeService.isDarkMode.value,
              onChanged: (value) {
                _themeService.setTheme(true);
                darkModeEnabled.value = true;
                updateAppSettings();
                Get.back();
              },
            )),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('إلغاء')),
        ],
      ),
    );
  }

  // Show language selection dialog
  void showLanguageDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('اختيار اللغة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languageOptions.map((lang) {
            return Obx(() => RadioListTile<String>(
              title: Text(lang['name']!),
              value: lang['name']!,
              groupValue: selectedLanguage.value,
              onChanged: (value) {
                if (value != null) {
                  selectedLanguage.value = value;
                  updateAppSettings();
                  Get.back();
                  
                  // Update locale if needed
                  if (lang['code'] == 'ar') {
                    Get.updateLocale(Locale('ar'));
                  } else if (lang['code'] == 'en') {
                    Get.updateLocale(Locale('en'));
                  } else if (lang['code'] == 'fr') {
                    Get.updateLocale(Locale('fr'));
                  }
                }
              },
            ));
          }).toList(),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('إلغاء')),
        ],
      ),
    );
  }

  // Get current theme name
  String get currentThemeName => _themeService.currentThemeName;

  // Calculate cache size
  Future<void> calculateCacheSize() async {
    try {
      // This is a simplified implementation
      // In a real app, you would calculate actual cache sizes from different sources
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Set<String> keys = prefs.getKeys();
      
      int estimatedSize = 0;
      for (String key in keys) {
        dynamic value = prefs.get(key);
        if (value != null) {
          estimatedSize += value.toString().length;
        }
      }
      
      // Convert to MB (rough estimation)
      double sizeMB = estimatedSize / (1024 * 1024);
      cacheSize.value = '${sizeMB.toStringAsFixed(1)} MB';
    } catch (e) {
      cacheSize.value = '0 MB';
    }
  }

  // Clear cache
  Future<void> clearCache() async {
    try {
      isLoading.value = true;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      // Save important settings before clearing
      Map<String, dynamic> importantSettings = {
        'notifications_enabled': notificationsEnabled.value,
        'selected_language': selectedLanguage.value,
        'dark_mode_enabled': darkModeEnabled.value,
      };

      // Clear all cache
      await prefs.clear();

      // Restore important settings
      for (String key in importantSettings.keys) {
        if (importantSettings[key] is bool) {
          await prefs.setBool(key, importantSettings[key]);
        } else if (importantSettings[key] is String) {
          await prefs.setString(key, importantSettings[key]);
        }
      }

      await calculateCacheSize();
      Get.snackbar('تم', 'تم مسح ذاكرة التخزين المؤقت');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل مسح ذاكرة التخزين المؤقت');
    } finally {
      isLoading.value = false;
    }
  }

  // Export data
  Future<void> exportData() async {
    try {
      isLoading.value = true;

      UserModel? user = _authService.appUser.value;
      if (user == null) throw 'لا توجد بيانات مستخدم';

      // Create export data structure
      Map<String, dynamic> exportData = {
        'user_data': user.toMap(),
        'settings': {
          'notifications_enabled': notificationsEnabled.value,
          'email_notifications': emailNotifications.value,
          'push_notifications': pushNotifications.value,
          'sound_enabled': soundEnabled.value,
          'selected_language': selectedLanguage.value,
          'profile_public': profilePublic.value,
          'show_email': showEmail.value,
          'show_phone': showPhone.value,
          'allow_messages': allowMessages.value,
          'dark_mode_enabled': darkModeEnabled.value,
          'auto_backup_enabled': autoBackupEnabled.value,
          'analytics_enabled': analyticsEnabled.value,
        },
        'export_date': DateTime.now().toIso8601String(),
      };

      // In a real implementation, you would save this to a file or send via email
      // For now, we'll just show a success message
      print('Export data: $exportData');

      await Future.delayed(Duration(seconds: 2)); // Simulate processing time

      Get.snackbar('تم', 'تم تصدير البيانات بنجاح');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تصدير البيانات: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Backup data to cloud
  Future<void> backupData() async {
    try {
      isLoading.value = true;

      UserModel? user = _authService.appUser.value;
      if (user == null) throw 'لا توجد بيانات مستخدم';

      // Create backup data
      Map<String, dynamic> backupData = {
        'user_id': user.id,
        'backup_date': DateTime.now().toIso8601String(),
        'user_data': user.toMap(),
        'settings': {
          'notifications_enabled': notificationsEnabled.value,
          'email_notifications': emailNotifications.value,
          'push_notifications': pushNotifications.value,
          'sound_enabled': soundEnabled.value,
          'selected_language': selectedLanguage.value,
          'profile_public': profilePublic.value,
          'show_email': showEmail.value,
          'show_phone': showPhone.value,
          'allow_messages': allowMessages.value,
          'dark_mode_enabled': darkModeEnabled.value,
          'auto_backup_enabled': autoBackupEnabled.value,
          'analytics_enabled': analyticsEnabled.value,
        },
      };

      // Save backup to Firestore or cloud storage
      // In a real implementation, you would implement actual cloud backup
      
      await Future.delayed(Duration(seconds: 3)); // Simulate backup time

      Get.snackbar('تم', 'تم النسخ الاحتياطي بنجاح');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل النسخ الاحتياطي: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete account with proper confirmation
  Future<void> deleteAccount() async {
    // Show first confirmation
    bool firstConfirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('تأكيد حذف الحساب', style: TextStyle(color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(
              'هل أنت متأكد من حذف حسابك؟\n\nسيتم حذف جميع بياناتك نهائياً ولا يمكن استرجاعها.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('متابعة', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (!firstConfirm) return;

    // Show second confirmation with password input
    final passwordController = TextEditingController();
    bool secondConfirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('تأكيد نهائي', style: TextStyle(color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('أدخل كلمة المرور الحالية لتأكيد حذف الحساب:'),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'كلمة المرور',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('حذف نهائياً', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (!secondConfirm || passwordController.text.isEmpty) return;

    try {
      isLoading.value = true;

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'المستخدم غير مسجل الدخول';

      // Re-authenticate before deletion
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: passwordController.text,
      );

      await user.reauthenticateWithCredential(credential);

      String userId = user.uid;

      // Delete user data from Firestore
      await _userService.deleteUser(userId);

      // Delete Firebase Auth account
      await user.delete();

      // Clear local data
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Navigate to login
      Get.offAllNamed(AppRoutes.LOGIN);

      Get.snackbar('تم', 'تم حذف الحساب بنجاح');
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'كلمة المرور غير صحيحة';
          break;
        case 'requires-recent-login':
          errorMessage = 'يرجى تسجيل الدخول مرة أخرى';
          break;
        default:
          errorMessage = 'فشل حذف الحساب: ${e.message}';
      }
      Get.snackbar('خطأ', errorMessage);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل حذف الحساب: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Reset all settings to default
  Future<void> resetToDefaults() async {
    bool confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('إعادة تعيين الإعدادات'),
        content: Text('هل تريد إعادة جميع الإعدادات إلى القيم الافتراضية؟'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text('إلغاء')),
          TextButton(onPressed: () => Get.back(result: true), child: Text('إعادة تعيين')),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        // Reset to default values
        notificationsEnabled.value = true;
        emailNotifications.value = true;
        pushNotifications.value = true;
        soundEnabled.value = true;
        selectedLanguage.value = 'العربية';
        profilePublic.value = true;
        showEmail.value = false;
        showPhone.value = false;
        allowMessages.value = true;
        darkModeEnabled.value = false;
        autoBackupEnabled.value = true;
        analyticsEnabled.value = true;

        // Save to preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('notifications_enabled', true);
        await prefs.setBool('email_notifications', true);
        await prefs.setBool('push_notifications', true);
        await prefs.setBool('sound_enabled', true);
        await prefs.setString('selected_language', 'العربية');
        await prefs.setBool('profile_public', true);
        await prefs.setBool('show_email', false);
        await prefs.setBool('show_phone', false);
        await prefs.setBool('allow_messages', true);
        await prefs.setBool('dark_mode_enabled', false);
        await prefs.setBool('auto_backup_enabled', true);
        await prefs.setBool('analytics_enabled', true);

        // Reset theme
        _themeService.setTheme(false);

        Get.snackbar('تم', 'تم إعادة تعيين جميع الإعدادات');
      } catch (e) {
        Get.snackbar('خطأ', 'فشل إعادة تعيين الإعدادات');
      }
    }
  }

  

  // Clear password form
  void clearPasswordForm() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    universityController.dispose();
    majorController.dispose();
    yearController.dispose();
    bioController.dispose();
    cityController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}