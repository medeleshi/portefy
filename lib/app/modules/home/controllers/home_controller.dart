import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';
import '../../../models/post_model.dart';
import 'base_posts_controller.dart';
import 'all_posts_controller.dart';
import 'university_posts_controller.dart';
import 'major_posts_controller.dart';
import 'level_posts_controller.dart';

class HomeController extends GetxController with GetTickerProviderStateMixin {
  late TabController tabController;
  
  final RxInt currentTabIndex = 0.obs;
  
  // Tab controllers
  late final AllPostsController allPostsController;
  late final UniversityPostsController universityPostsController;
  late final MajorPostsController majorPostsController;
  late final LevelPostsController levelPostsController;

  final List<String> tabTitles = ['الكل', 'الجامعة', 'التخصص', 'المستوى'];

  @override
  void onInit() {
    super.onInit();
    
    tabController = TabController(length: 4, vsync: this);
    tabController.addListener(_onTabChanged);
    
    // Get the already initialized controllers from binding
    allPostsController = Get.find<AllPostsController>(tag: 'all');
    universityPostsController = Get.find<UniversityPostsController>(tag: 'university');
    majorPostsController = Get.find<MajorPostsController>(tag: 'major');
    levelPostsController = Get.find<LevelPostsController>(tag: 'level');
    
    // Load data for the initial tab (index 0) only
    WidgetsBinding.instance.addPostFrameCallback((_) {
      allPostsController.ensureDataLoaded();
    });
  }

  void _onTabChanged() {
    if (!tabController.indexIsChanging) {
      currentTabIndex.value = tabController.index;
      _updateCurrentTabLastSeen();
    }
  }

  Future<void> _updateCurrentTabLastSeen() async {
    final controller = _getCurrentController();
    
    // Just update the last seen timestamp and reset badge
    await controller.updateLastSeenOnly();
    
    // Ensure data is loaded for this tab (lazy loading)
    await controller.ensureDataLoaded();
  }

  BasePostsController _getCurrentController() {
    switch (currentTabIndex.value) {
      case 0: return allPostsController;
      case 1: return universityPostsController;
      case 2: return majorPostsController;
      case 3: return levelPostsController;
      default: return allPostsController;
    }
  }

  // Navigation methods
  void navigateToAddPost() {
    Get.toNamed(AppRoutes.ADD_POST);
  }

  void navigateToPostDetails(PostModel post) {
    Get.toNamed(AppRoutes.POST_DETAILS, arguments: {'post': post});
  }

  void navigateToComments(PostModel post) {
    Get.toNamed(AppRoutes.COMMENTS, arguments: {'postId': post.id});
  }

  void navigateToNotifications() {
    Get.toNamed(AppRoutes.NOTIFICATIONS);
  }

  void navigateToSettings() {
    Get.toNamed(AppRoutes.SETTINGS);
  }

  // Method to be called when a new post is created
  void onPostCreated(PostModel post) {
    // Add to all relevant tabs
    if(post.audience == 'public') {
      allPostsController.insertLocalPost(post);
    }
    
    // Add to specific tabs based on post author details
    if (post.authorUniversity != null && post.audience == 'university') {
      universityPostsController.insertLocalPost(post);
    }
    
    if (post.authorMajor != null && post.authorUniversity != null && post.audience == 'major') {
      majorPostsController.insertLocalPost(post);
    }
    
    if (post.authorLevel != null && post.authorMajor != null && post.authorUniversity != null && post.audience == 'level') {
      levelPostsController.insertLocalPost(post);
    }
  }

  // Get badge count for specific tab
  int getBadgeCount(int tabIndex) {
    switch (tabIndex) {
      case 0: return allPostsController.newPostsBadgeCount.value;
      case 1: return universityPostsController.newPostsBadgeCount.value;
      case 2: return majorPostsController.newPostsBadgeCount.value;
      case 3: return levelPostsController.newPostsBadgeCount.value;
      default: return 0;
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}