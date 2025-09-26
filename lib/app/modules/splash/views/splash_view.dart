import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portefy/app/core/widgets/custom_logo.dart';
import '../../../theme/app_theme.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.primary,
      body: Container(
        decoration: BoxDecoration(
          // gradient: LinearGradient(
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          //   colors: [
          //     AppColors.primary,
          //     AppColors.secondary,
          //   ],
          // ),
        ),
        child: SafeArea(
          child: Center(
            // تغيير من Column إلى Center للتوسيط الكامل
            child: SingleChildScrollView(
              // لإضافة قابلية التمرير إذا لزم الأمر
              child: Obx(
                () => Column(
                  mainAxisAlignment: MainAxisAlignment.center, // توسيط عمودي
                  mainAxisSize: MainAxisSize.min, // لمنع التمدد الزائد
                  children: [
                    // Logo with animation
                    // AnimatedContainer(
                    //   duration: Duration(milliseconds: 1000),
                    //   curve: Curves.easeInOut,
                    //   width: 120,
                    //   height: 120,
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(24),
                    //     boxShadow: [
                    //       BoxShadow(
                    //         // ignore: deprecated_member_use
                    //         color: Colors.black.withOpacity(0.1),
                    //         blurRadius: 20,
                    //         offset: Offset(0, 10),
                    //       ),
                    //     ],
                    //   ),
                    //   child: Icon(
                    //     Icons.school,
                    //     size: 60,
                    //     color: AppColors.primary,
                    //   ),
                    // ),
                    CustomLogo(),

                    SizedBox(height: 40),

                    // App Name with fade animation
                    // FadeInText(
                    //   text: 'Portify',
                    //   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    //     color: Colors.white,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    //   delay: 300,
                    // ),

                    // SizedBox(height: 8),

                    // App Subtitle with fade animation
                    FadeInText(
                      text: 'ابني ملفك الشخصي الأكاديمي',
                      style: Theme.of(context).textTheme.titleLarge,
                      delay: 600,
                    ),

                    SizedBox(height: 60),

                    // Loading Indicator with rotation animation
                    RotationTransition(
                      turns: CurvedAnimation(
                        parent: controller.animationController,
                        curve: Curves.linear,
                      ),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        strokeWidth: 3,
                      ),
                    ),

                    SizedBox(height: 20),

                    // Loading text with blink animation
                    // AnimatedOpacity(
                    //   opacity: controller.textOpacity.value,
                    //   duration: Duration(milliseconds: 1000),
                    //   child: Text(
                    //     'جاري التحميل...',
                    //     style: Theme.of(context).textTheme.bodyMedium,
                    //   ),
                    // ),
                    if (controller.showRetryButton.value) ...[
                      // Icon(Icons.wifi_off, color: Colors.red, size: 40),
                      // SizedBox(height: 12),
                      Text('لا يوجد اتصال بالإنترنت'),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => controller.checkNetworkAndNavigate(),
                        icon: Icon(Icons.refresh),
                        label: Text('إعادة المحاولة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget for fade in text animation
class FadeInText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int delay;

  FadeInText({required this.text, this.style, this.delay = 0});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800),
      curve: Curves.easeIn,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: child,
          ),
        );
      },
      child: Text(text, style: style, textAlign: TextAlign.center),
    );
  }
}
