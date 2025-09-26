import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';
import '../../../widgets/points_notification_widget.dart';

class GamificationController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final UserService _userService = UserService();

  // Observables
  final RxBool isLoading = false.obs;
  final RxInt currentPoints = 0.obs;
  final RxInt currentLevel = 1.obs;
  final RxString currentBadge = 'مبتدئ'.obs;
  final RxList<Achievement> achievements = <Achievement>[].obs;
  final RxList<Badge> badges = <Badge>[].obs;
  final RxList<UserRanking> leaderboard = <UserRanking>[].obs;

  // Point system configuration
  final Map<String, int> pointsConfig = {
    'complete_profile': 10,
    'add_post': 5,
    'receive_like': 1,
    'give_like': 1,
    'receive_comment': 1,
    'comment_post': 2,
    'add_education': 5,
    'add_experience': 5,
    'add_project': 8,
    'add_skill': 3,
    'add_language': 3,
    'daily_login': 2,
    'share_post': 3,
    'complete_cv': 10,
    'first_login': 5,
  };

  // Levels configuration
  final Map<int, String> levelNames = {
    1: 'مبتدئ',
    2: 'متعلم',
    3: 'متقدم',
    4: 'خبير',
    5: 'محترف',
    6: 'أسطورة',
  };

  final Map<int, int> levelRequirements = {
    1: 0,
    2: 50,
    3: 150,
    4: 300,
    5: 500,
    6: 1000,
  };

  @override
  void onInit() {
    super.onInit();
    loadGamificationData();
  }

  // Load gamification data
  Future<void> loadGamificationData() async {
    try {
      isLoading.value = true;
      
      UserModel? currentUser = _authService.appUser.value;
      if (currentUser == null) return;

      currentPoints.value = currentUser.points!;
      _updateLevelAndBadge();
      _generateAchievements();
      _generateBadges();
      await _loadLeaderboard();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحميل بيانات التحفيز');
    } finally {
      isLoading.value = false;
    }
  }

  // Update level and badge based on points
  void _updateLevelAndBadge() {
    int points = currentPoints.value;
    
    // Calculate level
    int level = 1;
    for (int i = levelRequirements.keys.length; i >= 1; i--) {
      if (points >= levelRequirements[i]!) {
        level = i;
        break;
      }
    }
    
    currentLevel.value = level;
    currentBadge.value = levelNames[level] ?? 'مبتدئ';
  }

  // Generate achievements
  void _generateAchievements() {
    achievements.assignAll([
      Achievement(
        id: 'first_post',
        title: 'أول منشور',
        description: 'نشر أول منشور لك',
        icon: 'post',
        points: 5,
        isUnlocked: currentPoints.value > 0,
        unlockedAt: DateTime.now(),
      ),
      Achievement(
        id: 'profile_complete',
        title: 'ملف مكتمل',
        description: 'إكمال الملف الشخصي',
        icon: 'profile',
        points: 10,
        isUnlocked: currentPoints.value >= 10,
        unlockedAt: DateTime.now(),
      ),
      Achievement(
        id: 'social_butterfly',
        title: 'فراشة اجتماعية',
        description: 'الحصول على 50 إعجاب',
        icon: 'heart',
        points: 25,
        isUnlocked: currentPoints.value >= 50,
        unlockedAt: DateTime.now(),
      ),
      Achievement(
        id: 'scholar',
        title: 'طالب علم',
        description: 'إضافة 5 عناصر تعليمية',
        icon: 'education',
        points: 25,
        isUnlocked: currentPoints.value >= 25,
        unlockedAt: DateTime.now(),
      ),
      Achievement(
        id: 'experienced',
        title: 'خبير',
        description: 'إضافة 3 خبرات عمل',
        icon: 'work',
        points: 15,
        isUnlocked: currentPoints.value >= 15,
        unlockedAt: DateTime.now(),
      ),
      Achievement(
        id: 'project_master',
        title: 'سيد المشاريع',
        description: 'إضافة 10 مشاريع',
        icon: 'project',
        points: 80,
        isUnlocked: currentPoints.value >= 80,
        unlockedAt: DateTime.now(),
      ),
      Achievement(
        id: 'level_up',
        title: 'ترقية!',
        description: 'الوصول للمستوى الثاني',
        icon: 'level',
        points: 50,
        isUnlocked: currentLevel.value >= 2,
        unlockedAt: DateTime.now(),
      ),
    ]);
  }

  // Generate badges
  void _generateBadges() {
    badges.assignAll([
      Badge(
        id: 'newcomer',
        title: 'وافد جديد',
        description: 'انضم للتطبيق',
        color: 'bronze',
        isEarned: true,
        earnedAt: DateTime.now().subtract(Duration(days: 7)),
      ),
      Badge(
        id: 'active_user',
        title: 'مستخدم نشط',
        description: 'استخدم التطبيق لمدة أسبوع',
        color: 'silver',
        isEarned: currentPoints.value >= 20,
        earnedAt: DateTime.now(),
      ),
      Badge(
        id: 'content_creator',
        title: 'منشئ محتوى',
        description: 'نشر 10 منشورات',
        color: 'gold',
        isEarned: currentPoints.value >= 50,
        earnedAt: DateTime.now(),
      ),
      Badge(
        id: 'helper',
        title: 'مساعد',
        description: 'كتابة 50 تعليق',
        color: 'platinum',
        isEarned: currentPoints.value >= 100,
        earnedAt: DateTime.now(),
      ),
      Badge(
        id: 'influencer',
        title: 'مؤثر',
        description: 'الحصول على 100 إعجاب',
        color: 'diamond',
        isEarned: currentPoints.value >= 200,
        earnedAt: DateTime.now(),
      ),
    ]);
  }

  // Load leaderboard
  Future<void> _loadLeaderboard() async {
    try {
      // In a real implementation, you would fetch this from the server
      // For now, we'll create mock data
      leaderboard.assignAll([
        UserRanking(
          userId: '1',
          name: 'أحمد علي',
          points: 1250,
          level: 6,
          badge: 'أسطورة',
          rank: 1,
          avatar: null,
        ),
        UserRanking(
          userId: '2',
          name: 'فاطمة محمد',
          points: 950,
          level: 5,
          badge: 'محترف',
          rank: 2,
          avatar: null,
        ),
        UserRanking(
          userId: '3',
          name: 'خالد يوسف',
          points: 720,
          level: 5,
          badge: 'محترف',
          rank: 3,
          avatar: null,
        ),
        UserRanking(
          userId: '4',
          name: 'سارة أحمد',
          points: 580,
          level: 4,
          badge: 'خبير',
          rank: 4,
          avatar: null,
        ),
        UserRanking(
          userId: _authService.currentUserId ?? '',
          name: _authService.appUser.value?.fullName ?? 'أنت',
          points: currentPoints.value,
          level: currentLevel.value,
          badge: currentBadge.value,
          rank: _calculateUserRank(),
          avatar: _authService.appUser.value?.photoURL,
        ),
      ]);

      // Sort by points
      leaderboard.sort((a, b) => b.points.compareTo(a.points));
      
      // Update ranks
      for (int i = 0; i < leaderboard.length; i++) {
        leaderboard[i] = leaderboard[i].copyWith(rank: i + 1);
      }
    } catch (e) {
      print('خطأ في تحميل قائمة المتصدرين: $e');
    }
  }

  // Calculate user rank
  int _calculateUserRank() {
    // In a real implementation, this would be calculated based on all users
    int userPoints = currentPoints.value;
    
    if (userPoints >= 1000) return 1;
    if (userPoints >= 500) return 2;
    if (userPoints >= 200) return 5;
    if (userPoints >= 100) return 10;
    if (userPoints >= 50) return 25;
    return 50;
  }

  // Get progress to next level
  double getProgressToNextLevel() {
    int currentLevelPoints = levelRequirements[currentLevel.value] ?? 0;
    int nextLevelPoints = levelRequirements[currentLevel.value + 1] ?? levelRequirements[currentLevel.value]!;
    
    if (currentLevel.value >= levelRequirements.keys.length) {
      return 1.0; // Max level reached
    }
    
    int pointsNeeded = nextLevelPoints - currentLevelPoints;
    int pointsEarned = currentPoints.value - currentLevelPoints;
    
    return (pointsEarned / pointsNeeded).clamp(0.0, 1.0);
  }

  // Get points needed for next level
  int getPointsForNextLevel() {
    if (currentLevel.value >= levelRequirements.keys.length) {
      return 0; // Max level reached
    }
    
    int nextLevelPoints = levelRequirements[currentLevel.value + 1] ?? 0;
    return (nextLevelPoints - currentPoints.value).clamp(0, double.infinity).toInt();
  }

  // Get unlocked achievements count
  int get unlockedAchievementsCount => 
      achievements.where((achievement) => achievement.isUnlocked).length;

  // Get earned badges count  
  int get earnedBadgesCount => 
      badges.where((badge) => badge.isEarned).length;

  // Get user's rank position
  int get userRankPosition {
    String? currentUserId = _authService.currentUserId;
    if (currentUserId == null) return 0;
    
    int index = leaderboard.indexWhere((user) => user.userId == currentUserId);
    return index >= 0 ? index + 1 : 0;
  }

  // Award points for action
  Future<void> awardPoints(String action, {int? customPoints}) async {
    try {
      int points = customPoints ?? pointsConfig[action] ?? 0;
      if (points <= 0) return;

      String? userId = _authService.currentUserId;
      if (userId == null) return;

      int oldLevel = currentLevel.value;
      int oldPoints = currentPoints.value;

      // await _userService.updateUserPoints(userId, points);
      currentPoints.value += points;
      
      _updateLevelAndBadge();
      
      // Show points notification with animation
      _showPointsNotification(points, action);
      
      // Check for level up
      if (currentLevel.value > oldLevel) {
        await Future.delayed(Duration(milliseconds: 500));
        _showLevelUpDialog(oldLevel, currentLevel.value);
      }
      
      // Update achievements and badges
      _generateAchievements();
      _generateBadges();
      
      // Update user data in auth service
      if (_authService.appUser.value != null) {
        _authService.appUser.value = _authService.appUser.value!.copyWith(
          points: currentPoints.value,
        );
      }
    } catch (e) {
      print('خطأ في منح النقاط: $e');
    }
  }

  // Show points notification
  void _showPointsNotification(int points, String action) {
    String actionName = _getActionDisplayName(action);
    
    Get.snackbar(
      '🌟 نقاط جديدة!',
      'حصلت على $points نقطة من $actionName',
      duration: Duration(seconds: 3),
      backgroundColor: Colors.amber.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.all(16),
      borderRadius: 12,
      icon: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.star, color: Colors.white, size: 20),
      ),
    );
  }

  // Show level up dialog
  void _showLevelUpDialog(int oldLevel, int newLevel) {
    Get.dialog(
      LevelUpDialog(
        newLevel: newLevel,
        newBadge: currentBadge.value,
        totalPoints: currentPoints.value,
      ),
      barrierDismissible: false,
    );
  }

  // Get action display name
  String _getActionDisplayName(String action) {
    switch (action) {
      case 'complete_profile':
        return 'إكمال الملف الشخصي';
      case 'add_post':
        return 'نشر منشور';
      case 'receive_like':
        return 'الحصول على إعجاب';
      case 'give_like':
        return 'إعطاء إعجاب';
      case 'receive_comment':
        return 'الحصول على تعليق';
      case 'comment_post':
        return 'كتابة تعليق';
      case 'add_education':
        return 'إضافة تعليم';
      case 'add_experience':
        return 'إضافة خبرة';
      case 'add_project':
        return 'إضافة مشروع';
      case 'add_skill':
        return 'إضافة مهارة';
      case 'add_language':
        return 'إضافة لغة';
      case 'daily_login':
        return 'الدخول اليومي';
      case 'share_post':
        return 'مشاركة منشور';
      case 'complete_cv':
        return 'إنشاء CV';
      case 'first_login':
        return 'أول دخول';
      default:
        return 'نشاط';
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadGamificationData();
  }
}

// Models for gamification
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int points;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
    required this.isUnlocked,
    this.unlockedAt,
  });
}

class Badge {
  final String id;
  final String title;
  final String description;
  final String color;
  final bool isEarned;
  final DateTime? earnedAt;

  Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.color,
    required this.isEarned,
    this.earnedAt,
  });
}

class UserRanking {
  final String userId;
  final String name;
  final int points;
  final int level;
  final String badge;
  final int rank;
  final String? avatar;

  UserRanking({
    required this.userId,
    required this.name,
    required this.points,
    required this.level,
    required this.badge,
    required this.rank,
    this.avatar,
  });

  UserRanking copyWith({
    String? userId,
    String? name,
    int? points,
    int? level,
    String? badge,
    int? rank,
    String? avatar,
  }) {
    return UserRanking(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      points: points ?? this.points,
      level: level ?? this.level,
      badge: badge ?? this.badge,
      rank: rank ?? this.rank,
      avatar: avatar ?? this.avatar,
    );
  }
}