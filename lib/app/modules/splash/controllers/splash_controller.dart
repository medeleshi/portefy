import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';
import '../../../services/network_service.dart'; // <- أضفناه
import '../../../modules/gamification/controllers/gamification_controller.dart';
import '../../../routes/app_routes.dart';
import 'package:flutter/material.dart';

class SplashController extends GetxController
    with SingleGetTickerProviderMixin {
  final AuthService _authService = Get.find<AuthService>();
  final UserService _userService = UserService();

  late AnimationController animationController;
  var textOpacity = 0.0.obs;
  var showRetryButton = false.obs;

  @override
  void onInit() {
    super.onInit();

    // تهيئة متحكم الرسوم المتحركة
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat();

    // تشغيل تأثير الوامض للنص
    Future.delayed(Duration(milliseconds: 800), () {
      textOpacity.value = 1.0;
    });

    // بدل _navigateToNextScreen() نستعمل version تتأكد من النت
    checkNetworkAndNavigate();
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  /// ✅ التأكد من الشبكة قبل الانتقال
  Future<void> checkNetworkAndNavigate() async {
    bool connected = await NetworkService.checkRealInternet();

    if (!connected) {
      // أظهر Dialog صغير للمستعمل
      showRetryButton.value = true;
      return; // ما نمشيوش بعد ما فماش نت
    }

    showRetryButton.value = false;
    // إذا فما نت، نكمل العملية العادية
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 2)); // splash delay

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool hasSeenOnboarding = prefs.getBool('onboarding_completed') ?? false;

      if (!hasSeenOnboarding) {
        Get.offNamed(AppRoutes.ONBOARDING);
        return;
      }

      if (!_authService.isSignedIn) {
        Get.offNamed(AppRoutes.LOGIN);
        return;
      }

      String? userId = _authService.currentUserId;
      if (userId == null) {
        Get.offNamed(AppRoutes.LOGIN);
        return;
      }

      bool isProfileComplete = await _checkProfileCompletion(userId);

      if (isProfileComplete) {
        await _checkDailyLogin();
        Get.offNamed(AppRoutes.MAIN);
      } else {
        Get.offNamed(AppRoutes.USER_INFO);
      }
    } catch (e) {
      print('خطأ في SplashController: $e');
      Get.offNamed(AppRoutes.LOGIN);
    }
  }

  Future<bool> _checkProfileCompletion(String userId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? localProfileStatus = prefs.getBool('profile_completed_$userId');

      print("🔎 [DEBUG] local profile_completed_$userId = $localProfileStatus");

      // جلب من Firebase
      UserModel? userData = await _userService.getUserData(userId);
      bool remoteProfileStatus = userData?.isProfileComplete ?? false;

      print("🔎 [DEBUG] remote isProfileComplete = $remoteProfileStatus");

      // منطق الدمج: إذا واحد فيهم true نعتبره مكتمل
      bool finalStatus = (localProfileStatus == true) || remoteProfileStatus;

      // نخزن النتيجة في SharedPreferences لتسريع الدخول المرة الجاية
      await prefs.setBool('profile_completed_$userId', finalStatus);

      print("✅ [DEBUG] Final profileCompleted for $userId = $finalStatus");

      return finalStatus;
    } catch (e) {
      print('⚠️ خطأ في فحص اكتمال الملف الشخصي: $e');
      return false;
    }
  }

  Future<void> _checkDailyLogin() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String today = DateTime.now().toIso8601String().split('T')[0];
      String? lastLoginDate = prefs.getString('last_login_date');

      if (lastLoginDate != today) {
        // منح نقاط الدخول اليومي
        await Get.find<GamificationController>().awardPoints('daily_login');
        await prefs.setString('last_login_date', today);
      }
    } catch (e) {
      print('خطأ في فحص الدخول اليومي: $e');
      // لا ترمي خطأ، استمر فقط
    }
  }
}
