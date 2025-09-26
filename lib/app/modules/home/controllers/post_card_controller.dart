// post_card_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:portefy/app/services/post_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../../models/post_model.dart';
import '../../../services/auth_service.dart';
import '../../../theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../../posts/controllers/posts_controller.dart';

class PostCardController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final AuthService _authService = Get.find<AuthService>();
  final PostsController _postsController = Get.find<PostsController>();
  final PostService _postService = PostService();
  final PostModel post;
  final Function? onUpdate;
  final int? index;

  PostCardController({required this.post, this.onUpdate, this.index});

  final double _iconSize = 22.0;
  final double _avatarRadius = 22.0;

  // متغيرات للتحكم بالرسوم المتحركة
  late AnimationController likeAnimationController;
  late Animation<double> likeAnimation;
  final RxBool isLiked = false.obs;
  final RxBool isAnimating = false.obs;
  final RxBool isLikeInProgress = false.obs;

  final RxInt likesCount = 0.obs;
final RxInt commentsCount = 0.obs;


  @override
  void onInit() {
    super.onInit();

    // تهيئة متحكم الرسوم المتحركة للإعجاب
    likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    likeAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: likeAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // التحقق من حالة الإعجاب الحالية
    isLiked.value = post.isLikedByUser(_authService.currentUserId);
  // init counts
  likesCount.value = post.likesCount;
  commentsCount.value = post.commentsCount;
}

  @override
  void onClose() {
    likeAnimationController.dispose();
    super.onClose();
  }

  // دالة الانتقال لملف المستخدم
  void navigateToUserProfile(String userId) {
    final currentUserId = _authService.currentUserId;

    if (userId == currentUserId) {
      // الانتقال للملف الشخصي الخاص (بدون arguments)
      Get.toNamed(AppRoutes.PORTFOLIO);
    } else {
      // الانتقال لملف المستخدم الآخر
      Get.toNamed(AppRoutes.PORTFOLIO, arguments: {'userId': userId});
    }
  }

  void handleMenuSelection(String value, PostModel post) {
    switch (value) {
      case 'report':
        reportPost(post);
        break;
      case 'save':
        savePost(post);
        break;
      case 'share':
        sharePost(post);
        break;
      case 'edit':
        editPost(post);
        break;
      case 'delete':
        deletePost(post);
        break;
    }
  }

  void showImageGallery(List<String> imageUrls, int initialIndex) {
    Get.to(
      () => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ],
        ),
        body: PhotoViewGallery.builder(
          itemCount: imageUrls.length,
          pageController: PageController(initialPage: initialIndex),
          builder: (context, index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: CachedNetworkImageProvider(imageUrls[index]),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            );
          },
          loadingBuilder: (context, event) => Center(
            child: Container(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                value: event == null
                    ? 0
                    : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
              ),
            ),
          ),
        ),
      ),
      transition: Transition.fadeIn,
    );
  }

  void viewPostDetails(PostModel post) {
    print(post.authorName);

    Get.toNamed(AppRoutes.POST_DETAILS, arguments: {'post': post})?.then((
      value,
    ) {
      if (onUpdate != null && value == true) {
        onUpdate!();
      }
    });
  }

  void viewComments(PostModel post) {
  Get.toNamed(
    AppRoutes.COMMENTS,
    arguments: {'postId': post.id, 'post': post},
  )?.then((value) {
    if (value == true) {
      commentsCount.value += 1; // 👈 تحديث مباشر
      if (onUpdate != null) onUpdate!();
    }
  });
}


Future<void> toggleLike(PostModel post) async {
  if (_authService.currentUserId == null) {
    showLoginPrompt();
    return;
  }

  if (isLikeInProgress.value) return;

  isLikeInProgress.value = true;

  // animation
  isAnimating.value = true;
  likeAnimationController.reset();
  likeAnimationController.forward().then((_) {
    isAnimating.value = false;
  });

  // update UI locally
  isLiked.value = !isLiked.value;
  likesCount.value += isLiked.value ? 1 : -1; // 👈 تحديث مباشر

  try {
    await _postService.togglePostLike(post.id, _authService.currentUserId!);
    if (onUpdate != null) onUpdate!();
  } catch (e) {
    // rollback
    isLiked.value = !isLiked.value;
    likesCount.value += isLiked.value ? 1 : -1;
    Get.snackbar('خطأ', 'فشل في تحديث الإعجاب');
  } finally {
    isLikeInProgress.value = false;
  }
}

  void reportPost(PostModel post) {
    Get.dialog(
      AlertDialog(
        title: Text('الإبلاغ عن المنشور'),
        content: Text(
          'هل ترغب في الإبلاغ عن هذا المنشور لمخالفته شروط الاستخدام؟',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'تم الإبلاغ',
                'شكراً لإبلاغك، سنراجع المنشور قريباً',
              );
            },
            child: Text('تأكيد الإبلاغ'),
          ),
        ],
      ),
    );
  }

  void savePost(PostModel post) {
    // TODO: تنفيذ عملية حفظ المنشور
    Get.snackbar('تم الحفظ', 'تم حفظ المنشور في المفضلة');
  }

  void sharePost(PostModel post) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'مشاركة المنشور',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildShareOption('WhatsApp', Icons.message, Colors.green),
                _buildShareOption('Telegram', Icons.send, Colors.blue),
                _buildShareOption(
                  'Facebook',
                  Icons.facebook,
                  Colors.blue[800]!,
                ),
                _buildShareOption('Instagram', Icons.camera_alt, Colors.purple),
                _buildShareOption('TikTok', Icons.music_note, Colors.black),
                _buildShareOption(
                  'Twitter',
                  Icons.alternate_email,
                  Colors.blue,
                ),
                _buildShareOption('نسخ الرابط', Icons.link, AppColors.primary),
                _buildShareOption(
                  'المزيد',
                  Icons.more_horiz,
                  AppColors.textSecondary,
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildShareOption(String title, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        Get.back();
        // TODO: تنفيذ المشاركة حسب المنصة
        Get.snackbar('مشاركة عبر $title', 'تمت المشاركة بنجاح');
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void editPost(PostModel post) {
    Get.toNamed(AppRoutes.EDIT_POST, arguments: {'post': post})?.then((value) {
      if (value == true && onUpdate != null) {
        onUpdate!();
      }
    });
  }

  void deletePost(PostModel post) {
    Get.dialog(
      AlertDialog(
        title: Text('حذف المنشور'),
        content: Text(
          'هل أنت متأكد من رغبتك في حذف هذا المنشور؟ لا يمكن التراجع عن هذه العملية.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // TODO: تنفيذ عملية الحذف
              if (onUpdate != null) {
                onUpdate!();
              }
              Get.snackbar('تم الحذف', 'تم حذف المنشور بنجاح');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void showLoginPrompt() {
    Get.dialog(
      AlertDialog(
        title: Text('تسجيل الدخول مطلوب'),
        content: Text('يجب تسجيل الدخول للتفاعل مع المنشورات'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('لاحقاً')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.LOGIN);
            },
            child: Text('تسجيل الدخول'),
          ),
        ],
      ),
    );
  }
}
