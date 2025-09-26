// Contact Support View
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../theme/app_theme.dart';
import '../widgets/copyright_widget.dart';

class ContactView extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final RxString selectedCategory = 'عام'.obs;

  final List<String> categories = [
    'عام',
    'مشكلة تقنية',
    'الحساب والملف الشخصي',
    'الخصوصية والأمان',
    'الإشعارات',
    'معرض الأعمال',
    'اقتراح تحسين',
    'إبلاغ عن مشكلة',
  ];

  ContactView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('تواصل معنا'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Icons.support_agent, size: 48, color: AppColors.primary),
                  SizedBox(height: 12),
                  Text(
                    'نحن هنا لمساعدتك',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'أرسل لنا رسالة وسنرد عليك في أقرب وقت',
                    style: TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Quick Contact Methods
            Row(
              children: [
                Expanded(
                  child: _buildQuickContactCard(
                    icon: Icons.email,
                    title: 'البريد',
                    subtitle: 'support@app.com',
                    onTap: () => _launchEmail(),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildQuickContactCard(
                    icon: Icons.phone,
                    title: 'الهاتف',
                    subtitle: '+966 12 345 6789',
                    onTap: () => _launchPhone(),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Contact Form
            Container(
              padding: EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أرسل رسالة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Name field
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'الاسم',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Email field
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),

                  // Category selection
                  Obx(
                    () => DropdownButtonFormField<String>(
                      value: selectedCategory.value,
                      decoration: InputDecoration(
                        labelText: 'فئة الاستفسار',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          selectedCategory.value = value;
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 16),

                  // Subject field
                  TextFormField(
                    controller: subjectController,
                    decoration: InputDecoration(
                      labelText: 'الموضوع',
                      prefixIcon: Icon(Icons.subject),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Message field
                  TextFormField(
                    controller: messageController,
                    decoration: InputDecoration(
                      labelText: 'الرسالة',
                      prefixIcon: Icon(Icons.message),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 5,
                  ),
                  SizedBox(height: 24),

                  // Send button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _sendMessage,
                      icon: Icon(Icons.send),
                      label: Text('إرسال الرسالة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Response time info
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, color: AppColors.primary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'نرد عادة خلال 24-48 ساعة في أيام العمل',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            // Copyright
            Center(child: CopyRightWidget()),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        subjectController.text.isEmpty ||
        messageController.text.isEmpty) {
      Get.snackbar('خطأ', 'يرجى ملء جميع الحقول');
      return;
    }

    // TODO: Implement actual message sending
    // For now, just show success message
    Get.snackbar(
      'تم الإرسال',
      'شكراً لتواصلك معنا. سنرد عليك قريباً',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    // Clear form
    nameController.clear();
    emailController.clear();
    subjectController.clear();
    messageController.clear();
    selectedCategory.value = 'عام';

    Get.back();
  }

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@portefy.com',
      queryParameters: {'subject': 'استفسار من تطبيق Portefy'},
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      Get.snackbar('خطأ', 'تعذر فتح تطبيق البريد');
    }
  }

  void _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+21620999298');

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      Get.snackbar('خطأ', 'تعذر فتح تطبيق الهاتف');
    }
  }
}
