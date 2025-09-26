import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import '../../../theme/app_theme.dart';
import '../../../models/post_model.dart';
import '../../../services/auth_service.dart';
import '../controllers/posts_controller.dart';

class PostDetailsView extends GetView<PostsController> {
  @override
  Widget build(BuildContext context) {
    final PostModel post = Get.arguments['post'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('تفاصيل المنشور'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              if (post.userId == Get.find<AuthService>().currentUserId) ...[
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('تعديل'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('حذف', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ] else ...[
                PopupMenuItem(
                  value: 'report',
                  child: Row(
                    children: [
                      Icon(Icons.report, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('إبلاغ', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share, size: 20),
                    SizedBox(width: 8),
                    Text('مشاركة'),
                  ],
                ),
              ),
            ],
            onSelected: (value) => _handleMenuAction(value, post),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Header
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: post.authorAvatar != null
                      ? CachedNetworkImageProvider(post.authorAvatar!)
                      : null,
                  child: post.authorAvatar == null
                      ? Icon(Icons.person, color: AppColors.primary, size: 30)
                      : null,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (post.authorUniversity != null || post.authorMajor != null)
                        Text(
                          [post.authorMajor, post.authorUniversity]
                              .where((e) => e != null)
                              .join(' • '),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      SizedBox(height: 2),
                      Text(
                        timeago.format(post.createdAt, locale: 'ar'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Post Content
            Text(
              post.content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
              ),
            ),

            // Post Images
            if (post.imageUrls.isNotEmpty) ...[
              SizedBox(height: 20),
              _buildPostImages(post.imageUrls),
            ],

            // Post Tags
            if (post.tags.isNotEmpty) ...[
              SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: post.tags
                    .map((tag) => Chip(
                          label: Text(
                            '#$tag',
                            style: TextStyle(fontSize: 13),
                          ),
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ))
                    .toList(),
              ),
            ],

            SizedBox(height: 20),

            // Post Stats
            Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.red, size: 20),
                      SizedBox(width: 4),
                      Text(
                        '${post.likesCount} إعجاب',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  SizedBox(width: 20),
                  Row(
                    children: [
                      Icon(Icons.chat_bubble, color: AppColors.primary, size: 20),
                      SizedBox(width: 4),
                      Text(
                        '${post.commentsCount} تعليق',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  SizedBox(width: 20),
                  Row(
                    children: [
                      Icon(Icons.share, color: AppColors.secondary, size: 20),
                      SizedBox(width: 4),
                      Text(
                        '${post.sharesCount} مشاركة',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _toggleLike(post),
                    icon: Icon(
                      post.likedBy.contains(Get.find<AuthService>().currentUserId)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: post.likedBy.contains(Get.find<AuthService>().currentUserId)
                          ? Colors.red
                          : Colors.white,
                    ),
                    label: Text('إعجاب'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: post.likedBy.contains(Get.find<AuthService>().currentUserId)
                          ? Colors.red.withOpacity(0.1)
                          : AppColors.primary,
                      foregroundColor: post.likedBy.contains(Get.find<AuthService>().currentUserId)
                          ? Colors.red
                          : Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewComments(post),
                    icon: Icon(Icons.chat_bubble_outline),
                    label: Text('تعليق'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _sharePost(post),
                    icon: Icon(Icons.share),
                    label: Text('مشاركة'),
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),

            // Comments Preview
            Text(
              'التعليقات',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            // Load comments
            Obx(() {
              if (controller.isLoadingComments.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.comments.isEmpty) {
                return Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 48,
                        color: AppColors.textHint,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'لا توجد تعليقات',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'كن أول من يعلق على هذا المنشور',
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: controller.comments
                    .take(3)
                    .map((comment) => _buildCommentItem(comment))
                    .toList(),
              );
            }),

            if (controller.comments.length > 3) ...[
              SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => _viewComments(post),
                  child: Text('عرض جميع التعليقات (${controller.comments.length})'),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(Icons.person, color: AppColors.primary, size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller.commentController,
                decoration: InputDecoration(
                  hintText: 'اكتب تعليقاً...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ),
            SizedBox(width: 8),
            IconButton(
              onPressed: () => controller.addComment(post.id),
              icon: Icon(Icons.send, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostImages(List<String> imageUrls) {
    if (imageUrls.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: imageUrls.first,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 300,
            color: AppColors.border,
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    } else {
      return Container(
        height: 300,
        child: PageView.builder(
          itemCount: imageUrls.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(right: index < imageUrls.length - 1 ? 8 : 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: imageUrls[index],
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      );
    }
  }

  Widget _buildCommentItem(comment) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(Icons.person, color: AppColors.primary, size: 16),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.authorName,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  comment.content,
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  timeago.format(comment.createdAt, locale: 'ar'),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, PostModel post) {
    switch (action) {
      case 'edit':
        Get.toNamed('/edit-post', arguments: {'post': post});
        break;
      case 'delete':
        _showDeleteDialog(post);
        break;
      case 'report':
        _showReportDialog(post);
        break;
      case 'share':
        _sharePost(post);
        break;
    }
  }

  void _toggleLike(PostModel post) {
    // Implement like functionality
  }

  void _viewComments(PostModel post) {
    Get.toNamed('/comments', arguments: {'postId': post.id});
  }

  void _sharePost(PostModel post) {
    // Implement share functionality
  }

  void _showDeleteDialog(PostModel post) {
    Get.dialog(
      AlertDialog(
        title: Text('حذف المنشور'),
        content: Text('هل أنت متأكد من حذف هذا المنشور؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deletePost(post.id);
              Get.back();
            },
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(PostModel post) {
    Get.dialog(
      AlertDialog(
        title: Text('إبلاغ عن المنشور'),
        content: Text('هل تريد الإبلاغ عن هذا المنشور؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar('تم الإبلاغ', 'تم إرسال البلاغ بنجاح');
            },
            child: Text('إبلاغ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}