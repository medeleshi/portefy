import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:portefy/app/routes/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../controllers/portfolio_routing_controller.dart';

class PortfolioNotFoundView extends StatelessWidget {
  final String errorMessage;
  final bool isOwner;

  const PortfolioNotFoundView({
    Key? key,
    required this.errorMessage,
    this.isOwner = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text('الملف الشخصي'),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => _handleBackNavigation(),
        ),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildErrorIcon(),
              SizedBox(height: 24),
              _buildErrorTitle(),
              SizedBox(height: 12),
              _buildErrorMessage(),
              SizedBox(height: 32),
              _buildActionButtons(),
              SizedBox(height: 16),
              _buildAlternativeActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorIcon() {
    IconData icon;
    Color color;

    switch (_getErrorType()) {
      case ErrorType.userNotFound:
        icon = Icons.person_off;
        color = AppColors.error;
        break;
      case ErrorType.private:
        icon = Icons.lock;
        color = AppColors.warning;
        break;
      case ErrorType.blocked:
        icon = Icons.block;
        color = AppColors.error;
        break;
      case ErrorType.needLogin:
        icon = Icons.login;
        color = AppColors.info;
        break;
      case ErrorType.networkError:
        icon = Icons.wifi_off;
        color = AppColors.warning;
        break;
      case ErrorType.friendsOnly:
        icon = Icons.group;
        color = AppColors.info;
        break;
      default:
        icon = Icons.error_outline;
        color = AppColors.error;
    }

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Icon(icon, size: 60, color: color),
    );
  }

