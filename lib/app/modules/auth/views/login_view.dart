import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_logo.dart';
import '../../../theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 60),

              // Logo and Title
              Column(
                children: [
                  CustomLogo(),
                  SizedBox(height: 20),
                  Text(
                    'مرحباً بك',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'سجل الدخول لحسابك',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 50),
              

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

              // Login Form
              Form(
                key: controller.loginFormKey,
                child: Column(
                  children: [
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

                    SizedBox(height: 12),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.FORGOT_PASSWORD),
                        child: Text('نسيت كلمة المرور؟'),
                      ),
                    ),

                    SizedBox(height: 30),

                    // Login Button
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.login,
                          child: controller.isLoading.value
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text('تسجيل الدخول'),
                        ),
                      ),
                    ),

                    SizedBox(height: 30),

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ليس لديك حساب؟ ',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.REGISTER),
                          child: Text('إنشاء حساب'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

