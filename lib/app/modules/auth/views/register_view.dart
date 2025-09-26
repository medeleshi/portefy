import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_theme.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('إنشاء حساب جديد'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Form(
            key: controller.registerFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),

                // Title
                Text(
                  'أنشئ حسابك الجديد',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 8),

                Text(
                  'ابدأ رحلتك في بناء ملفك الشخصي',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 40),

                // Social Login Buttons
                Column(
                  children: [
                    // Google Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: controller.signInWithGoogle,
                        icon: Icon(Icons.g_mobiledata, color: Colors.red),
                        label: Text('تسجيل الدخول بـ Google'),
                      ),
                    ),

                    // SizedBox(height: 12),

                    // // Facebook Button
                    // SizedBox(
                    //   width: double.infinity,
                    //   child: OutlinedButton.icon(
                    //     onPressed: controller.signInWithFacebook,
                    //     icon: Icon(Icons.facebook, color: Colors.blue),
                    //     label: Text('تسجيل الدخول بـ Facebook'),
                    //   ),
                    // ),
                  ],
                ),

                SizedBox(height: 30),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'أو',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),

                SizedBox(height: 30),

                // Email Field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: controller.validateEmail,
                  onChanged: controller.email.call,
                ),

                SizedBox(height: 20),

                // Password Field
                Obx(
                  () => TextFormField(
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      prefixIcon: Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscurePassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                    ),
                    obscureText: controller.obscurePassword.value,
                    validator: controller.validatePassword,
                    onChanged: controller.password.call,
                  ),
                ),

                SizedBox(height: 20),

                // Confirm Password Field
                Obx(
                  () => TextFormField(
                    decoration: InputDecoration(
                      labelText: 'تأكيد كلمة المرور',
                      prefixIcon: Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscureConfirmPassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: controller.toggleConfirmPasswordVisibility,
                      ),
                    ),
                    obscureText: controller.obscureConfirmPassword.value,
                    validator: (value) {
                      if (value != controller.password.value) {
                        return 'كلمات المرور غير متطابقة';
                      }
                      return null;
                    },
                    onChanged: controller.confirmPassword.call,
                  ),
                ),

                SizedBox(height: 30),

                // Register Button
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.register,
                      child: controller.isLoading.value
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('إنشاء الحساب'),
                    ),
                  ),
                ),

                SizedBox(height: 30),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'لديك حساب؟ ',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('تسجيل الدخول'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
