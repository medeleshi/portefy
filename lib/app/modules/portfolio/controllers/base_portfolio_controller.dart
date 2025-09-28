import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/portfolio_model.dart';
import '../../../services/portfolio_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/pagination_service.dart';

abstract class BasePortfolioController<T extends PortfolioItem> extends GetxController {
  final PortfolioService _portfolioService = PortfolioService();
  final AuthService _authService = Get.find<AuthService>();
  final PaginationService _paginationService = PaginationService();

  String? viewedUserId;

  // Pagination variables
  final RxList<T> items = <T>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  DocumentSnapshot? _lastDocument;
  final int pageSize = 15;
  
  // Search and filter
  final RxString searchQuery = ''.obs;
  final RxList<T> filteredItems = <T>[].obs;
  final RxString selectedFilter = ''.obs;
  final RxBool isSearching = false.obs;
  
  Future? _searchTimer;
  
  // Cache management
  late PaginationCache<T> _cache;
  
  // دالة للحصول على مفتاح الكاش بناءً على viewedUserId
  String get cacheKey {
    final userId = viewedUserId ?? _authService.currentUserId;
    return '${getItemType()}_$userId';
  }
  
  @override
  void onInit() {
    super.onInit();

    // تحديث viewedUserId من parameters أو من الـ constructor
    _updateViewedUserId();
    
    // الحل: استخدام دالة مساعدة للحصول على الكاش المناسب
    _cache = _getTypedCache();
    
    // Load cached data first if available and not stale
    if (!_cache.isEmpty && !_cache.isStale) {
      items.assignAll(_cache.items);
      hasMoreData.value = _cache.hasMore;
      _lastDocument = _cache.lastDocument;
      filterItems();
    } else {
      loadItems(refresh: true);
    }
    
    // Listen to search query changes with debouncing
    searchQuery.listen((query) {
      _debounceSearch(query);
    });
    
    // Listen to filter changes
    selectedFilter.listen((_) {
      refreshItems();
    });
  }

  // دالة لتحديث viewedUserId
  void _updateViewedUserId() {
    // الأولوية لـ Get.parameters ثم للقيمة الممررة عبر constructor
    viewedUserId = Get.parameters['userId'] ?? viewedUserId ?? _authService.currentUserId;
  }

  // دالة مساعدة للحصول على الكاش المناسب للنوع
  PaginationCache<T> _getTypedCache() {
    final dynamicCache = PaginationCacheManager.getCache(cacheKey);
    
    // إذا كان الكاش فارغاً أو من نوع مختلف، نعيد كاش جديد
    if (dynamicCache.isEmpty || dynamicCache.items is! List<T>) {
      return PaginationCache<T>();
    }
    
    // إذا كان الكاش يحتوي على العناصر الصحيحة، نستخدمه
    try {
      // محاولة تحويل الكاش إلى النوع المطلوب
      return dynamicCache as PaginationCache<T>;
    } catch (e) {
      // في حالة الفشل، نعيد كاش جديد
      return PaginationCache<T>();
    }
  }

  // Abstract methods to be implemented by subclasses
  Future<PaginationResult<T>> fetchItemsFromService(String userId, DocumentSnapshot? lastDocument, int pageSize);
  String getItemType();
  List<String> getFilterOptions() => [];
  
  // Load items with pagination
  Future<void> loadItems({bool refresh = false}) async {
    // تحديث viewedUserId قبل كل تحميل
    _updateViewedUserId();
    
    String? userId = viewedUserId;
    if (userId == null) {
      print('Error: userId is null in ${getItemType()} controller');
      return;
    }
    
    if (refresh) {
      _lastDocument = null;
      hasMoreData.value = true;
      items.clear();
      _cache.clear();
    }
    
    if (!hasMoreData.value || isLoading.value || isLoadingMore.value) return;
    
    try {
      if (items.isEmpty) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }
            
      PaginationResult<T> result = await fetchItemsFromService(userId, _lastDocument, pageSize);
      
      if (result.items.isNotEmpty) {
        items.addAll(result.items);
        _cache.addItems(result.items);
        _lastDocument = result.lastDocument;
        _cache.lastDocument = _lastDocument;
      }
      
      hasMoreData.value = result.hasMore;
      _cache.hasMore = result.hasMore;
      
      filterItems();
      
    } catch (e) {
      print('Error loading ${getItemType()} for user $userId: $e');
      Get.snackbar('خطأ', 'فشل تحميل ${getItemType()}: ${e.toString()}');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }
  
