import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../theme/app_theme.dart';
import '../../../models/comment_model.dart';
import '../../../services/auth_service.dart';
import '../controllers/posts_controller.dart';

class CommentsView extends GetView<PostsController> {
  final ScrollController _scrollController = ScrollController();

  CommentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final String postId = Get.arguments['postId'];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.resetComments();
      controller.loadComments(postId);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          controller.hasMoreComments.value &&
          !controller.isLoadingComments.value) {
        controller.loadComments(postId);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('التعليقات'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // قائمة التعليقات
            Expanded(
              child: Obx(() {
                if (controller.isLoadingComments.value &&
                    controller.comments.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }

                if (controller.comments.isEmpty) {
                  return _buildEmptyComments();
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount:
                      controller.comments.length +
                      (controller.hasMoreComments.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < controller.comments.length) {
                      return _buildCommentItem(
                        controller.comments[index],
                        index,
                        postId,
                        isReply: false, // ✅ هذا تعليق وليس رد
                      );
                    } else {
                      return controller.isLoadingComments.value
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : SizedBox.shrink();
                    }
                  },
                );
              }),
            ),

            // حقل إدخال التعليق
            _buildCommentInput(postId),
          ],
        ),
      ),
    );
  }

  // واجهة إدخال التعليق (منفصلة لإعادة الاستخدام)
  Widget _buildCommentInput(String postId, {String? parentCommentId}) {
    return Container(
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
            backgroundImage:
                Get.find<AuthService>().appUser.value?.photoURL != null
                ? NetworkImage(Get.find<AuthService>().appUser.value!.photoURL!)
                : null,
            child: Get.find<AuthService>().appUser.value?.photoURL == null
                ? Icon(Icons.person, color: AppColors.primary, size: 20)
                : null,
          ),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller.commentController,
              decoration: InputDecoration(
                hintText: parentCommentId != null
                    ? 'اكتب رداً...'
                    : 'اكتب تعليقاً...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  controller.addComment(
                    postId,
                    parentCommentId: parentCommentId,
                  );
                }
              },
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            onPressed: () {
              if (controller.commentController.text.trim().isNotEmpty) {
                controller.addComment(postId, parentCommentId: parentCommentId);
              }
            },
            icon: Icon(Icons.send, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  // واجهة التعليقات الفارغة
  Widget _buildEmptyComments() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: AppColors.textHint),
          SizedBox(height: 16),
          Text(
            'لا توجد تعليقات',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'كن أول من يعلق على هذا المنشور',
            style: TextStyle(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  // ✅ واجهة موحدة للتعليقات والردود
  Widget _buildCommentItem(
    CommentModel comment,
    int index,
    String postId, {
    bool isReply = false,
    String? parentCommentId,
  }) {
    final bool isMyComment =
        comment.userId == Get.find<AuthService>().currentUserId;
    final double avatarSize = isReply ? 16.0 : 20.0;
    final double fontSize = isReply ? 14.0 : 16.0;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الصورة الرمزية
          CircleAvatar(
            radius: avatarSize,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: comment.authorAvatar != null
                ? NetworkImage(comment.authorAvatar!)
                : null,
            child: comment.authorAvatar == null
                ? Icon(Icons.person, color: AppColors.primary, size: avatarSize)
                : null,
          ),

          SizedBox(width: isReply ? 8 : 12),

          // محتوى التعليق/الرد
          Expanded(
            child: Container(
              padding: EdgeInsets.all(isReply ? 8 : 12),
              decoration: BoxDecoration(
                color: isReply ? AppColors.background : AppColors.surface,
                borderRadius: BorderRadius.circular(isReply ? 12 : 16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // معلومات المرسل والوقت
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          comment.authorName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            fontSize: fontSize - 2,
                          ),
                        ),
                      ),
                      Text(
                        timeago.format(comment.createdAt, locale: 'ar'),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (isMyComment && !isReply)
                        PopupMenuButton(
                          icon: Icon(Icons.more_vert, size: 14),
                          itemBuilder: (context) => [
                            PopupMenuItem(value: 'edit', child: Text('تعديل')),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                'حذف',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'delete') {
                              _showDeleteCommentDialog(comment);
                            }
                          },
                        ),
                    ],
                  ),

                  SizedBox(height: 6),

                  // نص التعليق/الرد
                  Text(
                    comment.content,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      height: 1.4,
                      fontSize: fontSize - 2,
                    ),
                  ),

                  SizedBox(height: 10),

                  // أزرار الإجراءات
                  Row(
                    children: [
                      // زر الإعجاب
                      InkWell(
                        onTap: () => isReply
                            ? controller.toggleReplyLike(
                                postId,
                                comment.id,
                                parentCommentId ?? comment.parentCommentId!,
                              )
                            : controller.toggleCommentLike(
                                postId,
                                comment.id,
                                index,
                              ),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                comment.isLikedBy(
                                      Get.find<AuthService>().currentUserId!,
                                    )
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 14,
                                color:
                                    comment.isLikedBy(
                                      Get.find<AuthService>().currentUserId!,
                                    )
                                    ? Colors.red
                                    : AppColors.textSecondary,
                              ),
                              if (comment.likesCount > 0) ...[
                                SizedBox(width: 4),
                                Text(
                                  '${comment.likesCount}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      if (!isReply) ...[
                        SizedBox(width: 12),
                        // زر الرد (للتعليقات فقط)
                        InkWell(
                          onTap: () => _showReplyDialog(comment, postId),
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            child: Text(
                              'رد',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],

                      // عرض عدد الردود (للتعليقات فقط)
                      if (!isReply && comment.repliesCount > 0) ...[
                        SizedBox(width: 12),
                        InkWell(
                          onTap: () => _showReplies(comment, postId),
                          child: Text(
                            'عرض ${comment.repliesCount} رد',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // dialog تأكيد الحذف
  void _showDeleteCommentDialog(CommentModel comment) {
    Get.dialog(
      AlertDialog(
        title: Text('حذف التعليق'),
        content: Text('هل أنت متأكد من حذف هذا التعليق؟'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('إلغاء')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteComment(comment.postId, comment.id);
            },
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // dialog الرد على تعليق
  void _showReplyDialog(CommentModel comment, String postId) {
    final TextEditingController replyController = TextEditingController();

    Get.dialog(
      Dialog(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'الرد على ${comment.authorName}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  comment.content,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: replyController,
                decoration: InputDecoration(
                  hintText: 'اكتب ردك...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
                autofocus: true,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text('إلغاء'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (replyController.text.trim().isNotEmpty) {
                          controller.commentController.text =
                              replyController.text;
                          controller.addComment(
                            postId,
                            parentCommentId: comment.id,
                          );
                          Get.back();
                        }
                      },
                      child: Text('إرسال'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // عرض الردود
  void _showReplies(CommentModel comment, String postId) {
    controller.loadReplies(postId, comment.id);

    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.arrow_back),
                ),
                Expanded(
                  child: Text(
                    'الردود على ${comment.authorName}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 48), // للمساحة المتساوية
              ],
            ),
            SizedBox(height: 16),

            // قائمة الردود
            Expanded(
              child: Obx(() {
                if (controller.isLoadingReplies.value &&
                    controller.replies.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }

                if (controller.replies.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد ردود',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: controller.replies.length,
                  itemBuilder: (context, index) {
                    return _buildCommentItem(
                      controller.replies[index],
                      index,
                      postId,
                      isReply: true, // ✅ هذا رد
                      parentCommentId: comment.id,
                    );
                  },
                );
              }),
            ),

            // حقل إدخال الرد
            _buildCommentInput(postId, parentCommentId: comment.id),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
