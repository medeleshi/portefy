import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_theme.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: controller.skipOnboarding,
            child: Text(
              'تخطي',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: controller.pageController,
              onPageChanged: (index) => controller.currentIndex.value = index,
              itemCount: controller.pages.length,
              itemBuilder: (context, index) {
                final page = controller.pages[index];
                return Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon/Image placeholder
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Icon(
                          page.icon,
                          size: 80,
                          color: AppColors.primary,
                        ),
                      ),
                      
                      SizedBox(height: 60),
                      
                      // Title
                      Text(
                        page.title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Description
                      Text(
                        page.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Page Indicators
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                controller.pages.length,
                (index) => Obx(() => _buildPageIndicator(index == controller.currentIndex.value)),
              ),
            ),
          ),
          
          SizedBox(height: 40),
          
          // Navigation Buttons
          Padding(
            padding: EdgeInsets.all(24.0),
            child: Row(
              children: [
                // Previous Button
                Obx(() => controller.currentIndex.value > 0
                    ? OutlinedButton(
                        onPressed: controller.previousPage,
                        child: Text('السابق'),
                      )
                    : SizedBox.shrink()),
                
                Spacer(),
                
                // Next/Get Started Button
                Obx(() => ElevatedButton(
                      onPressed: controller.nextPage,
                      child: Text(
                        controller.currentIndex.value == controller.pages.length - 1
                            ? 'ابدأ الآن'
                            : 'التالي',
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}