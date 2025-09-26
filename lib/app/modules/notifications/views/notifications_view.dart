// views/notifications_view.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/notification_model.dart';
import '../../../theme/app_theme.dart';
import '../controllers/notifications_controller.dart';
import '../controllers/base_notification_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: controller.tabTitles.length,
      initialIndex: controller.currentTabIndex.value,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('الإشعارات'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: TabBar(
            isScrollable: true,
            tabs: List.generate(controller.tabTitles.length, (index) {
              final tabController = controller.tabControllers[index];
              return Tab(
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(controller.tabTitles[index]),
                      SizedBox(width: 4),
                      tabController.unreadCount.value > 0
                          ? Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                tabController.unreadCount.value.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
              );
            }),
          ),
          // ... باقي الكود
        ),
        body: TabBarView(
          children: controller.tabControllers.map(_buildTabContent).toList(),
        ),
      ),
    );
  }

  Widget _buildTabContent(BaseNotificationController tabController) {
    return Obx(() {
      if (tabController.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      if (tabController.notifications.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: tabController.refreshNotifications,
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification.metrics.pixels ==
                scrollNotification.metrics.maxScrollExtent) {
              tabController.loadMoreNotifications();
            }
            return false;
          },
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8),
            itemCount:
                tabController.notifications.length +
                (tabController.hasMoreData.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == tabController.notifications.length) {
                return _buildLoadMoreIndicator(tabController);
              }

              final notification = tabController.notifications[index];
              return _buildNotificationItem(notification, index, tabController);
            },
          ),
        ),
      );
    });
  }

  Widget _buildLoadMoreIndicator(BaseNotificationController tabController) {
    return Obx(
      () => tabController.isLoadMore.value
          ? Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          : SizedBox.shrink(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: AppColors.textHint),
          SizedBox(height: 16),
          Text(
            'لا توجد إشعارات',
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

  Widget _buildNotificationItem(
    NotificationModel notification,
    int index,
    BaseNotificationController tabController,
  ) {
    return Dismissible(
      key: Key('${notification.id}-$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        tabController.deleteNotification(notification.id, index);
      },
      child: InkWell(
        onTap: () => tabController.markAsRead(notification, index),
        child: Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: notification.isRead
                ? AppColors.surface
                : AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: notification.isRead
                ? null
                : Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              // Notification Icon/Avatar
              _buildNotificationIcon(notification),

              SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      notification.body,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      notification.timeAgo,
                      style: TextStyle(color: AppColors.textHint, fontSize: 12),
                    ),
                  ],
                ),
              ),

              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAllDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('حذف جميع الإشعارات'),
        content: Text(
          'هل أنت متأكد من حذف جميع الإشعارات؟ لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('إلغاء')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteAllNotifications();
            },
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationModel notification) {
    if (notification.senderAvatar != null) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: CachedNetworkImageProvider(notification.senderAvatar!),
      );
    }

    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.newPost:
        iconData = Icons.article;
        iconColor = AppColors.primary;
        break;
      case NotificationType.postLike:
      case NotificationType.commentLike:
        iconData = Icons.favorite;
        iconColor = Colors.red;
        break;
      case NotificationType.postComment:
      case NotificationType.commentReply:
        iconData = Icons.chat_bubble;
        iconColor = AppColors.secondary;
        break;
      case NotificationType.follow:
        iconData = Icons.person_add;
        iconColor = AppColors.success;
        break;
      case NotificationType.mention:
        iconData = Icons.alternate_email;
        iconColor = AppColors.warning;
        break;
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: iconColor.withOpacity(0.1),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }
}
