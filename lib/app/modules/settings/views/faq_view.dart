// FAQ View
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portefy/app/modules/settings/widgets/copyright_widget.dart';
import 'package:portefy/app/routes/app_routes.dart';

import '../../../theme/app_theme.dart';
import '../widgets/contact_button_widget.dart';

// FAQ Item Model
class FAQItem {
  final String question;
  final String answer;
  final String category;
  final IconData icon;

  FAQItem({
    required this.question,
    required this.answer,
    required this.category,
    required this.icon,
  });
}

class FAQView extends StatelessWidget {
  final List<FAQItem> faqItems = [
    FAQItem(
      question: 'كيف أنشئ ملف شخصي جذاب؟',
      answer:
          'لإنشاء ملف شخصي جذاب، احرص على:\n• إضافة صورة واضحة ومناسبة\n• كتابة نبذة شخصية مميزة\n• إضافة مهاراتك وإنجازاتك\n• تحديث معلوماتك الأكاديمية\n• مشاركة أعمالك ومشاريعك',
      category: 'الملف الشخصي',
      icon: Icons.person,
    ),
    FAQItem(
      question: 'كيف أتواصل مع طلاب آخرين؟',
      answer:
          'يمكنك التواصل مع الطلاب من خلال:\n• البحث عن طلاب في نفس جامعتك\n• المشاركة في المنشورات والتعليقات\n• إرسال رسائل مباشرة\n• المشاركة في المجموعات الأكاديمية',
      category: 'التواصل',
      icon: Icons.chat,
    ),
    FAQItem(
      question: 'كيف أحمي خصوصيتي؟',
      answer:
          'لحماية خصوصيتك:\n• راجع إعدادات الخصوصية بانتظام\n• اختر ما تريد إظهاره في ملفك\n• تحكم في من يمكنه مراسلتك\n• احذر من مشاركة معلومات حساسة',
      category: 'الخصوصية',
      icon: Icons.security,
    ),
    FAQItem(
      question: 'ما هو نظام النقاط؟',
      answer:
          'نظام النقاط يكافئك على:\n• إكمال ملفك الشخصي\n• المشاركة الفعالة في المحتوى\n• مساعدة الطلاب الآخرين\n• تحقيق الإنجازات الأكاديمية\n\nيمكن استخدام النقاط لإلغاء قفل مميزات خاصة',
      category: 'النقاط',
      icon: Icons.star,
    ),
    FAQItem(
      question: 'كيف أرفع ملفات إلى معرض أعمالي؟',
      answer:
          'لرفع ملفات إلى معرض أعمالك:\n• اذهب إلى معرض الأعمال\n• اضغط على زر إضافة مشروع\n• اختر الملفات المناسبة\n• أضف وصف مفصل لكل مشروع\n• نظم أعمالك في فئات',
      category: 'معرض الأعمال',
      icon: Icons.folder,
    ),
    FAQItem(
      question: 'كيف أغير إعدادات الإشعارات؟',
      answer:
          'لتخصيص الإشعارات:\n• اذهب إلى الإعدادات\n• اختر قسم الإشعارات\n• فعّل أو ألغِ أنواع الإشعارات\n• حدد أوقات الهدوء\n• اختر طريقة التنبيه المفضلة',
      category: 'الإعدادات',
      icon: Icons.notifications,
    ),
    FAQItem(
      question: 'ماذا أفعل إذا نسيت كلمة المرور؟',
      answer:
          'إذا نسيت كلمة المرور:\n• اضغط على "نسيت كلمة المرور" في صفحة تسجيل الدخول\n• أدخل بريدك الإلكتروني\n• تحقق من بريدك الوارد\n• اتبع الرابط لإعادة تعيين كلمة المرور\n• أنشئ كلمة مرور جديدة وقوية',
      category: 'الحساب',
      icon: Icons.lock,
    ),
    FAQItem(
      question: 'كيف أحذف حسابي؟',
      answer:
          'لحذف حسابك:\n• اذهب إلى الإعدادات\n• اختر "منطقة الخطر"\n• اضغط على "حذف الحساب"\n• أدخل كلمة المرور للتأكيد\n\nتنبيه: هذا الإجراء لا يمكن التراجع عنه',
      category: 'الحساب',
      icon: Icons.delete_forever,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Group FAQ items by category
    Map<String, List<FAQItem>> groupedItems = {};
    for (var item in faqItems) {
      if (!groupedItems.containsKey(item.category)) {
        groupedItems[item.category] = [];
      }
      groupedItems[item.category]!.add(item);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('الأسئلة الشائعة'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Icons.help_outline, size: 48, color: AppColors.primary),
                  SizedBox(height: 12),
                  Text(
                    'كيف يمكننا مساعدتك؟',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ابحث في الأسئلة الشائعة أو تواصل معنا',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // FAQ Categories
            ...groupedItems.entries
                .map((entry) => _buildFAQCategory(entry.key, entry.value))
                .toList(),

            SizedBox(height: 24),

            // Contact Support Button
            ContactButtonWidget(),
            SizedBox(height: 24),
            // Copyright
            Center(child: CopyRightWidget()),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQCategory(String category, List<FAQItem> items) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(items.first.icon, color: AppColors.primary),
                SizedBox(width: 12),
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          ...items.map((item) => _buildFAQItem(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildFAQItem(FAQItem item) {
    return ExpansionTile(
      title: Text(
        item.question,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            item.answer,
            style: TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
        ),
      ],
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('البحث في الأسئلة الشائعة'),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'ما الذي تبحث عنه؟',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (value) {
            Get.back();
            // TODO: Implement search functionality
            Get.snackbar('البحث', 'البحث عن: $value');
          },
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('إلغاء')),
        ],
      ),
    );
  }
}
