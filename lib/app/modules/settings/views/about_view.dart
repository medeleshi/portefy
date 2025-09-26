import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/widgets/custom_logo.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../widgets/contact_button_widget.dart';
import '../widgets/copyright_widget.dart';

// About View
class AboutView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('حول التطبيق'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo and Info
            Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CustomLogo(),
                  SizedBox(height: 8),
                  Text(
                    'الإصدار 1.0.0',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'منصة شاملة لبناء الملف الشخصي للطلاب والتواصل مع المجتمع الأكاديمي',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Features
            _buildInfoSection(
              title: 'المميزات',
              icon: Icons.star_outline,
              items: [
                'إنشاء ملف شخصي احترافي',
                'معرض أعمال تفاعلي',
                'شبكة تواصل أكاديمية',
                'نظام نقاط ومكافآت',
                'مشاركة المعرفة والخبرات',
                'واجهة سهلة الاستخدام',
              ],
            ),

            SizedBox(height: 20),

            // Team
            _buildInfoSection(
              title: 'فريق التطوير',
              icon: Icons.people_outline,
              items: [
                'فريق من المطورين المتخصصين',
                'خبراء في تجربة المستخدم',
                'مصممين محترفين',
                'متخصصين في الأمان والخصوصية',
              ],
            ),

            SizedBox(height: 20),

            // Contact Info
            _buildContactSection(),

            SizedBox(height: 24),

            // Contact Support Button
            ContactButtonWidget(),

            SizedBox(height: 24),

            // Copyright
            CopyRightWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required List<String> items,
  }) {
    return Container(
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
          Row(
            children: [
              Icon(icon, color: AppColors.primary),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...items
              .map(
                (item) => Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 6, right: 8),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
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
          Row(
            children: [
              Icon(Icons.contact_support, color: AppColors.primary),
              SizedBox(width: 12),
              Text(
                'تواصل معنا',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildContactItem(Icons.email, 'support@portefy.com'),
          _buildContactItem(Icons.phone, '+216 20 999 298'),
          _buildContactItem(Icons.web, 'www.portefy.com'),
          _buildContactItem(
            Icons.location_on,
            'صفاقس، تونس',
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

