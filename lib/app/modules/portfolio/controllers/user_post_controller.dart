import 'package:get/get.dart';
import '../../../models/post_model.dart';
import '../../../services/auth_service.dart';
import '../../home/controllers/base_posts_controller.dart';

class UserPostsController extends BasePostsController {
  final String? userId;
  
  UserPostsController({this.userId});

  @override
  String get filterKey => 'user_posts_${userId ?? 'current'}';

  @override
  Map<String, dynamic> get filterParams => {
    'userId': userId ?? Get.find<AuthService>().currentUserId,
  };

  @override
  String get sharedPrefsKey => 'lastSeen_user_posts_${userId ?? 'current'}';

  // Override to use getUserPosts from PostService
  @override
  Future<void> loadPosts({bool refresh = false}) async {
    if (isLoading.value && !refresh) return;

    try {
      isLoading.value = true;

      if (refresh) {
        posts.clear();
        lastDocument = null;
        hasMore.value = true;
        clearCache();
      }

      // Check cache first
      if (!refresh && isCacheValid()) {
        final cachedPosts = cache[filterKey];
        if (cachedPosts != null) {
          posts.assignAll(cachedPosts);
          isLoading.value = false;
          return;
        }
      }

      final targetUserId = userId ?? Get.find<AuthService>().currentUserId;
      if (targetUserId == null) {
        throw 'المستخدم غير مسجل الدخول';
      }

      List<PostModel> newPosts = await postService.getUserPosts(
        targetUserId,
        lastDocument: null,
        limit: pageSize,
      );

      posts.assignAll(newPosts);
      
      if (newPosts.isNotEmpty) {
        lastDocument = newPosts.last.documentSnapshot;
        updateCache(newPosts);
      }

      hasMore.value = newPosts.length == pageSize;

    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحميل المنشورات: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> loadMorePosts() async {
    if (isLoadingMore.value || !hasMore.value) return;

    try {
      isLoadingMore.value = true;

      final targetUserId = userId ?? Get.find<AuthService>().currentUserId;
      if (targetUserId == null) {
        throw 'المستخدم غير مسجل الدخول';
      }

      List<PostModel> newPosts = await postService.getUserPosts(
        targetUserId,
        lastDocument: lastDocument,
        limit: pageSize,
      );

      if (newPosts.isNotEmpty) {
        posts.addAll(newPosts);
        lastDocument = newPosts.last.documentSnapshot;
        
        // Update cache
        cache[filterKey] = posts.toList();
        cacheTimestamp[filterKey] = DateTime.now();
      }

      hasMore.value = newPosts.length == pageSize;

    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحميل المزيد من المنشورات');
    } finally {
      isLoadingMore.value = false;
    }
  }
}