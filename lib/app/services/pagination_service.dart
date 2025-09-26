import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/portfolio_model.dart';

class PaginationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generic pagination method
  Future<PaginationResult<T>> getPaginatedData<T extends PortfolioItem>({
    required String collectionPath,
    required T Function(Map<String, dynamic> data, String id) fromMap,
    DocumentSnapshot? lastDocument,
    int limit = 10,
    String? orderByField,
    bool descending = true,
    Map<String, dynamic>? whereConditions,
  }) async {
    try {
      Query query = _firestore.collection(collectionPath);

      // Apply where conditions
      if (whereConditions != null) {
        whereConditions.forEach((field, value) {
          if (value is List) {
            query = query.where(field, whereIn: value);
          } else {
            query = query.where(field, isEqualTo: value);
          }
        });
      }

      // Apply ordering
      if (orderByField != null) {
        query = query.orderBy(orderByField, descending: descending);
      }

      // Apply pagination
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      query = query.limit(limit);

      QuerySnapshot snapshot = await query.get();

      List<T> items = snapshot.docs.map((doc) {
        return fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      return PaginationResult<T>(
        items: items,
        lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
        hasMore: items.length == limit,
        totalFetched: items.length,
      );
    } catch (e) {
      throw 'فشل جلب البيانات: ${e.toString()}';
    }
  }

  // Education pagination
  Future<PaginationResult<EducationModel>> getEducationPaginated({
    required String userId,
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    return await getPaginatedData<EducationModel>(
      collectionPath: 'users/$userId/portfolio/education/items',
      fromMap: (data, id) => EducationModel.fromMap(data, id),
      lastDocument: lastDocument,
      limit: limit,
      orderByField: 'startDate',
      descending: true,
    );
  }

  // Experience pagination
  Future<PaginationResult<ExperienceModel>> getExperiencePaginated({
    required String userId,
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    return await getPaginatedData<ExperienceModel>(
      collectionPath: 'users/$userId/portfolio/experience/items',
      fromMap: (data, id) => ExperienceModel.fromMap(data, id),
      lastDocument: lastDocument,
      limit: limit,
      orderByField: 'startDate',
      descending: true,
    );
  }

  // Projects pagination
  Future<PaginationResult<ProjectModel>> getProjectsPaginated({
    required String userId,
    DocumentSnapshot? lastDocument,
    int limit = 10,
    bool? isCompleted,
  }) async {
    Map<String, dynamic>? whereConditions;
    if (isCompleted != null) {
      whereConditions = {'isCompleted': isCompleted};
    }

    return await getPaginatedData<ProjectModel>(
      collectionPath: 'users/$userId/portfolio/projects/items',
      fromMap: (data, id) => ProjectModel.fromMap(data, id),
      lastDocument: lastDocument,
      limit: limit,
      orderByField: 'createdAt',
      descending: true,
      whereConditions: whereConditions,
    );
  }

  // Skills pagination with category filter
  Future<PaginationResult<SkillModel>> getSkillsPaginated({
    required String userId,
    DocumentSnapshot? lastDocument,
    int limit = 10,
    String? category,
  }) async {
    Map<String, dynamic>? whereConditions;
    if (category != null) {
      whereConditions = {'category': category};
    }

    return await getPaginatedData<SkillModel>(
      collectionPath: 'users/$userId/portfolio/skills/items',
      fromMap: (data, id) => SkillModel.fromMap(data, id),
      lastDocument: lastDocument,
      limit: limit,
      orderByField: 'name',
      descending: false,
      whereConditions: whereConditions,
    );
  }

  // Languages pagination
  Future<PaginationResult<LanguageModel>> getLanguagesPaginated({
    required String userId,
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    return await getPaginatedData<LanguageModel>(
      collectionPath: 'users/$userId/portfolio/languages/items',
      fromMap: (data, id) => LanguageModel.fromMap(data, id),
      lastDocument: lastDocument,
      limit: limit,
      orderByField: 'name',
      descending: false,
    );
  }

  // Certificates pagination
  Future<PaginationResult<CertificateModel>> getCertificatesPaginated({
    required String userId,
    DocumentSnapshot? lastDocument,
    int limit = 10,
    bool? includeExpired = true,
  }) async {
    Map<String, dynamic>? whereConditions;
    
    // Filter out expired certificates if needed
    if (includeExpired == false) {
      whereConditions = {
        'expiryDate': null, // Only certificates without expiry
      };
      // Note: For more complex filtering of expired certificates,
      // you might need to implement client-side filtering
    }

    return await getPaginatedData<CertificateModel>(
      collectionPath: 'users/$userId/portfolio/certificates/items',
      fromMap: (data, id) => CertificateModel.fromMap(data, id),
      lastDocument: lastDocument,
      limit: limit,
      orderByField: 'issueDate',
      descending: true,
      whereConditions: whereConditions,
    );
  }

  // Activities pagination
  Future<PaginationResult<ActivityModel>> getActivitiesPaginated({
    required String userId,
    DocumentSnapshot? lastDocument,
    int limit = 10,
    String? activityType,
  }) async {
    Map<String, dynamic>? whereConditions;
    if (activityType != null) {
      whereConditions = {'type': activityType};
    }

    return await getPaginatedData<ActivityModel>(
      collectionPath: 'users/$userId/portfolio/activities/items',
      fromMap: (data, id) => ActivityModel.fromMap(data, id),
      lastDocument: lastDocument,
      limit: limit,
      orderByField: 'startDate',
      descending: true,
      whereConditions: whereConditions,
    );
  }

  // Hobbies pagination
  Future<PaginationResult<HobbyModel>> getHobbiesPaginated({
    required String userId,
    DocumentSnapshot? lastDocument,
    int limit = 10,
    String? category,
  }) async {
    Map<String, dynamic>? whereConditions;
    if (category != null) {
      whereConditions = {'category': category};
    }

    return await getPaginatedData<HobbyModel>(
      collectionPath: 'users/$userId/portfolio/hobbies/items',
      fromMap: (data, id) => HobbyModel.fromMap(data, id),
      lastDocument: lastDocument,
      limit: limit,
      orderByField: 'name',
      descending: false,
      whereConditions: whereConditions,
    );
  }

  // Search functionality with pagination
  Future<PaginationResult<T>> searchPaginated<T extends PortfolioItem>({
    required String collectionPath,
    required T Function(Map<String, dynamic> data, String id) fromMap,
    required String searchField,
    required String searchTerm,
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    try {
      // For full-text search, you might want to use Algolia or similar service
      // This is a basic implementation for simple text matching
      
      Query query = _firestore.collection(collectionPath)
          .where(searchField, isGreaterThanOrEqualTo: searchTerm)
          .where(searchField, isLessThan: searchTerm + '\uf8ff')
          .orderBy(searchField);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      query = query.limit(limit);

      QuerySnapshot snapshot = await query.get();

      List<T> items = snapshot.docs.map((doc) {
        return fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      return PaginationResult<T>(
        items: items,
        lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
        hasMore: items.length == limit,
        totalFetched: items.length,
      );
    } catch (e) {
      throw 'فشل البحث: ${e.toString()}';
    }
  }

  // Get total count for a collection (for displaying total items)
  Future<int> getTotalCount(String collectionPath, {Map<String, dynamic>? whereConditions}) async {
    try {
      Query query = _firestore.collection(collectionPath);

      if (whereConditions != null) {
        whereConditions.forEach((field, value) {
          query = query.where(field, isEqualTo: value);
        });
      }

      AggregateQuerySnapshot snapshot = await query.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      // Fallback to getting all documents and counting (not recommended for large collections)
      QuerySnapshot snapshot = await _firestore.collection(collectionPath).get();
      return snapshot.docs.length;
    }
  }

  // Batch operations for better performance
  Future<void> batchUpdate({
    required String collectionPath,
    required List<String> documentIds,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      WriteBatch batch = _firestore.batch();

      for (String docId in documentIds) {
        DocumentReference docRef = _firestore.collection(collectionPath).doc(docId);
        batch.update(docRef, updateData);
      }

      await batch.commit();
    } catch (e) {
      throw 'فشل التحديث المجمع: ${e.toString()}';
    }
  }

  // Batch delete
  Future<void> batchDelete({
    required String collectionPath,
    required List<String> documentIds,
  }) async {
    try {
      WriteBatch batch = _firestore.batch();

      for (String docId in documentIds) {
        DocumentReference docRef = _firestore.collection(collectionPath).doc(docId);
        batch.delete(docRef);
      }

      await batch.commit();
    } catch (e) {
      throw 'فشل الحذف المجمع: ${e.toString()}';
    }
  }

  // Real-time pagination with streams
  Stream<PaginationResult<T>> getPaginatedStream<T extends PortfolioItem>({
    required String collectionPath,
    required T Function(Map<String, dynamic> data, String id) fromMap,
    int limit = 10,
    String? orderByField,
    bool descending = true,
  }) {
    Query query = _firestore.collection(collectionPath);

    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }

    query = query.limit(limit);

    return query.snapshots().map((snapshot) {
      List<T> items = snapshot.docs.map((doc) {
        return fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      return PaginationResult<T>(
        items: items,
        lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
        hasMore: items.length == limit,
        totalFetched: items.length,
      );
    });
  }

  // Get aggregated statistics
  Future<Map<String, int>> getPortfolioStatistics(String userId) async {
    try {
      Map<String, int> stats = {};

      // Count education items
      stats['education'] = await getTotalCount('users/$userId/portfolio/education/items');
      
      // Count experience items
      stats['experience'] = await getTotalCount('users/$userId/portfolio/experience/items');
      
      // Count projects
      stats['projects'] = await getTotalCount('users/$userId/portfolio/projects/items');
      
      // Count skills
      stats['skills'] = await getTotalCount('users/$userId/portfolio/skills/items');
      
      // Count languages
      stats['languages'] = await getTotalCount('users/$userId/portfolio/languages/items');
      
      // Count certificates
      stats['certificates'] = await getTotalCount('users/$userId/portfolio/certificates/items');
      
      // Count activities
      stats['activities'] = await getTotalCount('users/$userId/portfolio/activities/items');
      
      // Count hobbies
      stats['hobbies'] = await getTotalCount('users/$userId/portfolio/hobbies/items');

      return stats;
    } catch (e) {
      throw 'فشل جلب الإحصائيات: ${e.toString()}';
    }
  }
}

// Pagination result class
class PaginationResult<T> {
  final List<T> items;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;
  final int totalFetched;

  PaginationResult({
    required this.items,
    this.lastDocument,
    required this.hasMore,
    required this.totalFetched,
  });

  PaginationResult<T> copyWith({
    List<T>? items,
    DocumentSnapshot? lastDocument,
    bool? hasMore,
    int? totalFetched,
  }) {
    return PaginationResult<T>(
      items: items ?? this.items,
      lastDocument: lastDocument ?? this.lastDocument,
      hasMore: hasMore ?? this.hasMore,
      totalFetched: totalFetched ?? this.totalFetched,
    );
  }
}

// في ملف الخدمات أو في نهاية base_portfolio_controller.dart

// Cache manager for pagination
class PaginationCacheManager {
  static final Map<String, PaginationCache<dynamic>> _cache = {};
  
  static PaginationCache<dynamic> getCache(String key) {
    if (!_cache.containsKey(key)) {
      _cache[key] = PaginationCache<dynamic>();
    }
    return _cache[key]!;
  }
  
  static void clearCache(String key) {
    _cache.remove(key);
  }
  
  static void clearAllCache() {
    _cache.clear();
  }
  
  // دالة جديدة للحصول على كاش بنوع محدد
  static PaginationCache<T> getTypedCache<T>(String key) {
    final cache = getCache(key);
    
    // التحقق من أن العناصر هي من النوع المطلوب
    if (cache.items.isNotEmpty && cache.items.first is! T) {
      // إذا كانت العناصر ليست من النوع المطلوب، نعيد كاش جديد
      _cache[key] = PaginationCache<T>();
      return _cache[key] as PaginationCache<T>;
    }
    
    return cache as PaginationCache<T>;
  }
}

class PaginationCache<T> {
  final List<T> items = [];
  DocumentSnapshot? lastDocument;
  bool hasMore = true;
  DateTime? lastUpdated;
  
  void addItems(List<T> newItems) {
    items.addAll(newItems);
    lastUpdated = DateTime.now();
  }
  
  void insertItem(int index, T item) {
    items.insert(index, item);
    lastUpdated = DateTime.now();
  }
  
  void removeItem(int index) {
    if (index >= 0 && index < items.length) {
      items.removeAt(index);
      lastUpdated = DateTime.now();
    }
  }
  
  void updateItem(int index, T item) {
    if (index >= 0 && index < items.length) {
      items[index] = item;
      lastUpdated = DateTime.now();
    }
  }
  
  void clear() {
    items.clear();
    lastDocument = null;
    hasMore = true;
    lastUpdated = null;
  }
  
  bool get isEmpty => items.isEmpty;
  int get length => items.length;
  
  // Check if cache is stale (older than 5 minutes)
  bool get isStale {
    if (lastUpdated == null) return true;
    return DateTime.now().difference(lastUpdated!).inMinutes > 5;
  }
}