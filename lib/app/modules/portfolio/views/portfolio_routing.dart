// lib/app/modules/portfolio/main_portfolio_router.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/pagination_service.dart';
import '../../../theme/app_theme.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../controllers/base_portfolio_controller.dart';
import '../controllers/public_base_controller.dart';
import 'portfolio_not_found_view.dart';
import 'portfolio_view.dart';
import 'public_portfolio_view.dart';


// هذا هو الملف الذي سيتم استدعاؤه من الروتات الرئيسية
class PortfolioRouter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // إنشاء controller للتوجيه
    final PortfolioRoutingController controller = Get.put(PortfolioRoutingController());
    
    return controller.buildPortfolioView();
  }
}

// Portfolio Routing Controller
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
        errorMessage.value = 'هذا الملف الشخصي خاص';
        return false;
      }
      
      if (user.portfolioPrivacy == 'friends') {
        // التحقق من أن المستخدم الحالي صديق
        String? currentUserId = _authService.currentUserId;
        if (currentUserId == null) {
          errorMessage.value = 'يجب تسجيل الدخول لعرض ملفات الأصدقاء';
          return false;
        }
        
        bool areFriends = await _userService.areFriends(currentUserId, userId!);
        if (!areFriends) {
          errorMessage.value = 'هذا الملف متاح للأصدقاء فقط';
          return false;
        }
        return true;
      }
      
      return false;
    } catch (e) {
      errorMessage.value = 'فشل فحص صلاحيات الوصول';
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

// خدمة المستخدمين المحدثة
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return UserModel.fromMap(data, doc.id);
      }
      return null;
    } catch (e) {
      print('خطأ في getUserById: $e');
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
      print('خطأ في areFriends: $e');
      return false;
    }
  }

  Future<List<UserModel>> searchUsers(String query, {int limit = 20}) async {
    try {
      // البحث في الاسم الكامل
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('fullName', isGreaterThanOrEqualTo: query)
          .where('fullName', isLessThan: query + '\uf8ff')
          .limit(limit)
          .get();

      List<UserModel> results = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // إذا لم نجد نتائج، نبحث في البريد الإلكتروني
      if (results.isEmpty && query.contains('@')) {
        QuerySnapshot emailSnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: query.toLowerCase())
            .get();
        
        results.addAll(emailSnapshot.docs
            .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
      }

      return results;
    } catch (e) {
      print('خطأ في searchUsers: $e');
      return [];
    }
  }

  Future<void> updateUserLastSeen(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('خطأ في updateUserLastSeen: $e');
    }
  }

  Future<void> updateUserPrivacySettings({
    required String userId,
    required String portfolioPrivacy,
    required bool showEmail,
    required bool showPhone,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'portfolioPrivacy': portfolioPrivacy,
        'showEmail': showEmail,
        'showPhone': showPhone,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'فشل تحديث إعدادات الخصوصية: ${e.toString()}';
    }
  }

  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      Map<String, dynamic> stats = {};
      
      // عدد الأصدقاء
      QuerySnapshot friendsSnapshot = await _firestore
          .collection('friendships')
          .where('users', arrayContains: userId)
          .where('status', isEqualTo: 'accepted')
          .get();
      stats['friends'] = friendsSnapshot.docs.length;
      
      // عدد المتابعين (إذا كان لديك نظام متابعة)
      QuerySnapshot followersSnapshot = await _firestore
          .collection('follows')
          .where('followedId', isEqualTo: userId)
          .get();
      stats['followers'] = followersSnapshot.docs.length;
      
      // عدد المتابَعين
      QuerySnapshot followingSnapshot = await _firestore
          .collection('follows')
          .where('followerId', isEqualTo: userId)
          .get();
      stats['following'] = followingSnapshot.docs.length;
      
      return stats;
    } catch (e) {
      return {'friends': 0, 'followers': 0, 'following': 0};
    }
  }
}

// تحديث نموذج المستخدم ليدعم إعدادات الخصوصية
extension UserModelExtended on UserModel {
  String get portfolioPrivacy {
    // افتراضياً يكون الملف عام إذا لم يتم تحديد إعداد
    return 'public'; // يجب إضافة هذا الحقل للنموذج الأساسي
  }
  
  bool get showEmail {
    // افتراضياً لا يظهر البريد الإلكتروني
    return false; // يجب إضافة هذا الحقل للنموذج الأساسي
  }
  
  bool get showPhone {
    // افتراضياً لا يظهر رقم الهاتف
    return false; // يجب إضافة هذا الحقل للنموذج الأساسي
  }
  
  DateTime? get lastSeen {
    // آخر مرة كان فيها المستخدم نشطاً
    return null; // يجب إضافة هذا الحقل للنموذج الأساسي
  }
}

// إضافة هذه الروتات في main.dart أو routes.dart
class PortfolioRoutes {
  static const String portfolio = '/portfolio';
  static const String userProfile = '/profile/:userId';
  static const String searchUsers = '/search-users';
  static const String privacySettings = '/privacy-settings';
  static const String editProfile = '/edit-profile';
  static const String addPortfolioItem = '/add-portfolio-item';
  static const String editPortfolioItem = '/edit-portfolio-item';

