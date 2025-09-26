import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portefy/app/modules/notifications/controllers/all_notifications_controller.dart';
import 'package:portefy/app/routes/app_routes.dart';
import '../../../core/widgets/logo.dart';
import '../../../services/notification_service.dart';
import '../../../theme/app_theme.dart';
import '../controllers/home_controller.dart';
import '../widgets/posts_tab.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getCurrentBackgroundColor(),
      appBar: AppBar(
        title: Logo(),
        leading: // زر الإشعارات مع Badge realtime
          Obx(() {
            final notificationService = Get.find<NotificationService>();
            final unreadCount = notificationService.globalUnreadCount.value;
            
            return badges.Badge(
              badgeContent: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
              showBadge: unreadCount > 0,
              badgeStyle: badges.BadgeStyle(
                badgeColor: Colors.red,
                padding: EdgeInsets.all(4),
              ),
              position: badges.BadgePosition.topEnd(top: 2, end: 14),
              child: IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () {
                  // قبل الانتقال لشاشة الإشعارات، نعلم الخدمة أن المستخدم سيدخل الشاشة
                  Get.find<NotificationService>().setUserInNotificationsView(true);
                  Get.toNamed(AppRoutes.NOTIFICATIONS);
                },
              ),
            );
          }),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: controller.navigateToSettings,
            icon: Icon(Icons.settings),
          ),
        ],
        bottom: TabBar(
          controller: controller.tabController,
          isScrollable: false,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: List.generate(
            controller.tabTitles.length,
            (index) => Tab(
              child: Stack(
                children: [
                  Text(controller.tabTitles[index]),
                  Obx(() {
                    final badgeCount = controller.getBadgeCount(index);
                    if (badgeCount > 0) {
                      return Transform.translate(
                        offset: Offset(14, -14), // تعديل الموقع حسب الحاجة
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            badgeCount > 99 ? '99+' : badgeCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: [
          PostsTab(controller: controller.allPostsController),
          PostsTab(controller: controller.universityPostsController),
          PostsTab(controller: controller.majorPostsController),
          PostsTab(controller: controller.levelPostsController),
        ],
      ),
    );
  }
}
