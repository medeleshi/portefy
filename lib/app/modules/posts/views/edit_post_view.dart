import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../services/auth_service.dart';
import '../../../theme/app_theme.dart';
import '../../../models/post_model.dart';
import '../controllers/posts_controller.dart';

class EditPostView extends GetView<PostsController> {
  @override
  Widget build(BuildContext context) {
    // Get the post from arguments
    final PostModel post = Get.arguments['post'] as PostModel;

    // Initialize the form with post data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initializeEditForm(post);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('تعديل المنشور'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(
            () => TextButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () => controller.editPost(post),
              child: controller.isLoading.value
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'تحديث',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Edit Info Banner
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.warning.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.1),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.edit, color: AppColors.warning, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'يتم تعديل المنشور. سيتم إظهار علامة "تم التعديل" بعد الحفظ.',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Author Info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: post.authorAvatar != null
                      ? CachedNetworkImageProvider(post.authorAvatar!)
                      : null,
                  child: post.authorAvatar == null
                      ? Icon(Icons.person, color: AppColors.primary)
                      : null,
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
                        ),
                      ),
                      if (post.authorInfoText.isNotEmpty)
                        Text(
                          post.authorInfoText,
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

            SizedBox(height: 20),

            // Content TextField
            TextField(
              controller: controller.contentController,
              decoration: InputDecoration(
                hintText: 'ما الذي تفكر فيه؟',
                border: InputBorder.none,
                hintStyle: TextStyle(color: AppColors.textHint, fontSize: 18),
              ),
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
              maxLines: null,
              textInputAction: TextInputAction.newline,
              onChanged: (value) {
                controller.update();
              },
            ),

            SizedBox(height: 20),

            // Existing Images from Post
            if (post.imageUrls.isNotEmpty) ...[
              Text(
                'الصور الموجودة:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Container(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: post.imageUrls[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.border,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.border,
                            child: Icon(Icons.error, color: AppColors.error),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
            ],

            // New Selected Images Preview
            Obx(
              () => controller.selectedImages.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'صور جديدة لإضافتها:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.selectedImages.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    margin: EdgeInsets.only(left: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                        image: FileImage(
                                          controller.selectedImages[index],
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () =>
                                          controller.removeImage(index),
                                      child: Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    )
                  : SizedBox.shrink(),
            ),

            // Tags Section
            // Obx(
            //   () => controller.tags.isNotEmpty
            //       ? Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Text(
            //               'العلامات:',
            //               style: TextStyle(
            //                 fontWeight: FontWeight.w600,
            //                 color: AppColors.textPrimary,
            //               ),
            //             ),
            //             SizedBox(height: 8),
            //             Wrap(
            //               spacing: 8,
            //               runSpacing: 4,
            //               children: controller.tags
            //                   .map(
            //                     (tag) => Chip(
            //                       label: Text(
            //                         '#$tag',
            //                         style: TextStyle(
            //                           color: AppColors.primary,
            //                           fontSize: 12,
            //                         ),
            //                       ),
            //                       backgroundColor: AppColors.primary
            //                           .withOpacity(0.1),
            //                       deleteIcon: Icon(Icons.close, size: 16),
            //                       onDeleted: () => controller.removeTag(tag),
            //                     ),
            //                   )
            //                   .toList(),
            //             ),
            //             SizedBox(height: 20),
            //           ],
            //         )
            //       : SizedBox.shrink(),
            // ),

            // // Add Tags
            // Container(
            //   padding: EdgeInsets.all(12),
            //   decoration: BoxDecoration(
            //     color: AppColors.surface,
            //     borderRadius: BorderRadius.circular(12),
            //     border: Border.all(color: AppColors.border),
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         'إضافة/تعديل العلامات',
            //         style: TextStyle(
            //           fontWeight: FontWeight.w500,
            //           color: AppColors.textPrimary,
            //           fontSize: 14,
            //         ),
            //       ),
            //       SizedBox(height: 8),
            //       Row(
            //         children: [
            //           Expanded(
            //             child: TextField(
            //               controller: controller.tagsController,
            //               decoration: InputDecoration(
            //                 hintText: 'اكتب علامة واضغط إدخال',
            //                 hintStyle: TextStyle(fontSize: 12),
            //                 border: OutlineInputBorder(
            //                   borderRadius: BorderRadius.circular(20),
            //                   borderSide: BorderSide(color: AppColors.border),
            //                 ),
            //                 contentPadding: EdgeInsets.symmetric(
            //                   horizontal: 12,
            //                   vertical: 8,
            //                 ),
            //               ),
            //               style: TextStyle(fontSize: 14),
            //               onSubmitted: (value) {
            //                 controller.addTag(value);
            //               },
            //             ),
            //           ),
            //           SizedBox(width: 8),
            //           IconButton(
            //             onPressed: () {
            //               controller.addTag(controller.tagsController.text);
            //             },
            //             icon: Icon(Icons.add_circle, color: AppColors.primary),
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),

            // SizedBox(height: 20),

            // // Edit History Info
            // if (post.isEdited) ...[
            //   Container(
            //     padding: EdgeInsets.all(12),
            //     decoration: BoxDecoration(
            //       color: AppColors.warning.withOpacity(0.1),
            //       borderRadius: BorderRadius.circular(12),
            //       border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            //     ),
            //     child: Row(
            //       children: [
            //         Icon(Icons.history, color: AppColors.warning, size: 18),
            //         SizedBox(width: 8),
            //         Expanded(
            //           child: Text(
            //             'هذا المنشور تم تعديله مسبقاً آخر مرة: ${post.timeAgo}',
            //             style: TextStyle(
            //               color: AppColors.textSecondary,
            //               fontSize: 12,
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            //   SizedBox(height: 30),
            // ] else ...[
            //   SizedBox(height: 30),
            // ],
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
        child: SafeArea(
          child: Row(
            children: [
              // Add Images
              IconButton(
                onPressed: () => _showImagePicker(),
                icon: Icon(Icons.add_photo_alternate, color: AppColors.primary),
                tooltip: 'إضافة صور جديدة',
              ),

              // Add Camera
              IconButton(
                onPressed: controller.pickImageFromCamera,
                icon: Icon(Icons.camera_alt, color: AppColors.primary),
                tooltip: 'التقاط صورة',
              ),

              Spacer(),

              // Character Count
              GetBuilder<PostsController>(
                builder: (controller) => Text(
                  '${controller.contentController.text.length}/500',
                  style: TextStyle(
                    color: controller.contentController.text.length > 500
                        ? Colors.red
                        : AppColors.textHint,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePicker() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
            SizedBox(height: 16),
            Text(
              'إضافة صور جديدة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'الصور الجديدة ستضاف للموجودة حالياً',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primary),
              title: Text('من المعرض'),
              subtitle: Text('اختيار عدة صور'),
              onTap: () {
                Get.back();
                controller.pickImages();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.primary),
              title: Text('التقاط صورة'),
              subtitle: Text('استخدام الكاميرا'),
              onTap: () {
                Get.back();
                controller.pickImageFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }
}