  // Load more items
  Future<void> loadMoreItems() async {
    if (!hasMoreData.value || isLoadingMore.value) return;
    await loadItems();
  }
  
  // Refresh items
  Future<void> refreshItems() async {
    await loadItems(refresh: true);
  }
  
  // Search with debouncing
  void _debounceSearch(String query) {
    if (_searchTimer != null) {
      // _searchTimer!.cancel();
    }
    
    _searchTimer = Future.delayed(Duration(milliseconds: 500), () {
      if (query.length >= 2) {
        performSearch(query);
      } else {
        filterItems();
      }
    });
  }
  
  // Perform search
  Future<void> performSearch(String query) async {
    if (query.isEmpty) {
      filterItems();
      return;
    }
    
    try {
      isSearching.value = true;
      // تحديث viewedUserId قبل البحث
      _updateViewedUserId();
      
      String? userId = viewedUserId;
      if (userId == null) return;
      
      // Use local search first (faster)
      List<T> localResults = items.where((item) => 
          matchesSearchQuery(item, query.toLowerCase())).toList();
      
      if (localResults.isNotEmpty || items.length < 50) {
        // If we have local results or small dataset, use local search
        filteredItems.assignAll(localResults);
      } else {
        // For large datasets, perform server-side search
        PaginationResult<T> searchResult = await performServerSearch(query, userId);
        filteredItems.assignAll(searchResult.items);
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل البحث: ${e.toString()}');
      filterItems(); // Fallback to local filtering
    } finally {
      isSearching.value = false;
    }
  }
  
  // Server-side search (to be overridden by subclasses if needed)
  Future<PaginationResult<T>> performServerSearch(String query, String userId) async {
    // Default implementation returns empty result
    return PaginationResult<T>(items: [], hasMore: false, totalFetched: 0);
  }
  
  // Filter items based on search query and filters
  void filterItems() {
    List<T> itemsToFilter = items.toList();
    
    // Apply text search filter
    if (searchQuery.value.isNotEmpty && searchQuery.value.length >= 2) {
      itemsToFilter = itemsToFilter.where((item) => 
          matchesSearchQuery(item, searchQuery.value.toLowerCase())).toList();
    }
    
    // Apply category/type filter
    if (selectedFilter.value.isNotEmpty) {
      itemsToFilter = itemsToFilter.where((item) => 
          matchesFilter(item, selectedFilter.value)).toList();
    }
    
    filteredItems.assignAll(itemsToFilter);
  }
  
  // Abstract methods for search and filter matching
  bool matchesSearchQuery(T item, String query);
  bool matchesFilter(T item, String filter) => true;
  
  // Add item
  Future<void> addItem(T item) async {
    try {
      items.insert(0, item); // Add to beginning for most recent first
      _cache.insertItem(0, item);
      filterItems();
      Get.snackbar('تم', 'تم إضافة ${getItemType()} بنجاح');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل إضافة ${getItemType()}');
    }
  }
  
  // Update item
  Future<void> updateItem(int index, T updatedItem) async {
    try {
      if (index >= 0 && index < items.length) {
        items[index] = updatedItem;
        _cache.updateItem(index, updatedItem);
        filterItems();
        Get.snackbar('تم', 'تم تحديث ${getItemType()} بنجاح');
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحديث ${getItemType()}');
    }
  }
  
  // Delete item
  Future<void> deleteItem(String id, int index) async {
    try {
      await deleteItemFromService(id);
      
      if (index >= 0 && index < items.length) {
        items.removeAt(index);
        _cache.removeItem(index);
        filterItems();
      }
      
      Get.snackbar('تم', 'تم حذف ${getItemType()} بنجاح');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل حذف ${getItemType()}');
    }
  }
  
  // Batch delete
  Future<void> deleteMultipleItems(List<String> ids, List<int> indices) async {
    try {
      isLoading.value = true;
      
      // Sort indices in descending order to avoid index shifting issues
      indices.sort((a, b) => b.compareTo(a));
      
      await _paginationService.batchDelete(
        collectionPath: getCollectionPath(),
        documentIds: ids,
      );
      
      // Remove items from local list
      for (int index in indices) {
        if (index >= 0 && index < items.length) {
          items.removeAt(index);
          _cache.removeItem(index);
        }
      }
      
      filterItems();
      Get.snackbar('تم', 'تم حذف ${ids.length} عنصر بنجاح');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل الحذف المتعدد: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Abstract method for deletion
  Future<void> deleteItemFromService(String id);
  
  String getCollectionPath() {
    // تحديث viewedUserId قبل استخدامه
    _updateViewedUserId();
    String? userId = viewedUserId;
    if (userId == null) {
      throw Exception('User ID is null in ${getItemType()} controller');
    }
    return 'users/$userId/portfolio/${getCollectionSubPath()}/items';
  }
  
  // دالة مساعدة للحصول على المسار الفرعي للمجموعة
  String getCollectionSubPath() {
    switch (getItemType()) {
      case 'التعليم': return 'education';
      case 'الخبرات': return 'experience';
      case 'المشاريع': return 'projects';
      case 'المهارات': return 'skills';
      case 'اللغات': return 'languages';
      case 'الشهادات': return 'certificates';
      case 'الأنشطة': return 'activities';
      case 'الهوايات': return 'hobbies';
      default: return getItemType().toLowerCase();
    }
  }
  
  // Get statistics
  Future<int> getTotalCount() async {
    try {
      return await _paginationService.getTotalCount(getCollectionPath());
    } catch (e) {
      return items.length; // Fallback to local count
    }
  }
  
  // Export data
  List<Map<String, dynamic>> exportData() {
    return items.map((item) => item.toMap()).toList();
  }
  
  // Clear cache
  void clearCache() {
    PaginationCacheManager.clearCache(cacheKey);
  }
  
  @override
  void onClose() {
    _searchTimer?.ignore();
    super.onClose();
  }
}

// Individual controllers implementation

class EducationController extends BasePortfolioController<EducationModel> {
  @override
  Future<PaginationResult<EducationModel>> fetchItemsFromService(
      String userId, DocumentSnapshot? lastDocument, int pageSize) async {
    return await _paginationService.getEducationPaginated(
      userId: userId,
      lastDocument: lastDocument,
      limit: pageSize,
    );
  }
  
  @override
  String getItemType() => 'التعليم';
  
  @override
  bool matchesSearchQuery(EducationModel item, String query) {
    return item.institution.toLowerCase().contains(query) ||
           item.degree.toLowerCase().contains(query) ||
           item.fieldOfStudy.toLowerCase().contains(query);
  }
  
  @override
  List<String> getFilterOptions() => ['الكل', 'بكالوريوس', 'ماجستير', 'دكتوراه', 'دبلوم'];
  
  @override
  bool matchesFilter(EducationModel item, String filter) {
    if (filter == 'الكل') return true;
    return item.degree.toLowerCase().contains(filter.toLowerCase());
  }
  
  @override
  Future<void> deleteItemFromService(String id) async {
    await _portfolioService.deleteEducation(id);
  }
}

class ExperienceController extends BasePortfolioController<ExperienceModel> {
  @override
  Future<PaginationResult<ExperienceModel>> fetchItemsFromService(
      String userId, DocumentSnapshot? lastDocument, int pageSize) async {
    return await _paginationService.getExperiencePaginated(
      userId: userId,
      lastDocument: lastDocument,
      limit: pageSize,
    );
  }
  
  @override
  String getItemType() => 'الخبرات';
  
  @override
  bool matchesSearchQuery(ExperienceModel item, String query) {
    return item.company.toLowerCase().contains(query) ||
           item.position.toLowerCase().contains(query) ||
           (item.location?.toLowerCase().contains(query) ?? false);
  }
  
  @override
  List<String> getFilterOptions() => ['الكل', 'حالي', 'سابق'];
  
  @override
  bool matchesFilter(ExperienceModel item, String filter) {
    switch (filter) {
      case 'حالي':
        return item.isCurrent;
      case 'سابق':
        return !item.isCurrent;
      default:
        return true;
    }
  }
  
  @override
  Future<void> deleteItemFromService(String id) async {
    await _portfolioService.deleteExperience(id);
  }
}

class ProjectsController extends BasePortfolioController<ProjectModel> {
  @override
  Future<PaginationResult<ProjectModel>> fetchItemsFromService(
      String userId, DocumentSnapshot? lastDocument, int pageSize) async {
    bool? completedFilter;
    if (selectedFilter.value == 'مكتمل') completedFilter = true;
    if (selectedFilter.value == 'قيد التنفيذ') completedFilter = false;
    
    return await _paginationService.getProjectsPaginated(
      userId: userId,
      lastDocument: lastDocument,
      limit: pageSize,
      isCompleted: completedFilter,
    );
  }
  
  @override
  String getItemType() => 'المشاريع';
  
  @override
  bool matchesSearchQuery(ProjectModel item, String query) {
    return item.title.toLowerCase().contains(query) ||
           item.description.toLowerCase().contains(query);
  }
  
  @override
  List<String> getFilterOptions() => ['الكل', 'مكتمل', 'قيد التنفيذ'];
  
  @override
  bool matchesFilter(ProjectModel item, String filter) {
    switch (filter) {
      case 'مكتمل':
        return item.isCompleted;
      case 'قيد التنفيذ':
        return !item.isCompleted;
      default:
        return true;
    }
  }
  
  @override
  Future<void> deleteItemFromService(String id) async {
    await _portfolioService.deleteProject(id);
  }
}

class SkillsController extends BasePortfolioController<SkillModel> {
  @override
  Future<PaginationResult<SkillModel>> fetchItemsFromService(
      String userId, DocumentSnapshot? lastDocument, int pageSize) async {
    String? categoryFilter;
    if (selectedFilter.value != 'الكل' && selectedFilter.value.isNotEmpty) {
      categoryFilter = selectedFilter.value;
    }
    
    return await _paginationService.getSkillsPaginated(
      userId: userId,
      lastDocument: lastDocument,
      limit: pageSize,
      category: categoryFilter,
    );
  }
  
  @override
  String getItemType() => 'المهارات';
  
  @override
  bool matchesSearchQuery(SkillModel item, String query) {
    return item.name.toLowerCase().contains(query) ||
           item.category.toLowerCase().contains(query);
  }
  
  @override
  List<String> getFilterOptions() => ['الكل', 'تقنية', 'ناعمة', 'أكاديمية'];
  
  @override
  bool matchesFilter(SkillModel item, String filter) {
    if (filter == 'الكل') return true;
    return item.category == filter;
  }
  
  @override
  Future<void> deleteItemFromService(String id) async {
    await _portfolioService.deleteSkill(id);
  }
}

class LanguagesController extends BasePortfolioController<LanguageModel> {
  @override
  Future<PaginationResult<LanguageModel>> fetchItemsFromService(
      String userId, DocumentSnapshot? lastDocument, int pageSize) async {
    return await _paginationService.getLanguagesPaginated(
      userId: userId,
      lastDocument: lastDocument,
      limit: pageSize,
    );
  }
  
  @override
  String getItemType() => 'اللغات';
  
  @override
  bool matchesSearchQuery(LanguageModel item, String query) {
    return item.name.toLowerCase().contains(query) ||
           item.proficiency.toLowerCase().contains(query);
  }
  
  @override
  List<String> getFilterOptions() => ['الكل', 'أصلي', 'طلق', 'متوسط', 'مبتدئ'];
  
  @override
  bool matchesFilter(LanguageModel item, String filter) {
    if (filter == 'الكل') return true;
    return item.proficiency == filter;
  }
  
  @override
  Future<void> deleteItemFromService(String id) async {
    await _portfolioService.deleteLanguage(id);
  }
}

class CertificatesController extends BasePortfolioController<CertificateModel> {
  @override
  Future<PaginationResult<CertificateModel>> fetchItemsFromService(
      String userId, DocumentSnapshot? lastDocument, int pageSize) async {
    bool? includeExpired = selectedFilter.value != 'ساري';
    
    return await _paginationService.getCertificatesPaginated(
      userId: userId,
      lastDocument: lastDocument,
      limit: pageSize,
      includeExpired: includeExpired,
    );
  }
  
  @override
  String getItemType() => 'الشهادات';
  
  @override
  bool matchesSearchQuery(CertificateModel item, String query) {
    return item.name.toLowerCase().contains(query) ||
           item.issuer.toLowerCase().contains(query);
  }
  
  @override
  List<String> getFilterOptions() => ['الكل', 'ساري', 'منتهي الصلاحية', 'ينتهي قريباً'];
  
  @override
  bool matchesFilter(CertificateModel item, String filter) {
    switch (filter) {
      case 'ساري':
        return !item.isExpired;
      case 'منتهي الصلاحية':
        return item.isExpired;
      case 'ينتهي قريباً':
        return item.isExpiringSoon;
      default:
        return true;
    }
  }
  
  @override
  Future<void> deleteItemFromService(String id) async {
    await _portfolioService.deleteCertificate(id);
  }
}

class ActivitiesController extends BasePortfolioController<ActivityModel> {
  @override
  Future<PaginationResult<ActivityModel>> fetchItemsFromService(
      String userId, DocumentSnapshot? lastDocument, int pageSize) async {
    String? typeFilter;
    if (selectedFilter.value != 'الكل' && selectedFilter.value.isNotEmpty) {
      typeFilter = selectedFilter.value;
    }
    
    return await _paginationService.getActivitiesPaginated(
      userId: userId,
      lastDocument: lastDocument,
      limit: pageSize,
      activityType: typeFilter,
    );
  }
  
  @override
  String getItemType() => 'الأنشطة';
  
  @override
  bool matchesSearchQuery(ActivityModel item, String query) {
    return item.title.toLowerCase().contains(query) ||
           item.organization.toLowerCase().contains(query) ||
           item.type.toLowerCase().contains(query);
  }
  
  @override
  List<String> getFilterOptions() => ['الكل', 'تطوعي', 'نادي', 'رياضي', 'خدمة مجتمع'];
  
  @override
  bool matchesFilter(ActivityModel item, String filter) {
    if (filter == 'الكل') return true;
    return item.type == filter;
  }
  
  @override
  Future<void> deleteItemFromService(String id) async {
    await _portfolioService.deleteActivity(id);
  }
}

class HobbiesController extends BasePortfolioController<HobbyModel> {
  @override
  Future<PaginationResult<HobbyModel>> fetchItemsFromService(
      String userId, DocumentSnapshot? lastDocument, int pageSize) async {
    String? categoryFilter;
    if (selectedFilter.value != 'الكل' && selectedFilter.value.isNotEmpty) {
      categoryFilter = selectedFilter.value;
    }
    
    return await _paginationService.getHobbiesPaginated(
      userId: userId,
      lastDocument: lastDocument,
      limit: pageSize,
      category: categoryFilter,
    );
  }
  
  @override
  String getItemType() => 'الهوايات';
  
  @override
  bool matchesSearchQuery(HobbyModel item, String query) {
    return item.name.toLowerCase().contains(query) ||
           (item.category?.toLowerCase().contains(query) ?? false);
  }
  
  @override
  List<String> getFilterOptions() => ['الكل', 'رياضة', 'فنون', 'موسيقى', 'قراءة', 'سفر'];
  
  @override
  bool matchesFilter(HobbyModel item, String filter) {
    if (filter == 'الكل') return true;
    return item.category == filter;
  }
  
  @override
  Future<void> deleteItemFromService(String id) async {
    await _portfolioService.deleteHobby(id);
  }
}