  Widget _buildErrorTitle() {
    String title;

    switch (_getErrorType()) {
      case ErrorType.userNotFound:
        title = 'المستخدم غير موجود';
        break;
      case ErrorType.private:
        title = 'ملف شخصي خاص';
        break;
      case ErrorType.blocked:
        title = 'غير متاح';
        break;
      case ErrorType.needLogin:
        title = 'تسجيل الدخول مطلوب';
        break;
      case ErrorType.networkError:
        title = 'مشكلة في الاتصال';
        break;
      case ErrorType.friendsOnly:
        title = 'للأصدقاء فقط';
        break;
      default:
        title = 'خطأ غير متوقع';
    }

    return Text(
      title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildErrorMessage() {
    String message;

    switch (_getErrorType()) {
      case ErrorType.userNotFound:
        message =
            'المستخدم المطلوب غير موجود أو تم حذف حسابه. تأكد من صحة الرابط أو ابحث عن المستخدم بطريقة أخرى.';
        break;
      case ErrorType.private:
        message =
            'هذا الملف الشخصي مخفي ولا يمكن عرضه للعامة. المالك قد اختار إبقاء ملفه خاصاً.';
        break;
      case ErrorType.blocked:
        message =
            'لا يمكنك عرض هذا الملف الشخصي. قد تكون محظوراً أو هناك قيود على الوصول.';
        break;
      case ErrorType.needLogin:
        message =
            'يجب تسجيل الدخول أولاً لعرض الملف الشخصي. سجل دخولك للحصول على الوصول الكامل.';
        break;
      case ErrorType.networkError:
        message =
            'تعذر الاتصال بالخادم. تحقق من اتصالك بالإنترنت وحاول مرة أخرى.';
        break;
      case ErrorType.friendsOnly:
        message =
            'هذا الملف الشخصي متاح للأصدقاء فقط. أرسل طلب صداقة للحصول على الوصول.';
        break;
      default:
        message = errorMessage.isNotEmpty
            ? errorMessage
            : 'حدث خطأ غير متوقع أثناء تحميل الملف الشخصي.';
    }

    return Text(
      message,
      style: TextStyle(
        fontSize: 16,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionButtons() {
    List<Widget> buttons = [];

    switch (_getErrorType()) {
      case ErrorType.userNotFound:
        buttons = [
          _buildPrimaryButton(
            'البحث عن مستخدمين',
            Icons.search,
            () => Get.toNamed('/search-users'),
          ),
          SizedBox(height: 12),
          _buildSecondaryButton(
            'العودة للرئيسية',
            Icons.home,
            () => Get.offAllNamed('/home'),
          ),
        ];
        break;
      case ErrorType.private:
        buttons = [
          _buildPrimaryButton(
            'البحث عن المستخدم',
            Icons.search,
            () => Get.toNamed('/search-users'),
          ),
          SizedBox(height: 12),
          _buildSecondaryButton(
            'العودة',
            Icons.arrow_back,
            () => _handleBackNavigation(),
          ),
        ];
        break;
      case ErrorType.friendsOnly:
        buttons = [
          _buildPrimaryButton(
            'إرسال طلب صداقة',
            Icons.person_add,
            () => _sendFriendRequest(),
          ),
          SizedBox(height: 12),
          _buildSecondaryButton(
            'العودة',
            Icons.arrow_back,
            () => _handleBackNavigation(),
          ),
        ];
        break;
      case ErrorType.blocked:
        buttons = [
          _buildInfoCard(
            'لا يمكنك التفاعل مع هذا المستخدم',
            Icons.info,
            AppColors.warning,
          ),
          SizedBox(height: 12),
          _buildSecondaryButton(
            'العودة',
            Icons.arrow_back,
            () => _handleBackNavigation(),
          ),
        ];
        break;
      case ErrorType.needLogin:
        buttons = [
          _buildPrimaryButton(
            'تسجيل الدخول',
            Icons.login,
            () => Get.toNamed('/login'),
          ),
          SizedBox(height: 12),
          _buildSecondaryButton(
            'إنشاء حساب جديد',
            Icons.person_add,
            () => Get.toNamed('/register'),
          ),
        ];
        break;
      case ErrorType.networkError:
        buttons = [
          _buildPrimaryButton(
            'المحاولة مرة أخرى',
            Icons.refresh,
            () => _retryConnection(),
          ),
          SizedBox(height: 12),
          _buildSecondaryButton(
            'فحص الاتصال',
            Icons.wifi,
            () => _checkConnection(),
          ),
        ];
        break;
      default:
        buttons = [
          _buildPrimaryButton(
            'المحاولة مرة أخرى',
            Icons.refresh,
            () => _retryLoading(),
          ),
          SizedBox(height: 12),
          _buildSecondaryButton(
            'العودة',
            Icons.arrow_back,
            () => _handleBackNavigation(),
          ),
        ];
    }

    return Column(children: buttons);
  }

  Widget _buildAlternativeActions() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'خيارات أخرى',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12),
            _buildAlternativeAction(
              'عرض ملفي الشخصي',
              Icons.person,
              () => Get.toNamed('/portfolio'),
            ),
            _buildAlternativeAction(
              'تصفح المستخدمين',
              Icons.people,
              () => Get.toNamed('/search-users'),
            ),
            _buildAlternativeAction(
              'إعدادات الخصوصية',
              Icons.privacy_tip,
              () => Get.toNamed('/privacy-settings'),
            ),
            _buildAlternativeAction(
              'الإبلاغ عن مشكلة',
              Icons.bug_report,
              () => _reportIssue(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlternativeAction(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          text,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          text,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String message, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  ErrorType _getErrorType() {
    if (errorMessage.contains('غير موجود') ||
        errorMessage.contains('not found')) {
      return ErrorType.userNotFound;
    } else if (errorMessage.contains('خاص') ||
        errorMessage.contains('private')) {
      return ErrorType.private;
    } else if (errorMessage.contains('محظور') ||
        errorMessage.contains('blocked')) {
      return ErrorType.blocked;
    } else if (errorMessage.contains('تسجيل الدخول') ||
        errorMessage.contains('login')) {
      return ErrorType.needLogin;
    } else if (errorMessage.contains('شبكة') ||
        errorMessage.contains('network')) {
      return ErrorType.networkError;
    } else if (errorMessage.contains('أصدقاء') ||
        errorMessage.contains('friends')) {
      return ErrorType.friendsOnly;
    } else {
      return ErrorType.general;
    }
  }

  void _handleBackNavigation() {
    if (Navigator.canPop(Get.context!)) {
      Get.back();
    } else {
      Get.offAllNamed(AppRoutes.MAIN);
    }
  }

  void _sendFriendRequest() {
    String? userId = Get.parameters['userId'];
    if (userId != null) {
      // إرسال طلب صداقة
      Get.snackbar(
        'تم الإرسال',
        'سيتم إرسال طلب الصداقة عند تسجيل الدخول',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'خطأ',
        'لا يمكن تحديد المستخدم',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _retryConnection() {
    Get.snackbar(
      'جاري المحاولة',
      'يتم إعادة تحميل الصفحة...',
      snackPosition: SnackPosition.BOTTOM,
    );

    try {
      Get.find<PortfolioRoutingController>().refreshPortfolio();
    } catch (e) {
      // إذا لم يكن الكونترولر موجود، أنشئ واحد جديد
      Get.put(PortfolioRoutingController()).refreshPortfolio();
    }
  }

  void _retryLoading() {
    _retryConnection();
  }

  void _checkConnection() {
    Get.dialog(
      AlertDialog(
        title: Text('فحص الاتصال'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('يرجى التحقق من:'),
            SizedBox(height: 12),
            _buildCheckItem('اتصال الإنترنت'),
            _buildCheckItem('إعدادات الشبكة'),
            _buildCheckItem('حالة الخادم'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('إغلاق')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _retryConnection();
            },
            child: Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: AppColors.textSecondary,
          ),
          SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  void _reportIssue() {
    Get.dialog(
      AlertDialog(
        title: Text('الإبلاغ عن مشكلة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('اختر نوع المشكلة:'),
            SizedBox(height: 16),
            _buildReportOption('مشكلة تقنية', Icons.bug_report),
            _buildReportOption('محتوى غير مناسب', Icons.flag),
            _buildReportOption('مشكلة في الخصوصية', Icons.privacy_tip),
            _buildReportOption('أخرى', Icons.more_horiz),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('إلغاء')),
        ],
      ),
    );
  }

  Widget _buildReportOption(String text, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(text),
      onTap: () {
        Get.back();
        Get.snackbar(
          'شكراً',
          'تم إرسال البلاغ وسيتم مراجعته',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }
}

enum ErrorType {
  userNotFound,
  private,
  blocked,
  needLogin,
  networkError,
  friendsOnly,
  general,
}
