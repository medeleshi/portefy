import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/post_model.dart';
import '../../../models/comment_model.dart';
import '../../../models/post_report_model.dart';
import '../../../models/user_model.dart';
import '../../../services/post_service.dart';
import '../../../services/comment_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/report_service.dart';
import '../../../services/storage_service.dart';
// import '../../gamification/controllers/gamification_controller.dart';
import '../../home/controllers/home_controller.dart';

class PostsController extends GetxController {
  final PostService _postService = PostService();
  final CommentService commentService = CommentService();
  final AuthService _authService = Get.find<AuthService>();
  final StorageService _storageService = StorageService();

  // Form controllers
  final contentController = TextEditingController();
  final commentController = TextEditingController();
  final tagsController = TextEditingController();
  // متحكمات الإبلاغ
  final Rx<ReportReason?> selectedReportReason = Rx<ReportReason?>(null);
  final TextEditingController reportDescriptionController = TextEditingController();
  
  // خدمة الإبلاغ
  final ReportService reportService = Get.put(ReportService());


  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isLoadingComments = false.obs;
  final RxList<File> selectedImages = <File>[].obs;
  final RxList<String> tags = <String>[].obs;
  final RxList<CommentModel> comments = <CommentModel>[].obs;
  DocumentSnapshot? lastCommentDoc;
  RxBool hasMoreComments = true.obs;
  final Rx<PostModel?> currentPost = Rx<PostModel?>(null);
  final RxList<CommentModel> replies = <CommentModel>[].obs;
  final RxBool isLoadingReplies = false.obs;

  // Image picker
  final ImagePicker _picker = ImagePicker();

  final RxString selectedAudience = 'Public'.obs;
  final RxString selectTypeAudicence = 'public'.obs;

