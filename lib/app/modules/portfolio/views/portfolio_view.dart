// lib/app/modules/portfolio/views/portfolio_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../../../models/user_model.dart';
import '../../../models/portfolio_model.dart';
import '../../../services/auth_service.dart';
import '../../home/widgets/posts_tab.dart';
import '../controllers/base_portfolio_controller.dart';
import '../controllers/user_post_controller.dart';
import '../widgets/timeline_widgets.dart';

class PortfolioView extends StatefulWidget {
  final String? userId;

  const PortfolioView({
    super.key,
    this.userId,
  });

  @override
  _PortfolioViewState createState() => _PortfolioViewState();
}

class _PortfolioViewState extends State<PortfolioView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers for each tab
  late UserPostsController userPostsController;
  late EducationController educationController;
  late ExperienceController experienceController;
  late ProjectsController projectsController;
  late SkillsController skillsController;
  late LanguagesController languagesController;
  late CertificatesController certificatesController;
  late ActivitiesController activitiesController;
  late HobbiesController hobbiesController;

  // State variables
  final RxBool _isLoading = true.obs;
  final RxBool _userExists = true.obs;
  final RxString _errorMessage = ''.obs;
  final RxString _targetUserId = ''.obs;

  final List<TabData> tabs = [
    TabData('المنشورات', Icons.post_add, 'student_posts'),
    TabData('التعليم', Icons.school, 'education'),
    TabData('الخبرات', Icons.work, 'experience'),
    TabData('المشاريع', Icons.lightbulb, 'projects'),
    TabData('المهارات', Icons.star, 'skills'),
    TabData('اللغات', Icons.language, 'languages'),
    TabData('الشهادات', Icons.card_membership, 'certificates'),
    TabData('الأنشطة', Icons.group_work, 'activities'),
    TabData('الهوايات', Icons.music_note, 'hobbies'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _checkUserExistence();
  }

  // دالة للتحقق من وجود المستخدم
  Future<void> _checkUserExistence() async {
    try {
      _isLoading.value = true;
      
      final authService = Get.find<AuthService>();
      final currentUserId = authService.currentUserId;
      
      // تحديد userId الهدف
      String targetUserId = (widget.userId ?? currentUserId)!;
      _targetUserId.value = targetUserId;
      
      // إذا كان userId فارغاً أو يساوي المستخدم الحالي، نعتبره موجوداً
      if (widget.userId == null || widget.userId == currentUserId) {
        _userExists.value = true;
        _initializeControllers(targetUserId);
        return;
      }

      // التحقق من وجود المستخدم في Firestore
      final userDoc = await _firestore.collection('users').doc(targetUserId).get();
      
      if (userDoc.exists) {
        _userExists.value = true;
        _initializeControllers(targetUserId);
      } else {
        _userExists.value = false;
        _errorMessage.value = 'المستخدم غير موجود';
      }
    } catch (e) {
      _userExists.value = false;
      _errorMessage.value = 'حدث خطأ أثناء تحميل الملف الشخصي';
      print('Error checking user existence: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // تهيئة الكنترولرز بعد التأكد من وجود المستخدم
  void _initializeControllers(String targetUserId) {
    // إزالة الكنترولرز القديمة إذا كانت موجودة
    _removeExistingControllers();

    // Initialize UserPostsController with the userId
    userPostsController = Get.put(
      UserPostsController(userId: targetUserId),
      tag: 'user_posts_$targetUserId',
    );

    // Initialize portfolio controllers مع تحديد userId
    educationController = Get.put(
      EducationController()..viewedUserId = targetUserId,
      tag: 'education_$targetUserId',
    );
    
    experienceController = Get.put(
      ExperienceController()..viewedUserId = targetUserId,
      tag: 'experience_$targetUserId',
    );
    
    projectsController = Get.put(
      ProjectsController()..viewedUserId = targetUserId,
      tag: 'projects_$targetUserId',
    );
    
    skillsController = Get.put(
      SkillsController()..viewedUserId = targetUserId,
      tag: 'skills_$targetUserId',
    );
    
    languagesController = Get.put(
      LanguagesController()..viewedUserId = targetUserId,
      tag: 'languages_$targetUserId',
    );
    
    certificatesController = Get.put(
      CertificatesController()..viewedUserId = targetUserId,
      tag: 'certificates_$targetUserId',
    );
    
    activitiesController = Get.put(
      ActivitiesController()..viewedUserId = targetUserId,
      tag: 'activities_$targetUserId',
    );
    
    hobbiesController = Get.put(
      HobbiesController()..viewedUserId = targetUserId,
      tag: 'hobbies_$targetUserId',
    );

    // تحميل البيانات بعد تهيئة الكنترولرز
    _loadControllersData();
  }

  // إزالة الكنترولرز القديمة
  void _removeExistingControllers() {
    try {
      final tags = [
        'user_posts_${widget.userId}',
        'education_${widget.userId}',
        'experience_${widget.userId}',
        'projects_${widget.userId}',
        'skills_${widget.userId}',
        'languages_${widget.userId}',
        'certificates_${widget.userId}',
        'activities_${widget.userId}',
        'hobbies_${widget.userId}',
      ];

      for (final tag in tags) {
        if (Get.isRegistered<UserPostsController>(tag: tag)) {
          Get.delete<UserPostsController>(tag: tag);
        }
        if (Get.isRegistered<EducationController>(tag: tag)) {
          Get.delete<EducationController>(tag: tag);
        }
        if (Get.isRegistered<ExperienceController>(tag: tag)) {
          Get.delete<ExperienceController>(tag: tag);
        }
        if (Get.isRegistered<ProjectsController>(tag: tag)) {
          Get.delete<ProjectsController>(tag: tag);
        }
        if (Get.isRegistered<SkillsController>(tag: tag)) {
          Get.delete<SkillsController>(tag: tag);
        }
        if (Get.isRegistered<LanguagesController>(tag: tag)) {
          Get.delete<LanguagesController>(tag: tag);
        }
        if (Get.isRegistered<CertificatesController>(tag: tag)) {
          Get.delete<CertificatesController>(tag: tag);
        }
        if (Get.isRegistered<ActivitiesController>(tag: tag)) {
          Get.delete<ActivitiesController>(tag: tag);
        }
        if (Get.isRegistered<HobbiesController>(tag: tag)) {
          Get.delete<HobbiesController>(tag: tag);
        }
      }
    } catch (e) {
      print('Error removing controllers: $e');
    }
  }

  // تحميل البيانات في الكنترولرز
  void _loadControllersData() {
    // تحميل بيانات المنشورات
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userPostsController.loadPosts();
    });

    // تحميل بيانات الـ portfolio بعد فترة بسيطة
    Future.delayed(Duration(milliseconds: 100), () {
      educationController.refreshItems();
      experienceController.refreshItems();
      projectsController.refreshItems();
      skillsController.refreshItems();
      languagesController.refreshItems();
      certificatesController.refreshItems();
      activitiesController.refreshItems();
      hobbiesController.refreshItems();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_isLoading.value) {
        return _buildLoadingState();
      }

      if (!_userExists.value) {
        return _buildErrorState();
      }

      return _buildPortfolioView();
    });
  }

  // واجهة التحميل
  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            SizedBox(height: 16),
            Text(
              'جاري تحميل الملف الشخصي...',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // واجهة الخطأ
  Widget _buildErrorState() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              SizedBox(height: 20),
              Text(
                _errorMessage.value,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'المستخدم الذي تحاول زيارته غير موجود أو لا يمكن الوصول إليه',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'العودة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // واجهة المحفظة الرئيسية
  Widget _buildPortfolioView() {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                title: Text(
                  'الملف الشخصي',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: AppColors.primary,
                floating: true,
                pinned: true,
                elevation: 3,
                shadowColor: Colors.black.withOpacity(0.3),
                expandedHeight: 220,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildProfileHeader(),
                ),
                actions: _buildAppBarActions(),
                bottom: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.7),
                  tabs: tabs
                      .map(
                        (tab) => Tab(
                          icon: Icon(tab.icon, size: 20),
                          text: tab.label,
                        ),
                      )
                      .toList(),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildStudentPostsTab(),
              _buildEducationTab(),
              _buildExperienceTab(),
              _buildProjectsTab(),
              _buildSkillsTab(),
              _buildLanguagesTab(),
              _buildCertificatesTab(),
              _buildActivitiesTab(),
              _buildHobbiesTab(),
            ],
          ),
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  // بناء أزرار AppBar مع التحقق من صلاحيات المستخدم
  List<Widget> _buildAppBarActions() {
    final authService = Get.find<AuthService>();
    final isCurrentUser = widget.userId == null || widget.userId == authService.currentUserId;

    if (!isCurrentUser) {
      return [];
    }

    return [
      IconButton(
        icon: Icon(Icons.edit),
        onPressed: () => Get.toNamed(AppRoutes.EDIT_PROFILE),
        tooltip: 'تعديل الملف الشخصي',
      ),
    ];
  }

  Widget _buildProfileHeader() {
    final authService = Get.find<AuthService>();

    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').doc(_targetUserId.value).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(radius: 40, backgroundColor: Colors.white.withOpacity(0.3)),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 150,
                        height: 20,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: 200,
                        height: 16,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                'تعذر تحميل بيانات المستخدم',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final user = UserModel.fromMap(userData, snapshot.data!.id);

        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  backgroundImage: user.photoURL != null
                      ? NetworkImage(user.photoURL!)
                      : null,
                  child: user.photoURL == null
                      ? Icon(Icons.person, size: 40, color: Colors.white)
                      : null,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user.fullName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (user.university != null || user.major != null)
                      Text(
                        "${user.university ?? ''} ${user.major != null ? '- ${user.major}' : ''}",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStudentPostsTab() {
    return PostsTab(controller: userPostsController, isTap: true,);
  }

  Widget _buildEducationTab() {
    return buildTimelineTab<EducationModel>(
      controller: educationController,
      itemBuilder: (education, index) => TimelineItemBuilder.buildEducationItem(
        education,
        index,
        educationController,
        Get.find<AuthService>(),
      ),
    );
  }

  Widget _buildExperienceTab() {
    return buildTimelineTab<ExperienceModel>(
      controller: experienceController,
      itemBuilder: (experience, index) =>
          TimelineItemBuilder.buildExperienceItem(
            experience,
            index,
            experienceController,
            Get.find<AuthService>(),
          ),
    );
  }

  Widget _buildProjectsTab() {
    return buildTimelineTab<ProjectModel>(
      controller: projectsController,
      itemBuilder: (project, index) => TimelineItemBuilder.buildProjectItem(
        project,
        index,
        projectsController,
        Get.find<AuthService>(),
      ),
    );
  }

  Widget _buildSkillsTab() {
    return buildTimelineTab<SkillModel>(
      controller: skillsController,
      itemBuilder: (skill, index) => TimelineItemBuilder.buildSkillItem(
        skill,
        index,
        skillsController,
        Get.find<AuthService>(),
      ),
    );
  }

  Widget _buildCertificatesTab() {
    return buildTimelineTab<CertificateModel>(
      controller: certificatesController,
      itemBuilder: (certificate, index) =>
          TimelineItemBuilder.buildCertificateItem(
            certificate,
            index,
            certificatesController,
            Get.find<AuthService>(),
          ),
    );
  }

  Widget _buildActivitiesTab() {
    return buildTimelineTab<ActivityModel>(
      controller: activitiesController,
      itemBuilder: (activity, index) => TimelineItemBuilder.buildActivityItem(
        activity,
        index,
        activitiesController,
        Get.find<AuthService>(),
      ),
    );
  }

  Widget _buildHobbiesTab() {
    return buildTimelineTab<HobbyModel>(
      controller: hobbiesController,
      itemBuilder: (hobby, index) =>
          TimelineItemBuilder.buildHobbyItem(
            hobby, 
            index, 
            hobbiesController,
            Get.find<AuthService>(),
          ),
    );
  }

  Widget _buildLanguagesTab() {
    return buildTimelineTab<LanguageModel>(
      controller: languagesController,
      itemBuilder: (language, index) => TimelineItemBuilder.buildLanguageItem(
        language,
        index,
        languagesController,
        Get.find<AuthService>(),
      ),
    );
  }

  // بناء زر الإضافة مع التحقق من الصلاحيات
  Widget _buildFloatingActionButton() {
    final authService = Get.find<AuthService>();
    final isCurrentUser = widget.userId == null || widget.userId == authService.currentUserId;

    if (!isCurrentUser) {
      return SizedBox.shrink();
    }

    return SizedBox(
      width: 48,
      height: 48,
      child: FloatingActionButton(
        onPressed: _showAddDialog,
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: CircleBorder(),
      ),
    );
  }

  void _showAddDialog() {
    String currentTabType = _getCurrentTabType();

    switch (currentTabType) {
      case 'student_posts':
        Get.toNamed(AppRoutes.ADD_POST);
        break;
      case 'education':
        Get.toNamed(
          AppRoutes.ADD_PORTFOLIO_ITEM,
          arguments: {'type': 'education'},
        );
        break;
      case 'experience':
        Get.toNamed(
          AppRoutes.ADD_PORTFOLIO_ITEM,
          arguments: {'type': 'experience'},
        );
        break;
      case 'projects':
        Get.toNamed(
          AppRoutes.ADD_PORTFOLIO_ITEM,
          arguments: {'type': 'projects'},
        );
        break;
      case 'skills':
        Get.toNamed(
          AppRoutes.ADD_PORTFOLIO_ITEM,
          arguments: {'type': 'skills'},
        );
        break;
      case 'languages':
        Get.toNamed(
          AppRoutes.ADD_PORTFOLIO_ITEM,
          arguments: {'type': 'languages'},
        );
        break;
      case 'certificates':
        Get.toNamed(
          AppRoutes.ADD_PORTFOLIO_ITEM,
          arguments: {'type': 'certificates'},
        );
        break;
      case 'activities':
        Get.toNamed(
          AppRoutes.ADD_PORTFOLIO_ITEM,
          arguments: {'type': 'activities'},
        );
        break;
      case 'hobbies':
        Get.toNamed(
          AppRoutes.ADD_PORTFOLIO_ITEM,
          arguments: {'type': 'hobbies'},
        );
        break;
      default:
        Get.toNamed(AppRoutes.ADD_POST);
    }
  }

  String _getCurrentTabType() {
    int currentIndex = _tabController.index;
    if (currentIndex >= 0 && currentIndex < tabs.length) {
      return tabs[currentIndex].type;
    }
    return 'student_posts';
  }
}

// Tab data class
class TabData {
  final String label;
  final IconData icon;
  final String type;

  TabData(this.label, this.icon, this.type);
}