import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portefy/app/modules/portfolio/views/portfolio_routing.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';
import '../../../theme/app_theme.dart';
import '../views/portfolio_view.dart';
import '../views/public_portfolio_view.dart';
import '../views/portfolio_not_found_view.dart';

class PortfolioRoutingController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final UserService _userService = UserService();
  
  final RxBool isLoading = true.obs;
  final Rx<UserModel?> targetUser = Rx<UserModel?>(null);
  final RxString errorMessage = ''.obs;
  final RxBool isOwner = false.obs;
  final RxBool canViewPortfolio = false.obs;
  
  String? userId;

  @override
  void onInit() {
    super.onInit();
    userId = Get.parameters['userId'];
    checkPortfolioAccess();
  }

  Future<void> checkPortfolioAccess() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // إذا لم يتم تمرير userId، عرض ملف المستخدم الحالي
      if (userId == null || userId!.isEmpty) {
        if (_authService.currentUserId != null) {
          isOwner.value = true;
          canViewPortfolio.value = true;
          targetUser.value = _authService.appUser.value;
        } else {
          errorMessage.value = 'يجب تسجيل الدخول لعرض الملف الشخصي';
          canViewPortfolio.value = false;
        }
        return;
      }
      
      // التحقق من أن المستخدم المطلوب موجود
      UserModel? user = await _userService.getUserById(userId!);
      if (user == null) {
        errorMessage.value = 'المستخدم غير موجود';
        canViewPortfolio.value = false;
        return;
      }
      
      targetUser.value = user;
      
      // التحقق من أن هذا المستخدم هو صاحب الحساب
      isOwner.value = _authService.currentUserId == userId;
      
      // التحقق من إعدادات الخصوصية
      if (isOwner.value) {
        canViewPortfolio.value = true;
      } else {
        canViewPortfolio.value = await _checkPrivacySettings(user);
      }
      
    } catch (e) {
      errorMessage.value = 'حدث خطأ أثناء تحميل الملف الشخصي';
      canViewPortfolio.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _checkPrivacySettings(UserModel user) async {
    try {
      // التحقق من إعدادات الخصوصية للملف الشخصي
      if (user.portfolioPrivacy == null || user.portfolioPrivacy == 'public') {
        return true;
      }
      
      if (user.portfolioPrivacy == 'private') {
        return false;
      }
      
      if (user.portfolioPrivacy == 'friends') {
        // التحقق من أن المستخدم الحالي صديق
        return await _userService.areFriends(_authService.currentUserId!, userId!);
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  Widget buildPortfolioView() {
    return Obx(() {
      if (isLoading.value) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text(
                  'جاري تحميل الملف الشخصي...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      
      if (!canViewPortfolio.value || targetUser.value == null) {
        return PortfolioNotFoundView(
          errorMessage: errorMessage.value,
          isOwner: isOwner.value,
        );
      }
      
      if (isOwner.value) {
        return PortfolioView(); // الواجهة الكاملة لصاحب الحساب
      } else {
        return PublicPortfolioView(user: targetUser.value!); // الواجهة العامة للزوار
      }
    });
  }

  void refreshPortfolio() {
    checkPortfolioAccess();
  }
}

// خدمة المستخدمين
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> areFriends(String currentUserId, String otherUserId) async {
    try {
      // التحقق من وجود صداقة بين المستخدمين
      QuerySnapshot friendshipDoc = await _firestore
          .collection('friendships')
          .where('users', arrayContains: currentUserId)
          .get();

      for (var doc in friendshipDoc.docs) {
        List<String> users = List<String>.from(doc['users']);
        if (users.contains(otherUserId) && doc['status'] == 'accepted') {
          return true;
        }
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<List<UserModel>> searchUsers(String query, {int limit = 20}) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('searchKeywords', arrayContains: query.toLowerCase())
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }
}