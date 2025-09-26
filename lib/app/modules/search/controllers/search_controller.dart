import 'package:get/get.dart';
import '../../../models/post_model.dart';
import '../../../models/user_model.dart';
import '../../../services/search_service.dart';

class SearchPortefyController extends GetxController {
  final SearchService _searchService = SearchService();

  // نتائج البحث
  final RxList<PostModel> searchResults = <PostModel>[].obs;
  final RxList<UserModel> userResults = <UserModel>[].obs;
  final RxList<String> searchSuggestions = <String>[].obs;
  final RxList<String> popularTags = <String>[].obs;

  // حالة التحميل
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;

  // استعلام البحث الحالي
  final RxString currentQuery = ''.obs;
  final RxString searchType = 'posts'.obs; // 'posts' أو 'users'

  // التصفية
  final RxString selectedUniversity = ''.obs;
  final RxString selectedMajor = ''.obs;
  final RxString selectedLevel = ''.obs;
  final RxList<String> selectedTags = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPopularTags();
    loadTrendingPosts();
  }

  // البحث في المنشورات
  Future<void> searchPosts(String query) async {
    try {
      isLoading.value = true;
      currentQuery.value = query;
      searchType.value = 'posts';
      
      final results = await _searchService.searchPosts(query);
      searchResults.assignAll(results);
      userResults.clear();
      
      // حفظ الاقتراحات
      final suggestions = await _searchService.getSearchSuggestions(query);
      searchSuggestions.assignAll(suggestions);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل البحث في المنشورات');
    } finally {
      isLoading.value = false;
    }
  }

  // البحث في المستخدمين
  Future<void> searchUsers(String query) async {
    try {
      isLoading.value = true;
      currentQuery.value = query;
      searchType.value = 'users';
      
      final results = await _searchService.searchUsers(query);
      userResults.assignAll(results);
      searchResults.clear();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل البحث في المستخدمين');
    } finally {
      isLoading.value = false;
    }
  }

  // البحث المتقدم
  Future<void> advancedSearch() async {
    try {
      isLoading.value = true;
      
      final results = await _searchService.advancedSearch(
        query: currentQuery.value,
        university: selectedUniversity.value.isEmpty ? null : selectedUniversity.value,
        major: selectedMajor.value.isEmpty ? null : selectedMajor.value,
        level: selectedLevel.value.isEmpty ? null : selectedLevel.value,
        tags: selectedTags.isEmpty ? null : selectedTags,
      );
      
      searchResults.assignAll(results);
      searchType.value = 'posts';
    } catch (e) {
      Get.snackbar('خطأ', 'فشل البحث المتقدم');
    } finally {
      isLoading.value = false;
    }
  }

  // الحصول على الاقتراحات التلقائية
  Future<void> getSuggestions(String query) async {
    if (query.length < 2) {
      searchSuggestions.clear();
      return;
    }
    
    try {
      final suggestions = await _searchService.getSearchSuggestions(query);
      searchSuggestions.assignAll(suggestions);
    } catch (e) {
      // تجاهل الأخطاء في الاقتراحات
    }
  }

  // الحصول على الوسوم الشائعة
  Future<void> loadPopularTags() async {
    try {
      final tags = await _searchService.getPopularTags();
      popularTags.assignAll(tags);
    } catch (e) {
      // تجاهل الأخطاء
    }
  }

  // الحصول على المنشورات الشائعة
  Future<void> loadTrendingPosts() async {
    try {
      isLoading.value = true;
      final posts = await _searchService.getTrendingPosts();
      searchResults.assignAll(posts);
      searchType.value = 'posts';
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحميل المنشورات الشائعة');
    } finally {
      isLoading.value = false;
    }
  }

  // مسح نتائج البحث
  void clearSearch() {
    searchResults.clear();
    userResults.clear();
    currentQuery.value = '';
    searchSuggestions.clear();
    clearFilters();
  }

  // مسح الفلاتر
  void clearFilters() {
    selectedUniversity.value = '';
    selectedMajor.value = '';
    selectedLevel.value = '';
    selectedTags.clear();
  }

  // تبديل نوع البحث
  void toggleSearchType() {
    if (searchType.value == 'posts') {
      searchType.value = 'users';
      if (currentQuery.value.isNotEmpty) {
        searchUsers(currentQuery.value);
      }
    } else {
      searchType.value = 'posts';
      if (currentQuery.value.isNotEmpty) {
        searchPosts(currentQuery.value);
      }
    }
  }

  // إضافة/إزالة وسوم من الفلاتر
  void toggleTagFilter(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
  }

  // التحقق إذا كان الوسم مفعل
  bool isTagSelected(String tag) {
    return selectedTags.contains(tag);
  }

  // الحصول على عدد النتائج
  int get resultCount {
    if (searchType.value == 'posts') {
      return searchResults.length;
    } else {
      return userResults.length;
    }
  }

  // التحقق إذا كانت هناك نتائج
  bool get hasResults {
    if (searchType.value == 'posts') {
      return searchResults.isNotEmpty;
    } else {
      return userResults.isNotEmpty;
    }
  }

  // التحقق إذا كان البحث نشطاً
  bool get isSearching {
    return currentQuery.value.isNotEmpty;
  }
}