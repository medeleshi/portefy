import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:portefy/app/routes/app_routes.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../models/post_report_model.dart';
import '../../../services/share_service.dart';
import '../../../theme/app_theme.dart';
import '../../../models/post_model.dart';
import '../../../services/auth_service.dart';
import '../../posts/controllers/posts_controller.dart';
import '../controllers/base_posts_controller.dart';
import '../controllers/home_controller.dart';

class PostsTab extends StatelessWidget {
  final BasePostsController controller;
  final ShareService _shareService = ShareService();

  PostsTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Ensure data is loaded when tab becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.ensureDataLoaded();
    });

    return Obx(() {
      // Show shimmer loading effect for better UX
      if (controller.isLoading.value && controller.posts.isEmpty) {
        return _buildShimmerLoading();
      }

      if (controller.posts.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: controller.refreshPosts,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: CustomScrollView(
          slivers: [
            // New posts badge at the top
            SliverToBoxAdapter(child: _buildNewPostsBadge()),

            // Posts list
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == controller.posts.length) {
                    // Load more posts when reaching the end
                    if (controller.hasMore.value &&
                        !controller.isLoadingMore.value) {
                      controller.loadMorePosts();
                    }

                    return Obx(
                      () => controller.isLoadingMore.value
                          ? Container(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : SizedBox.shrink(),
                    );
                  }

                  return _buildPostCard(controller.posts[index], index);
                },
                childCount:
                    controller.posts.length +
                    (controller.hasMore.value ? 1 : 0),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNewPostsBadge() {
    return Obx(() {
      if (controller.newPostsBadgeCount.value == 0) {
        return SizedBox.shrink();
      }

      return Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => controller.refreshPosts(),
            borderRadius: BorderRadius.circular(25),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_upward, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '${controller.newPostsBadgeCount.value} منشور جديد',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8),
      itemCount: 3,
      itemBuilder: (context, index) => _buildShimmerCard(),
    );
  }

  Widget _buildShimmerCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.textHint.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.textHint.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        width: 80,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.textHint.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            Container(
              width: double.infinity / .3,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.textHint.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity / .5,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.textHint.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(height: 8),

            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.textHint.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.post_add, size: 60, color: AppColors.primary),
          ),
          SizedBox(height: 24),
          Text(
            'لا توجد منشورات حتى الآن',
            style: TextStyle(
              fontSize: 20,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'كن أول من يشارك منشوراً في مجتمعك الجامعي',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.ADD_POST),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            icon: Icon(Icons.add),
            label: Text('إنشاء منشور'),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(PostModel post, int index) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Header
            Padding(padding: EdgeInsets.all(16), child: _buildPostHeader(post)),

            // Post Content
            GestureDetector(
              onTap: () => _navigateToPostDetails(post),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  post.content,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ),

            // Post Images
            if (post.imageUrls.isNotEmpty) ...[
              SizedBox(height: 12),
              _buildPostImages(post.imageUrls),
            ],

            // // Post Tags
            // if (post.tags.isNotEmpty) ...[
            //   SizedBox(height: 12),
            //   Padding(
            //     padding: EdgeInsets.symmetric(horizontal: 16),
            //     child: _buildPostTags(post.tags),
            //   ),
            // ],

            // Post Actions
            Padding(
              padding: EdgeInsets.all(16),
              child: _buildPostActions(post, index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostHeader(PostModel post) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: post.authorAvatar != null
                ? CachedNetworkImageProvider(post.authorAvatar!)
                : null,
            child: post.authorAvatar == null
                ? Icon(Icons.person, color: AppColors.primary, size: 24)
                : null,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.authorName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
              if (post.authorInfoText.isNotEmpty) ...[
                SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      post.authorInfoText,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text('.'),
                    SizedBox(width: 4),
                    Text(
                      post.timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        SizedBox(width: 8),
        PopupMenuButton(
          icon: Icon(Icons.more_vert, color: AppColors.textSecondary, size: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          itemBuilder: (context) => _buildPostMenuItems(post),
        ),
      ],
    );
  }

  List<PopupMenuEntry> _buildPostMenuItems(PostModel post) {
    List<PopupMenuEntry> items = [];
    final currentUserId = Get.find<AuthService>().currentUserId;

    if (post.userId == currentUserId) {
      items.addAll([
        PopupMenuItem(
          onTap: () =>
              Get.toNamed(AppRoutes.EDIT_POST, arguments: {'post': post}),
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20, color: AppColors.primary),
              SizedBox(width: 12),
              Text('تعديل'),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () => _confirmDelete(post),
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red, size: 20),
              SizedBox(width: 12),
              Text('حذف', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ]);
    } else {
      items.addAll([
        PopupMenuItem(
          onTap: () => showReportPostBottomSheet(post.id),
          value: 'report',
          child: Row(
            children: [
              Icon(Icons.report, color: Colors.orange, size: 20),
              SizedBox(width: 12),
              Text('إبلاغ', style: TextStyle(color: Colors.orange)),
            ],
          ),
        ),
        // PopupMenuItem(
        //   value: 'hide',
        //   child: Row(
        //     children: [
        //       Icon(
        //         Icons.visibility_off,
        //         color: AppColors.textSecondary,
        //         size: 20,
        //       ),
        //       SizedBox(width: 12),
        //       Text('إخفاء المنشور'),
        //     ],
        //   ),
        // ),
      ]);
    }

    return items;
  }

  // Build Image/Image Gallery
  Widget _buildPostImages(List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      return SizedBox.shrink(); // Handle empty case
    }

    if (imageUrls.length == 1) {
      return _buildSingleImage(imageUrls.first);
    } else {
      return _buildImageGallery(imageUrls);
    }
  }

  Widget _buildSingleImage(String imageUrl) {
    return GestureDetector(
      onTap: () => _showImageViewer([imageUrl], 0),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            height: 250,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                _buildImagePlaceholder(250, double.infinity),
            errorWidget: (context, url, error) =>
                _buildImageError(250, double.infinity),
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery(List<String> imageUrls) {
    return Container(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 16, right: 16), // Added right padding
        itemCount: imageUrls.length > 4
            ? 4
            : imageUrls.length, // Limit to 4 items max
        itemBuilder: (context, index) {
          if (index == 3 && imageUrls.length > 4) {
            return _buildMoreImagesOverlay(imageUrls, imageUrls.length - 3);
          }
          return _buildGalleryImage(imageUrls, index);
        },
      ),
    );
  }

  Widget _buildGalleryImage(List<String> imageUrls, int index) {
    return GestureDetector(
      onTap: () => _showImageViewer(imageUrls, index),
      child: Container(
        margin: EdgeInsets.only(right: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: imageUrls[index],
                height: 200,
                width: 150,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildImagePlaceholder(200, 150),
                errorWidget: (context, url, error) =>
                    _buildImageError(200, 150),
              ),
              // Add index indicator for multiple images
              if (imageUrls.length > 1)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${index + 1}/${imageUrls.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreImagesOverlay(List<String> imageUrls, int remainingCount) {
    return GestureDetector(
      onTap: () => _showImageViewer(imageUrls, 3), // Start from the 4th image
      child: Container(
        margin: EdgeInsets.only(right: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 200,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library, size: 40, color: Colors.grey[600]),
                  SizedBox(height: 8),
                  Text(
                    '+$remainingCount',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'صور',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(double height, double width) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }

  Widget _buildImageError(double height, double width) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: Icon(Icons.broken_image, color: AppColors.textHint)),
    );
  }
  // Build Image/Image Gallery

  Widget _buildPostTags(List<String> tags) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: tags
          .map(
            (tag) => Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '#$tag',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPostActions(PostModel post, int index) {
    final currentUserId = Get.find<AuthService>().currentUserId;
    final isLiked = post.isLikedByUser(currentUserId);

    // دالة لتنسيق الأرقام
    String _formatNumber(int number) {
      if (number == 0) return '0';
      if (number < 1000) return number.toString();
      if (number < 1000000) return '${(number / 1000).toStringAsFixed(1)}K';
      if (number < 100000000) {
        return '${(number / 1000000).toStringAsFixed(1)}M';
      }
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    }

    return Row(
      children: [
        // Like Button with animation
        Expanded(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.toggleLike(post.id, index),
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : AppColors.textSecondary,
                          size: 22,
                          key: ValueKey(isLiked),
                        ),
                      ),
                      SizedBox(width: 8),
                      if (post.likesCount > 0)
                        Text(
                          _formatNumber(post.likesCount),
                          style: TextStyle(
                            color: isLiked
                                ? Colors.red
                                : AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Comment Button
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _navigateToComments(post),
              borderRadius: BorderRadius.circular(25),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    if (post.commentsCount > 0)
                      Text(
                        _formatNumber(post.commentsCount),
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Share Button
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _shareService.sharePost(post);
              },
              borderRadius: BorderRadius.circular(25),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.share_outlined,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    if (post.sharesCount > 0)
                      Text(
                        _formatNumber(post.sharesCount),
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(PostModel post) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('حذف المنشور'),
        content: Text(
          'هل أنت متأكد من حذف هذا المنشور؟ لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Implement delete functionality
              controller.deletePost(post.id);
              Get.snackbar('تم الحذف', 'تم حذف المنشور بنجاح');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showImageViewer(List<String> images, int initialIndex) {
    Get.to(
      () => ImageViewerScreen(imageUrls: images, initialIndex: initialIndex),
    );
  }

  void _navigateToPostDetails(PostModel post) {
    Get.find<HomeController>().navigateToPostDetails(post);
  }

  void _navigateToComments(PostModel post) {
    Get.find<HomeController>().navigateToComments(post);
  }

  void showReportPostBottomSheet(String postId) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.report, color: Colors.red),
                SizedBox(width: 10),
                Text(
                  'الإبلاغ عن المنشور',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: 20),

            // محتوى الـ BottomSheet (نفس محتوى الـ Dialog)
            Expanded(
              child: SingleChildScrollView(
                child: ReportPostContent(postId: postId),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
// Image Viewer Screen for full-screen image viewing

class ImageViewerScreen extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageViewerScreen({
    Key? key,
    required this.imageUrls,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _ImageViewerScreenState createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  double _scale = 1.0;
  double _previousScale = 1.0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      _scale = 1.0; // Reset zoom quand on change d'image
    });
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // GestureDetector pour swipe down to close
            GestureDetector(
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity! > 100) {
                  _goBack(); // Swipe down pour fermer
                }
              },
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.imageUrls.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    maxScale: 5.0,
                    minScale: 0.5,
                    child: Center(
                      child: Hero(
                        tag: 'image_${widget.imageUrls[index]}',
                        child: CachedNetworkImage(
                          imageUrl: widget.imageUrls[index],
                          fit: BoxFit.contain,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[800],
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[800],
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Header avec bouton back et indicateur
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    // Bouton back
                    IconButton(
                      onPressed: _goBack,
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    SizedBox(width: 16),
                    // Indicateur de position
                    Text(
                      '${_currentIndex + 1}/${widget.imageUrls.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Indicateurs de swipe en bas
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Indicateur swipe horizontal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.swipe, color: Colors.white54, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Swipe horizontal pour naviguer',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Indicateur swipe down to close
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.swipe_down, color: Colors.white54, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Swipe down pour fermer',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// محتوى الـ BottomSheet منفصل لإعادة الاستخدام
class ReportPostContent extends StatelessWidget {
  final String postId;
  final PostsController controller = Get.put(PostsController());

  ReportPostContent({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'يرجى اختيار سبب الإبلاغ عن هذا المنشور',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        SizedBox(height: 20),

        // قائمة أسباب الإبلاغ
        Obx(
          () => Column(
            children: ReportReason.values.map((reason) {
              return ListTile(
                leading: Radio<ReportReason>(
                  value: reason,
                  groupValue: controller.selectedReportReason.value,
                  onChanged: (value) {
                    controller.selectedReportReason.value = value!;
                  },
                ),
                title: Text(_getReasonText(reason)),
                onTap: () {
                  controller.selectedReportReason.value = reason;
                },
              );
            }).toList(),
          ),
        ),

        SizedBox(height: 20),
        TextField(
          controller: controller.reportDescriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'وصف إضافي (اختياري)',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 30),

        ElevatedButton(
          onPressed: () => _submitReport(postId),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            minimumSize: Size(double.infinity, 50),
          ),
          child: Text(
            'إبلاغ',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        SizedBox(height: 10),

        TextButton(onPressed: () => Get.back(), child: Text('إلغاء')),
      ],
    );
  }

  String _getReasonText(ReportReason reason) {
    // نفس الدالة السابقة
    switch (reason) {
      case ReportReason.spam:
        return 'محتوى غير مرغوب أو إعلاني';
      case ReportReason.hateSpeech:
        return 'خطاب كراهية أو تحريض';
      case ReportReason.violence:
        return 'عنف أو تهديد';
      case ReportReason.nudity:
        return 'محتوى غير لائق';
      case ReportReason.falseInformation:
        return 'معلومات خاطئة';
      case ReportReason.harassment:
        return 'تحرش أو مضايقة';
      case ReportReason.other:
        return 'سبب آخر';
    }
  }

  void _submitReport(String postId) {
    if (controller.selectedReportReason.value == null) {
      Get.snackbar('خطأ', 'يرجى اختيار سبب الإبلاغ');
      return;
    }

    controller.submitPostReport(
      postId: postId,
      reason: controller.selectedReportReason.value!,
      description: controller.reportDescriptionController.text.trim(),
    );

    Get.back();
  }
}
