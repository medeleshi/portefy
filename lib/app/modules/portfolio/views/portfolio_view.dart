// lib/app/modules/portfolio/views/portfolio_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  }); // Optional userId for viewing other users' portfolios

  @override
  _PortfolioViewState createState() => _PortfolioViewState();
}

class _PortfolioViewState extends State<PortfolioView>
    with TickerProviderStateMixin {
  late TabController _tabController;

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

    // Initialize UserPostsController with the userId
    userPostsController = Get.put(
      UserPostsController(userId: widget.userId),
      tag: widget.userId ?? 'current_user',
    );

    // Initialize controllers
    educationController = Get.put(EducationController());
    experienceController = Get.put(ExperienceController());
    projectsController = Get.put(ProjectsController());
    skillsController = Get.put(SkillsController());
    languagesController = Get.put(LanguagesController());
    certificatesController = Get.put(CertificatesController());
    activitiesController = Get.put(ActivitiesController());
    hobbiesController = Get.put(HobbiesController());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                actions: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => Get.toNamed(AppRoutes.EDIT_PROFILE),
                    tooltip: 'إعدادات الخصوصية',
                  ),
                ],
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

  Widget _buildProfileHeader() {
    final authService = Get.find<AuthService>();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Obx(() {
        UserModel? user = authService.appUser.value;
        if (user == null) return SizedBox.shrink();

        return Row(
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
                  // SizedBox(height: 8),
                  // Container(
                  //   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white.withOpacity(0.2),
                  //     borderRadius: BorderRadius.circular(16),
                  //   ),
                  //   child: Row(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       Icon(Icons.star, color: Colors.amber, size: 16),
                  //       SizedBox(width: 4),
                  //       Text(
                  //         '${user.points} نقطة',
                  //         style: TextStyle(
                  //           color: Colors.white,
                  //           fontWeight: FontWeight.w500,
                  //           fontSize: 12,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStudentPostsTab() {
    return PostsTab(controller: userPostsController);
  }

  Widget _buildEducationTab() {
    return buildTimelineTab<EducationModel>(
      controller: educationController,
      itemBuilder: (education, index) => TimelineItemBuilder.buildEducationItem(
        education,
        index,
        educationController,
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
      ),
    );
  }

  Widget _buildSkillsTab() {
    return buildTimelineTab<SkillModel>(
      controller: skillsController,
      itemBuilder: (skill, index) =>
          TimelineItemBuilder.buildSkillItem(skill, index, skillsController),
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
      ),
    );
  }

  Widget _buildHobbiesTab() {
    return buildTimelineTab<HobbyModel>(
      controller: hobbiesController,
      itemBuilder: (hobby, index) =>
          TimelineItemBuilder.buildHobbyItem(hobby, index, hobbiesController),
    );
  }

  Widget _buildLanguagesTab() {
    return buildTimelineTab<LanguageModel>(
      controller: languagesController,
      itemBuilder: (language, index) => TimelineItemBuilder.buildLanguageItem(
        language,
        index,
        languagesController,
      ),
    );
  }

  Widget _buildFloatingActionButton() {
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
