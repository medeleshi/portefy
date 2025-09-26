import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_routes.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentIndex = 0.obs;
  
  final List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'ابني ملفك الشخصي',
      description: 'أنشئ ملفاً شخصياً متكاملاً يعرض مهاراتك، تعليمك، وخبراتك الأكاديمية والعملية',
      image: 'assets/images/onboarding1.png',
      icon: Icons.person_add,
    ),
    OnboardingPage(
      title: 'تواصل مع زملائك',
      description: 'انضم إلى مجتمع الطلاب، شارك أفكارك، وتفاعل مع زملائك في نفس الجامعة أو التخصص',
      image: 'assets/images/onboarding2.png',
      icon: Icons.people,
    ),
    OnboardingPage(
      title: 'احصل على فرص',
      description: 'استخدم ملفك الشخصي للحصول على فرص تدريب ووظائف، وحوّله إلى CV احترافي',
      image: 'assets/images/onboarding3.png',
      icon: Icons.work,
    ),
  ];

  void nextPage() {
    if (currentIndex.value < pages.length - 1) {
      currentIndex.value++;
      pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void previousPage() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      Get.offNamed(AppRoutes.LOGIN);
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ في إكمال التقديم');
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String image;
  final IconData icon;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
    required this.icon,
  });
}