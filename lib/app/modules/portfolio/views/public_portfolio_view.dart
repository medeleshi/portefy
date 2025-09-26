import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portefy/app/modules/portfolio/views/portfolio_routing.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../../../models/user_model.dart';
import '../../../models/portfolio_model.dart';
import '../../../services/auth_service.dart';
import '../controllers/public_base_controller.dart';
import 'portfolio_view.dart';

class PublicPortfolioView extends StatefulWidget {
  final UserModel user;

  const PublicPortfolioView({Key? key, required this.user}) : super(key: key);

  @override
  _PublicPortfolioViewState createState() => _PublicPortfolioViewState();
}

class _PublicPortfolioViewState extends State<PublicPortfolioView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late PublicPortfolioController controller;
  final AuthService _authService = Get.find<AuthService>();

  final List<TabData> tabs = [
    TabData('نبذة', Icons.person, 'overview'),
    TabData('التعليم', Icons.school, 'education'),
    TabData('الخبرات', Icons.work, 'experience'),
    TabData('المشاريع', Icons.lightbulb, 'projects'),
    TabData('المهارات', Icons.star, 'skills'),
    TabData('الشهادات', Icons.card_membership, 'certificates'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    controller = Get.put(
      PublicPortfolioController(widget.user.id),
      tag: widget.user.id,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    Get.delete<PublicPortfolioController>(tag: widget.user.id);
    super.dispose();
  }

  // دالة التعامل مع الزر الرجوع
  void _handleBackNavigation() {
    final context = Get.context;
    if (context != null && Navigator.canPop(context)) {
      Get.back();
    } else {
      // إذا لم يكن هناك شاشة سابقة، ننتقل إلى الشاشة الرئيسية
      Get.offAllNamed(AppRoutes.MAIN);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleBackNavigation();
        return false; // منع السلوك الافتراضي للزر الرجوع
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor: AppColors.primary,
                expandedHeight: 280,
                floating: false,
                pinned: true,
                elevation: 3,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildProfileHeader(),
                ),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: _handleBackNavigation,
                ),
                actions: [_buildActionMenu()],
                bottom: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.7),
                  tabs: tabs
                      .map(
                        (tab) =>
                            Tab(icon: Icon(tab.icon, size: 20), text: tab.label),
                      )
                      .toList(),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildEducationTab(),
              _buildExperienceTab(),
              _buildProjectsTab(),
              _buildSkillsTab(),
              _buildCertificatesTab(),
            ],
          ),
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  backgroundImage: widget.user.photoURL != null
                      ? NetworkImage(widget.user.photoURL!)
                      : null,
                  child: widget.user.photoURL == null
                      ? Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.fullName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    if (widget.user.university != null ||
                        widget.user.major != null)
                      Text(
                        "${widget.user.university ?? ''} ${widget.user.major != null ? '- ${widget.user.major}' : ''}",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    SizedBox(height: 8),
                    if (widget.user.city != null)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            widget.user.city!,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 12),
                    _buildConnectionStatus(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Obx(() {
      return Row(
        children: [
          // Portfolio completion indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, color: Colors.green, size: 16),
                SizedBox(width: 4),
                Text(
                  '${controller.completionPercentage.value}% مكتمل',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          // Connection status
          if (controller.connectionStatus.value.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getConnectionColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                controller.connectionStatus.value,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      );
    });
  }

  Color _getConnectionColor() {
    switch (controller.connectionStatus.value) {
      case 'صديق':
        return Colors.green;
      case 'طلب صداقة مرسل':
        return Colors.orange;
      case 'طلب صداقة مستقبل':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildActionMenu() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.white),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'share',
          child: Row(
            children: [
              Icon(Icons.share, size: 20),
              SizedBox(width: 8),
              Text('مشاركة الملف الشخصي'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'report',
          child: Row(
            children: [
              Icon(Icons.flag, size: 20),
              SizedBox(width: 8),
              Text('إبلاغ'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'block',
          child: Row(
            children: [
              Icon(Icons.block, size: 20),
              SizedBox(width: 8),
              Text('حظر'),
            ],
          ),
        ),
      ],
      onSelected: (value) => _handleAction(value),
    );
  }

  Widget _buildFloatingActionButton() {
    if (_authService.currentUserId == null) return SizedBox.shrink();

    return Obx(() {
      String status = controller.connectionStatus.value;
      IconData icon;
      Color color;
      VoidCallback? onPressed;

      switch (status) {
        case 'غير متصل':
          icon = Icons.person_add;
          color = AppColors.primary;
          onPressed = () => controller.sendFriendRequest();
          break;
        case 'طلب صداقة مرسل':
          icon = Icons.hourglass_empty;
          color = Colors.orange;
          onPressed = null;
          break;
        case 'طلب صداقة مستقبل':
          icon = Icons.person_add_alt;
          color = Colors.blue;
          onPressed = () => _showFriendRequestDialog();
          break;
        case 'صديق':
          icon = Icons.message;
          color = Colors.green;
          onPressed = () => _startChat();
          break;
        default:
          return SizedBox.shrink();
      }

      return SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          onPressed: onPressed,
          child: Icon(icon, color: Colors.white),
          backgroundColor: color,
          elevation: 6,
        ),
      );
    });
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatisticsCards(),
          SizedBox(height: 20),
          _buildAboutSection(),
          SizedBox(height: 20),
          _buildContactInfoSection(),
          SizedBox(height: 20),
          _buildRecentActivitySection(),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Obx(() {
      return GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        childAspectRatio: 1.5,
        children: [
          _buildStatCard(
            'المشاريع',
            controller.stats['projects'] ?? 0,
            Icons.lightbulb,
            AppColors.primary,
          ),
          _buildStatCard(
            'الخبرات',
            controller.stats['experience'] ?? 0,
            Icons.work,
            AppColors.secondary,
          ),
          _buildStatCard(
            'المهارات',
            controller.stats['skills'] ?? 0,
            Icons.star,
            AppColors.accent,
          ),
          _buildStatCard(
            'الشهادات',
            controller.stats['certificates'] ?? 0,
            Icons.card_membership,
            AppColors.success,
          ),
        ],
      );
    });
  }

  Widget _buildStatCard(String title, int count, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    if (widget.user.bio == null || widget.user.bio!.isEmpty) {
      return SizedBox.shrink();
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'نبذة شخصية',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              widget.user.bio!,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.contact_mail, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'معلومات التواصل',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (widget.user.showEmail && widget.user.email.isNotEmpty)
              _buildContactItem(
                Icons.email,
                'البريد الإلكتروني',
                widget.user.email,
              ),
            if (widget.user.showPhone && widget.user.phone != null)
              _buildContactItem(Icons.phone, 'الهاتف', widget.user.phone!),
            if (widget.user.city != null)
              _buildContactItem(
                Icons.location_on,
                'المدينة',
                widget.user.city!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'النشاط الأخير',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'آخر تحديث: ${_formatLastSeen(widget.user.lastSeen)}',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationTab() {
    return _buildPublicTimelineTab<EducationModel>(
      controller: controller.educationController,
      itemBuilder: (education, index) => PublicTimelineItem(
        title: '${education.degree} في ${education.fieldOfStudy}',
        subtitle: education.institution,
        period:
            '${education.startDate.year} - ${education.isCurrent ? 'الآن' : education.endDate?.year ?? ''}',
        description: education.description,
        icon: Icons.school,
        color: AppColors.primary,
      ),
      emptyMessage: 'لا توجد معلومات تعليمية',
    );
  }

  Widget _buildExperienceTab() {
    return _buildPublicTimelineTab<ExperienceModel>(
      controller: controller.experienceController,
      itemBuilder: (experience, index) => PublicTimelineItem(
        title: experience.position,
        subtitle: experience.company,
        period:
            '${experience.startDate.year} - ${experience.isCurrent ? 'الآن' : experience.endDate?.year ?? ''}',
        description: experience.description,
        icon: Icons.work,
        color: AppColors.secondary,
      ),
      emptyMessage: 'لا توجد خبرات مهنية',
    );
  }

  Widget _buildProjectsTab() {
    return _buildPublicTimelineTab<ProjectModel>(
      controller: controller.projectsController,
      itemBuilder: (project, index) => PublicTimelineItem(
        title: project.title,
        subtitle: project.description,
        period: project.isCompleted ? 'مكتمل' : 'قيد التنفيذ',
        description: project.description,
        icon: Icons.lightbulb,
        color: AppColors.accent,
      ),
      emptyMessage: 'لا توجد مشاريع',
    );
  }

  Widget _buildSkillsTab() {
    return _buildPublicListTab<SkillModel>(
      controller: controller.skillsController,
      itemBuilder: (skill, index) => Card(
        margin: EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.info.withOpacity(0.1),
            child: Icon(Icons.star, color: AppColors.info),
          ),
          title: Text(
            skill.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 6),
              Text(skill.category, style: TextStyle(fontSize: 12)),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: skill.level / 5.0,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                borderRadius: BorderRadius.circular(10),
              ),
              SizedBox(height: 4),
              Text(
                '${skill.level}/5',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
      emptyMessage: 'لا توجد مهارات',
    );
  }

  Widget _buildCertificatesTab() {
    return _buildPublicTimelineTab<CertificateModel>(
      controller: controller.certificatesController,
      itemBuilder: (certificate, index) => PublicTimelineItem(
        title: certificate.name,
        subtitle: certificate.issuer,
        period: 'صادرة في: ${certificate.issueDate.year}',
        description: certificate.description,
        icon: Icons.card_membership,
        color: AppColors.success,
        isExpired: certificate.isExpired,
        isExpiringSoon: certificate.isExpiringSoon,
      ),
      emptyMessage: 'لا توجد شهادات',
    );
  }

  Widget _buildPublicTimelineTab<T extends PortfolioItem>({
    required PublicBaseController<T> controller,
    required PublicTimelineItem Function(T, int) itemBuilder,
    required String emptyMessage,
  }) {
    return Obx(() {
      if (controller.isLoading.value && controller.items.isEmpty) {
        return Center(child: CircularProgressIndicator());
      }

      if (controller.items.isEmpty) {
        return _buildEmptyState(emptyMessage);
      }

      return RefreshIndicator(
        onRefresh: controller.refreshItems,
        child: PublicTimelineView(
          items: controller.items.asMap().entries.map((entry) {
            return itemBuilder(entry.value, entry.key);
          }).toList(),
        ),
      );
    });
  }

  Widget _buildPublicListTab<T extends PortfolioItem>({
    required PublicBaseController<T> controller,
    required Widget Function(T, int) itemBuilder,
    required String emptyMessage,
  }) {
    return Obx(() {
      if (controller.isLoading.value && controller.items.isEmpty) {
        return Center(child: CircularProgressIndicator());
      }

      if (controller.items.isEmpty) {
        return _buildEmptyState(emptyMessage);
      }

      return RefreshIndicator(
        onRefresh: controller.refreshItems,
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: controller.items.length,
          itemBuilder: (context, index) {
            return itemBuilder(controller.items[index], index);
          },
        ),
      );
    });
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: AppColors.textHint),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _handleAction(String action) {
    switch (action) {
      case 'share':
        _shareProfile();
        break;
      case 'report':
        _reportUser();
        break;
      case 'block':
        _blockUser();
        break;
    }
  }

  void _shareProfile() {
    // Share profile functionality
    Get.snackbar('مشاركة', 'تم نسخ رابط الملف الشخصي');
  }

  void _reportUser() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'إبلاغ عن المستخدم',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('سبب الإبلاغ:'),
            // Add report reasons here
          ],
        ),
      ),
    );
  }

  void _blockUser() {
    Get.dialog(
      AlertDialog(
        title: Text('حظر المستخدم'),
        content: Text('هل أنت متأكد من حظر ${widget.user.fullName}؟'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('إلغاء')),
          TextButton(
            onPressed: () {
              controller.blockUser();
              Get.back();
            },
            child: Text('حظر'),
          ),
        ],
      ),
    );
  }

  void _showFriendRequestDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('طلب صداقة'),
        content: Text('${widget.user.fullName} أرسل لك طلب صداقة'),
        actions: [
          TextButton(
            onPressed: () {
              controller.rejectFriendRequest();
              Get.back();
            },
            child: Text('رفض'),
          ),
          TextButton(
            onPressed: () {
              controller.acceptFriendRequest();
              Get.back();
            },
            child: Text('قبول'),
          ),
        ],
      ),
    );
  }

  void _startChat() {
    Get.toNamed('/chat', arguments: {'userId': widget.user.id});
  }

  String _formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return 'غير محدد';

    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'منذ لحظات';
    } else if (difference.inHours < 1) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inDays < 1) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${lastSeen.day}/${lastSeen.month}/${lastSeen.year}';
    }
  }
}

