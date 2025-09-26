import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../../../models/post_model.dart';
import '../../../services/post_service.dart';
import '../../../services/auth_service.dart';

abstract class BasePostsController extends GetxController {
  final PostService _postService = PostService();
  final AuthService _authService = Get.find<AuthService>();

  // Observables
  final RxList<PostModel> posts = <PostModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxInt newPostsBadgeCount = 0.obs;

  // Pagination
  DocumentSnapshot? lastDocument;
  final int pageSize = 10;

  // State management
  final RxBool _isInitialized = false.obs;
  bool get isInitialized => _isInitialized.value;

  // Cache - made protected for subclass access
  final Map<String, List<PostModel>> _cache = {};
  final Map<String, DateTime> _cacheTimestamp = {};
  final Duration cacheExpiry = Duration(minutes: 5);

  // Protected getters for subclasses
  Map<String, List<PostModel>> get cache => _cache;
  Map<String, DateTime> get cacheTimestamp => _cacheTimestamp;
  PostService get postService => _postService;

  // Real-time listener
  StreamSubscription? _newestPostsSubscription;
  DateTime? _lastSeenTimestamp;

  // Abstract methods to be implemented by concrete controllers
  String get filterKey; // Unique key for this filter
  Map<String, dynamic> get filterParams; // Parameters for the query
  String get sharedPrefsKey => 'lastSeen_$filterKey';

  @override
  void onInit() {
    super.onInit();
    _initializeLastSeen();
    _startRealtimeListener();
    // Don't auto-load posts in onInit, let the UI decide when to load
  }

  // Load posts only when explicitly called (lazy loading)
  Future<void> ensureDataLoaded() async {
    if (!_isInitialized.value && posts.isEmpty && !isLoading.value) {
      _isInitialized.value = true;
      await loadPosts();
    }
  }

  Future<void> _initializeLastSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSeenStr = prefs.getString(sharedPrefsKey);
    if (lastSeenStr != null) {
      _lastSeenTimestamp = DateTime.parse(lastSeenStr);
    } else {
      _lastSeenTimestamp = DateTime.now();
      await _updateLastSeen();
    }
  }

  Future<void> _updateLastSeen() async {
    final prefs = await SharedPreferences.getInstance();
    _lastSeenTimestamp = DateTime.now();
    await prefs.setString(
      sharedPrefsKey,
      _lastSeenTimestamp!.toIso8601String(),
    );
    newPostsBadgeCount.value = 0;
  }

  // Public method to update last seen without refreshing posts
  Future<void> updateLastSeenOnly() async {
    await _updateLastSeen();
  }

  void _startRealtimeListener() {
    _newestPostsSubscription = _postService
        .getPostsStream(limit: 1, filterParams: filterParams)
        .listen((posts) {
          if (posts.isNotEmpty) {
            final newestPost = posts.first;
            if (_lastSeenTimestamp != null &&
                newestPost.createdAt.isAfter(_lastSeenTimestamp!) &&
                newestPost.userId != _authService.currentUserId) {
              newPostsBadgeCount.value++;
            }
          }
        });
  }

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
        final cachedPosts = _cache[filterKey];
        if (cachedPosts != null) {
          posts.assignAll(cachedPosts);
          isLoading.value = false;
          return;
        }
      }

      List<PostModel> newPosts = await _postService.getPosts(
        lastDocument: null,
        limit: pageSize,
        filterParams: filterParams,
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

  Future<void> loadMorePosts() async {
    if (isLoadingMore.value || !hasMore.value) return;

    try {
      isLoadingMore.value = true;

      List<PostModel> newPosts = await _postService.getPosts(
        lastDocument: lastDocument,
        limit: pageSize,
        filterParams: filterParams,
      );

      if (newPosts.isNotEmpty) {
        posts.addAll(newPosts);
        lastDocument = newPosts.last.documentSnapshot;

        // Update cache
        _cache[filterKey] = posts.toList();
        _cacheTimestamp[filterKey] = DateTime.now();
      }

      hasMore.value = newPosts.length == pageSize;
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحميل المزيد من المنشورات');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshPosts() async {
    await _updateLastSeen();
    await loadPosts(refresh: true);
  }

  void insertLocalPost(PostModel post) {
    // Insert at the beginning of the list
    posts.insert(0, post);

    // Update cache
    _cache[filterKey] = posts.toList();
    _cacheTimestamp[filterKey] = DateTime.now();
  }

  Future<void> toggleLike(String postId, int index) async {
    try {
      String? userId = _authService.currentUserId;
      if (userId == null) return;

      PostModel post = posts[index];
      bool isLiking = !post.likedBy.contains(userId);

      await _postService.togglePostLike(postId, userId);

      List<String> likedBy = List<String>.from(post.likedBy);

      if (likedBy.contains(userId)) {
        likedBy.remove(userId);
      } else {
        likedBy.add(userId);
      }

      posts[index] = post.copyWith(likedBy: likedBy);

      // Update cache
      _cache[filterKey] = posts.toList();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في الإعجاب بالمنشور');
    }
  }

  // Protected methods for subclass access
  bool isCacheValid() {
    final timestamp = _cacheTimestamp[filterKey];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < cacheExpiry;
  }

  void updateCache(List<PostModel> newPosts) {
    _cache[filterKey] = newPosts;
    _cacheTimestamp[filterKey] = DateTime.now();
  }

  void clearCache() {
    _cache.remove(filterKey);
    _cacheTimestamp.remove(filterKey);
  }

  @override
  void onClose() {
    _newestPostsSubscription?.cancel();
    super.onClose();
  }

  void deletePost(String id) async {
    isLoading.value = true;

    try {
      // ne9es delete images
      
      posts.removeWhere((post) => post.id == id);
      await _postService.deletePost(id);
    } catch (e) {
      throw '${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }
}