  static List<GetPage> getRoutes() {
    return [
      // الملف الشخصي للمستخدم الحالي
      GetPage(
        name: portfolio,
        page: () => PortfolioRouter(),
        binding: PortfolioBinding(),
      ),
      
      // عرض ملف مستخدم آخر
      GetPage(
        name: userProfile,
        page: () => PortfolioRouter(),
        binding: PortfolioBinding(),
      ),
      
      // البحث عن المستخدمين
      GetPage(
        name: searchUsers,
        page: () => UserSearchView(),
        binding: BindingsBuilder(() {
          Get.lazyPut(() => UserSearchController());
        }),
      ),
      
      // إعدادات الخصوصية
      GetPage(
        name: privacySettings,
        page: () => PrivacySettingsView(),
        binding: BindingsBuilder(() {
          Get.lazyPut(() => PrivacySettingsController());
        }),
      ),
      
      // تعديل الملف الشخصي
      GetPage(
        name: editProfile,
        page: () => EditProfileView(),
        binding: BindingsBuilder(() {
          Get.lazyPut(() => EditProfileController());
        }),
      ),
      
      // إضافة عنصر جديد للملف الشخصي
      GetPage(
        name: addPortfolioItem,
        page: () => AddPortfolioItemView(),
        binding: BindingsBuilder(() {
          Get.lazyPut(() => AddPortfolioItemController());
        }),
      ),
      
      // تعديل عنصر في الملف الشخصي
      GetPage(
        name: editPortfolioItem,
        page: () => EditPortfolioItemView(),
        binding: BindingsBuilder(() {
          Get.lazyPut(() => EditPortfolioItemController());
        }),
      ),
    ];
  }
}

// Portfolio Binding
class PortfolioBinding extends Bindings {
  @override
  void dependencies() {
    // Portfolio Controllers
    Get.lazyPut(() => EducationController());
    Get.lazyPut(() => ExperienceController());
    Get.lazyPut(() => ProjectsController());
    Get.lazyPut(() => SkillsController());
    Get.lazyPut(() => LanguagesController());
    Get.lazyPut(() => CertificatesController());
    Get.lazyPut(() => ActivitiesController());
    Get.lazyPut(() => HobbiesController());
    
    // Services
    Get.lazyPut(() => UserService());
    Get.lazyPut(() => PaginationService());
    Get.lazyPut(() => FriendshipService());
  }
}

// واجهة البحث عن المستخدمين
class UserSearchView extends StatefulWidget {
  @override
  _UserSearchViewState createState() => _UserSearchViewState();
}

class _UserSearchViewState extends State<UserSearchView> {
  final TextEditingController _searchController = TextEditingController();
  final RxList<UserModel> searchResults = <UserModel>[].obs;
  final RxBool isSearching = false.obs;
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text('البحث عن المستخدمين'),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildSearchResults(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'ابحث عن المستخدمين...',
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    searchResults.clear();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Expanded(
      child: Obx(() {
        if (isSearching.value) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (searchResults.isEmpty && _searchController.text.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 80,
                  color: AppColors.textHint,
                ),
                SizedBox(height: 16),
                Text(
                  'لا توجد نتائج',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        if (searchResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people,
                  size: 80,
                  color: AppColors.textHint,
                ),
                SizedBox(height: 16),
                Text(
                  'ابدأ البحث عن المستخدمين',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: searchResults.length,
          itemBuilder: (context, index) {
            final user = searchResults[index];
            return _buildUserCard(user);
          },
        );
      }),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          backgroundImage: user.photoURL != null 
              ? NetworkImage(user.photoURL!) 
              : null,
          child: user.photoURL == null 
              ? Icon(Icons.person, color: AppColors.primary)
              : null,
        ),
        title: Text(
          user.fullName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user.university != null || user.major != null) ...[
              SizedBox(height: 4),
              Text(
                "${user.university ?? ''} ${user.major != null ? '- ${user.major}' : ''}",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
            if (user.city != null) ...[
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                  SizedBox(width: 4),
                  Text(
                    user.city!,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        onTap: () {
          Get.toNamed('/profile/${user.id}');
        },
      ),
    );
  }

  void _onSearchChanged(String query) {
    if (query.length < 2) {
      searchResults.clear();
      return;
    }

    _performSearch(query);
  }

  Future<void> _performSearch(String query) async {
    try {
      isSearching.value = true;
      List<UserModel> results = await _userService.searchUsers(query);
      searchResults.assignAll(results);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل البحث: ${e.toString()}');
    } finally {
      isSearching.value = false;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// إضافة Controllers للواجهات الجديدة
class UserSearchController extends GetxController {
  // يمكن إضافة منطق إضافي هنا
}

class PrivacySettingsController extends GetxController {
  // سيتم تطوير هذا في ملف منفصل
}

class EditProfileController extends GetxController {
  // سيتم تطوير هذا في ملف منفصل
}

class AddPortfolioItemController extends GetxController {
  // سيتم تطوير هذا في ملف منفصل
}

class EditPortfolioItemController extends GetxController {
  // سيتم تطوير هذا في ملف منفصل
}

// واجهات مؤقتة (يجب إنشاؤها في ملفات منفصلة)
class PrivacySettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إعدادات الخصوصية')),
      body: Center(child: Text('قيد التطوير')),
    );
  }
}

class EditProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تعديل الملف الشخصي')),
      body: Center(child: Text('قيد التطوير')),
    );
  }
}

class AddPortfolioItemView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إضافة عنصر جديد')),
      body: Center(child: Text('قيد التطوير')),
    );
  }
}

class EditPortfolioItemView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تعديل العنصر')),
      body: Center(child: Text('قيد التطوير')),
    );
  }
}