// Public Timeline Item class (without edit/delete actions)
class PublicTimelineItem {
  final String title;
  final String subtitle;
  final String period;
  final String? description;
  final IconData icon;
  final Color color;
  final bool isExpired;
  final bool isExpiringSoon;

  PublicTimelineItem({
    required this.title,
    required this.subtitle,
    required this.period,
    this.description,
    required this.icon,
    required this.color,
    this.isExpired = false,
    this.isExpiringSoon = false,
  });
}

// Public Timeline View
class PublicTimelineView extends StatelessWidget {
  final List<PublicTimelineItem> items;

  const PublicTimelineView({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return PublicTimelineElement(
          item: item,
          isFirst: index == 0,
          isLast: index == items.length - 1,
        );
      },
    );
  }
}

// Public Timeline Element (read-only)
class PublicTimelineElement extends StatelessWidget {
  final PublicTimelineItem item;
  final bool isFirst;
  final bool isLast;

  const PublicTimelineElement({
    Key? key,
    required this.item,
    required this.isFirst,
    required this.isLast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline line and marker
          Container(
            width: 40,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: item.color.withOpacity(0.5),
                    ),
                  )
                else
                  SizedBox(height: 20),

                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: item.color,
                    boxShadow: [
                      BoxShadow(
                        color: item.color.withOpacity(0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(item.icon, size: 12, color: Colors.white),
                ),

                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: item.color.withOpacity(0.5),
                    ),
                  )
                else
                  SizedBox(height: 20),
              ],
            ),
          ),

          SizedBox(width: 16),

          // Content
          Expanded(
            child: Card(
              margin: EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: item.isExpired
                        ? AppColors.error.withOpacity(0.5)
                        : item.isExpiringSoon
                            ? AppColors.warning.withOpacity(0.5)
                            : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      if (item.description != null) ...[
                        SizedBox(height: 8),
                        Text(
                          item.description!,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: item.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.period,
                          style: TextStyle(
                            fontSize: 12,
                            color: item.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}