  // Add/Edit post methods
  Future<void> addPost() async {
    if (contentController.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى كتابة محتوى المنشور');
      return;
    }

    try {
      isLoading.value = true;

      UserModel? currentUser = _authService.appUser.value;
      if (currentUser == null) throw 'المستخدم غير مسجل الدخول';

      // Upload images if any
      List<String> imageUrls = [];
      for (File image in selectedImages) {
        String imageUrl = await _storageService.uploadPostImage(image);
        imageUrls.add(imageUrl);
      }

      PostModel post = PostModel(
        id: '',
        userId: currentUser.id,
        authorName: currentUser.fullName,
        authorAvatar: currentUser.photoURL,
        authorUniversity: currentUser.university,
        authorMajor: currentUser.major,
        authorLevel: currentUser.level,
        content: contentController.text.trim(),
        imageUrls: imageUrls,
        tags: tags.toList(),
        audience: selectTypeAudicence.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _postService.createPost(post);

      // Notify HomeController to add post to tabs
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().onPostCreated(post);
      }

      Get.back();
      Get.snackbar('نجح', 'تم نشر المنشور بنجاح');
      _clearForm();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل نشر المنشور: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> editPost(PostModel post) async {
    if (contentController.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى كتابة محتوى المنشور');
      return;
    }

    try {
      isLoading.value = true;

      // Upload new images if any
      List<String> imageUrls = List<String>.from(post.imageUrls);
      for (File image in selectedImages) {
        String imageUrl = await _storageService.uploadPostImage(image);
        imageUrls.add(imageUrl);
      }

      Map<String, dynamic> updateData = {
        'content': contentController.text.trim(),
        'imageUrls': imageUrls,
        'tags': tags.toList(),
      };

      await _postService.updatePost(post.id, updateData);

      Get.back();
      Get.snackbar('نجح', 'تم تحديث المنشور بنجاح');
      _clearForm();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحديث المنشور: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Image handling methods
  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        selectedImages.addAll(images.map((xFile) => File(xFile.path)));
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل اختيار الصور');
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        selectedImages.add(File(image.path));
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل التقاط الصورة');
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  // Tags handling
  void addTag(String tag) {
    if (tag.trim().isNotEmpty && !tags.contains(tag.trim())) {
      tags.add(tag.trim());
      tagsController.clear();
    }
  }

  void removeTag(String tag) {
    tags.remove(tag);
  }

  Future<void> loadComments(String postId, {int limit = 20}) async {
    // ✅ إضافة شرط إضافي لمنع التحميل المزدوج
    if (!hasMoreComments.value || isLoadingComments.value) return;

    try {
      isLoadingComments.value = true;

      final result = await commentService.getPostComments(
        postId,
        limit: limit,
        lastDoc: lastCommentDoc,
      );

      if (result.comments.isNotEmpty) {
        comments.addAll(result.comments);
        lastCommentDoc = result.lastDoc;

        // ✅ التحقق إذا كان عدد التعليقات أقل من الـ limit
        if (result.comments.length < limit) {
          hasMoreComments.value = false;
        }
      } else {
        hasMoreComments.value = false;
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحميل التعليقات');
      // ✅ إعادة تعيين حالة التحميل حتى في حالة الخطأ
    } finally {
      isLoadingComments.value = false;
    }
  }

  // Reset comments (مثلاً عند إعادة فتح post جديد)
  void resetComments() {
    comments.clear();
    lastCommentDoc = null;
    hasMoreComments.value = true;
  }

  Future<void> addComment(String postId, {String? parentCommentId}) async {
    if (commentController.text.trim().isEmpty) return;

    try {
      UserModel? currentUser = _authService.appUser.value;
      if (currentUser == null) throw 'المستخدم غير مسجل الدخول';

      CommentModel comment = CommentModel(
        id: '',
        postId: postId,
        userId: currentUser.id,
        authorName: currentUser.fullName,
        authorAvatar: currentUser.photoURL,
        content: commentController.text.trim(),
        parentCommentId: parentCommentId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await commentService.addComment(comment);
      commentController.clear();

      // Award points for commenting
      // await Get.find<GamificationController>().awardPoints('comment_post');

      // Reload comments
      await loadComments(postId);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل إضافة التعليق');
    }
  }

  Future<void> loadReplies(String postId, String commentId) async {
    try {
      isLoadingReplies.value = true;
      final result = await commentService.getCommentReplies(postId, commentId);
      replies.assignAll(result);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحميل الردود');
    } finally {
      isLoadingReplies.value = false;
    }
  }

  Future<void> toggleReplyLike(
    String postId,
    String replyId,
    String parentCommentId,
  ) async {
    try {
      final String userId = Get.find<AuthService>().currentUserId!;

      // تحديث محلي فوري
      final index = replies.indexWhere((reply) => reply.id == replyId);
      if (index != -1) {
        CommentModel reply = replies[index];
        List<String> newLikedBy = List.from(reply.likedBy);

        if (newLikedBy.contains(userId)) {
          newLikedBy.remove(userId);
        } else {
          newLikedBy.add(userId);
        }

        replies[index] = reply.copyWith(likedBy: newLikedBy);
      }

      // تحديث في Firestore
      await commentService.toggleCommentLike(postId, replyId, userId);
    } catch (e) {
      // في حالة الخطأ، إعادة تحميل الردود
      Get.snackbar('خطأ', 'فشل في تحديث إعجاب الرد');
    }
  }

  // تبديل الإعجاب على التعليق أو الرد
  Future<void> toggleCommentLike(
    String postId,
    String commentId,
    int commentIndex, // الفهرس في القائمة
  ) async {
    try {
      final String userId = Get.find<AuthService>().currentUserId!;

      // البحث عن التعليق في القائمة
      if (commentIndex < comments.length) {
        CommentModel comment = comments[commentIndex];

        // تحديث الحالة محلياً أولاً (لتحسين تجربة المستخدم)
        bool wasLiked = comment.isLikedBy(userId);
        List<String> newLikedBy = List.from(comment.likedBy);

        if (wasLiked) {
          newLikedBy.remove(userId);
        } else {
          newLikedBy.add(userId);
        }

        // تحديث التعليق محلياً
        comments[commentIndex] = comment.copyWith(
          likedBy: newLikedBy,
          updatedAt: DateTime.now(),
        );

        // تحديث الواجهة
        comments.refresh();

        // تحديث البيانات في Firestore
        await commentService.toggleCommentLike(postId, commentId, userId);
      }
    } catch (e) {
      // في حالة الخطأ، إعادة الحالة السابقة
      comments.refresh();
      Get.snackbar('خطأ', 'فشل في تحديث الإعجاب');
    }
  }

  // تبديل الإعجاب على الرد (للاستخدام في الـ Replies)

  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await commentService.deleteComment(postId, commentId);
      comments.removeWhere((comment) => comment.id == commentId);
      Get.snackbar('نجح', 'تم حذف التعليق بنجاح');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل حذف التعليق');
    }
  }

  // Load post details
  Future<void> loadPostDetails(String postId) async {
    try {
      PostModel? post = await _postService.getPost(postId);
      if (post != null) {
        currentPost.value = post;
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحميل تفاصيل المنشور');
    }
  }

  // Initialize edit form
  void initializeEditForm(PostModel post) {
    contentController.text = post.content;
    tags.assignAll(post.tags);
    currentPost.value = post;
  }

  // Clear form data
  void _clearForm() {
    contentController.clear();
    tagsController.clear();
    commentController.clear();
    selectedImages.clear();
    tags.clear();
    comments.clear();
    currentPost.value = null;
  }

  void setAudience(String title, String typeAudience) {
    selectedAudience.value = title;
    selectTypeAudicence.value = typeAudience;
  }

  
  // دالة إرسال التبليغ
  Future<void> submitPostReport({
    required String postId,
    required ReportReason reason,
    required String description,
  }) async {
    try {
      // التحقق من أن المستخدم لم يبلغ عن هذا المنشور من قبل
      bool alreadyReported = await reportService.hasUserReportedPost(postId);
      if (alreadyReported) {
        Get.snackbar('تنبيه', 'لقد قمت بالإبلاغ عن هذا المنشور مسبقاً');
        return;
      }

      // إرسال التبليغ
      await reportService.submitPostReport(
        postId: postId,
        reason: reason,
        description: description.isNotEmpty ? description : null,
      );

      Get.snackbar('تم', 'تم الإبلاغ عن المنشور بنجاح', 
        backgroundColor: Colors.green,
        colorText: Colors.white
      );
      
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في الإبلاغ عن المنشور: ${e.toString()}');
    }
  }

  @override
  void onClose() {
    contentController.dispose();
    commentController.dispose();
    tagsController.dispose();
    reportDescriptionController.dispose();
    super.onClose();
  }
}
