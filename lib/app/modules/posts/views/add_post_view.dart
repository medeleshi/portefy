import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../theme/app_theme.dart';
import '../controllers/posts_controller.dart';

class AddPostView extends GetView<PostsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('إضافة منشور'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(
            () => TextButton(
              onPressed: controller.isLoading.value ? null : controller.addPost,
              child: controller.isLoading.value
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'نشر',
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
            // Points Info Banner
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.success.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.1),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ستحصل على 5 نقاط عند نشر هذا المنشور! 🎉',
                      style: TextStyle(
                        color: AppColors.primary,
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
                  child: Icon(Icons.person, color: AppColors.primary),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Get.find<AuthService>().appUser.value?.fullName ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      // Audience Selector
                      Obx(
                        () => GestureDetector(
                          onTap: () => _showAudienceSelector(),
                          child: Row(
                            children: [
                              Icon(
                                _getAudienceIcon(
                                  controller.selectTypeAudicence.value,
                                ),
                                size: 14,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                controller.selectedAudience.value,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
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

            // Selected Images Preview
            Obx(
              () => controller.selectedImages.isNotEmpty
                  ? Container(
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
                                margin: EdgeInsets.only(right: 8),
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
                                right: 12,
                                child: GestureDetector(
                                  onTap: () => controller.removeImage(index),
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
                    )
                  : SizedBox.shrink(),
            ),

            SizedBox(height: 20),

            // // Tags Section
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
            //         'إضافة علامات',
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

            // SizedBox(height: 30),
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
                icon: Icon(Icons.photo_library, color: AppColors.primary),
                tooltip: 'إضافة صور',
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
              'إضافة صور',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  void _showAudienceSelector() {
    final authService = Get.find<AuthService>();
    final currentUser = authService.appUser.value;

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
              'من يمكنه رؤية منشورك؟',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // General audience
            _buildAudienceOption(
              'Public',
              'جميع المستخدمين',
              Icons.public,
              'public',
            ),

            // University audience
            if (currentUser?.university != null)
              _buildAudienceOption(
                currentUser!.university!,
                'جامعتك',
                Icons.school,
                'university',
              ),

            // Major audience
            if (currentUser?.major != null)
              _buildAudienceOption(
                currentUser!.major!,
                'تخصصك',
                Icons.group,
                'major',
              ),

            // Year/level audience
            if (currentUser?.level != null)
              _buildAudienceOption(
                currentUser!.level!,
                'مستواك',
                Icons.stairs,
                'level',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudienceOption(
    String title,
    String subTitle,
    IconData icon,
    String typeAudience,
  ) {
    return GetBuilder<PostsController>(
      builder: (controller) => ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title),
        subtitle: Text(subTitle, style: TextStyle(fontSize: 12)),
        trailing: controller.selectedAudience.value == title
            ? Icon(Icons.check_circle, color: AppColors.primary)
            : Icon(Icons.radio_button_unchecked, color: AppColors.textHint),
        onTap: () {
          controller.setAudience(title, typeAudience);
          Get.back();
        },
      ),
    );
  }

  IconData _getAudienceIcon(String audience) {
    if (controller.selectTypeAudicence.value == 'public') return Icons.public;
    if (controller.selectTypeAudicence.value == 'university')
      return Icons.school;
    if (controller.selectTypeAudicence.value == 'major') return Icons.group;
    if (controller.selectTypeAudicence.value == 'level') return Icons.stairs;
    return Icons.public;
  }
}
