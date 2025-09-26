import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../theme/app_theme.dart';
import '../controllers/gamification_controller.dart';

class GamificationView extends GetView<GamificationController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('نظام النقاط'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: controller.refreshData,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // User Stats Header
                _buildUserStatsHeader(),
                
                SizedBox(height: 20),
                
                // Progress Card
                _buildProgressCard(),
                
                SizedBox(height: 20),
                
                // Quick Stats
                _buildQuickStats(),
                
                SizedBox(height: 20),
                
                // Tabs
                DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      TabBar(
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textSecondary,
                        indicatorColor: AppColors.primary,
                        tabs: [
                          Tab(text: 'الإنجازات'),
                          Tab(text: 'الأوسمة'),
                          Tab(text: 'المتصدرون'),
                        ],
                      ),
                      
                      SizedBox(
                        height: 400,
                        child: TabBarView(
                          children: [
                            _buildAchievementsTab(),
                            _buildBadgesTab(),
                            _buildLeaderboardTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildUserStatsHeader() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // User Avatar and Info
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Icon(Icons.person, size: 30, color: Colors.white),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                          'المستوى ${controller.currentLevel.value}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                    Obx(() => Text(
                          controller.currentBadge.value,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        )),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Obx(() => Text(
                        '${controller.currentPoints.value}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                  Text(
                    'نقطة',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          SizedBox(height: 20),
          
          // Level Progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'التقدم للمستوى التالي',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  Obx(() => Text(
                        '${controller.getPointsForNextLevel()} نقطة متبقية',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      )),
                ],
              ),
              SizedBox(height: 8),
              Obx(() => LinearProgressIndicator(
                    value: controller.getProgressToNextLevel(),
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    borderRadius: BorderRadius.circular(4),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'كيف تحصل على النقاط؟',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16),
              ...[
                {'action': 'إكمال الملف الشخصي', 'points': 10},
                {'action': 'نشر منشور جديد', 'points': 5},
                {'action': 'إضافة مشروع', 'points': 8},
                {'action': 'كتابة تعليق', 'points': 2},
                {'action': 'الحصول على إعجاب', 'points': 1},
              ].map((item) => Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item['action'] as String,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        Text(
                          '+${item['points']} نقطة',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'الإنجازات',
              '${controller.unlockedAchievementsCount}/${controller.achievements.length}',
              Icons.emoji_events,
              AppColors.success,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'الأوسمة',
              '${controller.earnedBadgesCount}/${controller.badges.length}',
              Icons.military_tech,
              AppColors.warning,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Obx(() => _buildStatCard(
                  'الترتيب',
                  '#${controller.userRankPosition}',
                  Icons.leaderboard,
                  AppColors.info,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: controller.achievements.length,
      itemBuilder: (context, index) {
        final achievement = controller.achievements[index];
        return Card(
          margin: EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: achievement.isUnlocked
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.textHint.withOpacity(0.1),
              child: Icon(
                _getAchievementIcon(achievement.icon),
                color: achievement.isUnlocked ? AppColors.success : AppColors.textHint,
              ),
            ),
            title: Text(
              achievement.title,
              style: TextStyle(
                color: achievement.isUnlocked ? AppColors.textPrimary : AppColors.textHint,
                fontWeight: achievement.isUnlocked ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(achievement.description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (achievement.isUnlocked) Icon(Icons.check_circle, color: AppColors.success),
                SizedBox(width: 4),
                Text(
                  '+${achievement.points}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadgesTab() {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: controller.badges.length,
      itemBuilder: (context, index) {
        final badge = controller.badges[index];
        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getBadgeColor(badge.color).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.military_tech,
                    color: badge.isEarned ? _getBadgeColor(badge.color) : AppColors.textHint,
                    size: 24,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  badge.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: badge.isEarned ? AppColors.textPrimary : AppColors.textHint,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  badge.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeaderboardTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: controller.leaderboard.length,
      itemBuilder: (context, index) {
        final user = controller.leaderboard[index];
        final isCurrentUser = user.userId == Get.find<AuthService>().currentUserId;
        
        return Card(
          margin: EdgeInsets.only(bottom: 8),
          color: isCurrentUser ? AppColors.primary.withOpacity(0.1) : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getRankColor(user.rank),
              child: Text(
                '#${user.rank}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    user.name,
                    style: TextStyle(
                      fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (isCurrentUser)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'أنت',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Text('${user.badge} • المستوى ${user.level}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${user.points}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'نقطة',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getAchievementIcon(String iconName) {
    switch (iconName) {
      case 'post':
        return Icons.article;
      case 'profile':
        return Icons.person;
      case 'heart':
        return Icons.favorite;
      case 'education':
        return Icons.school;
      case 'work':
        return Icons.work;
      case 'project':
        return Icons.lightbulb;
      case 'level':
        return Icons.trending_up;
      default:
        return Icons.star;
    }
  }

  Color _getBadgeColor(String colorName) {
    switch (colorName) {
      case 'bronze':
        return Color(0xFFCD7F32);
      case 'silver':
        return Color(0xFFC0C0C0);
      case 'gold':
        return Color(0xFFFFD700);
      case 'platinum':
        return Color(0xFFE5E4E2);
      case 'diamond':
        return Color(0xFFB9F2FF);
      default:
        return AppColors.primary;
    }
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Color(0xFFFFD700); // Gold
    if (rank == 2) return Color(0xFFC0C0C0); // Silver
    if (rank == 3) return Color(0xFFCD7F32); // Bronze
    if (rank <= 10) return AppColors.primary;
    return AppColors.textSecondary;
  }
}