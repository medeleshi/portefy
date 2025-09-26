import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // البحث في المنشورات
  Future<List<PostModel>> searchPosts(String query, {int limit = 20}) async {
    try {
      // البحث في محتوى المنشورات
      final contentQuery = _firestore
          .collection('posts')
          .where('content', isGreaterThanOrEqualTo: query)
          .where('content', isLessThan: query + 'z')
          .limit(limit)
          .get();

      // البحث في وسوم المنشورات
      final tagsQuery = _firestore
          .collection('posts')
          .where('tags', arrayContains: query)
          .limit(limit)
          .get();

      // الانتظار لجميع الاستعلامات
      final results = await Future.wait([contentQuery, tagsQuery]);

      // دمج النتائج وإزالة التكرارات
      final allPosts = results.expand((snapshot) => snapshot.docs).toList();
      final uniquePosts = allPosts.toSet().toList();

      return uniquePosts
          .map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'فشل البحث في المنشورات: ${e.toString()}';
    }
  }

  // البحث في المستخدمين
  Future<List<UserModel>> searchUsers(String query, {int limit = 20}) async {
    try {
      // البحث في الأسماء
      final nameQuery = _firestore
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThan: query + 'z')
          .limit(limit)
          .get();

      // البحث في التخصصات
      final majorQuery = _firestore
          .collection('users')
          .where('major', isGreaterThanOrEqualTo: query)
          .where('major', isLessThan: query + 'z')
          .limit(limit)
          .get();

      // البحث في الجامعات
      final universityQuery = _firestore
          .collection('users')
          .where('university', isGreaterThanOrEqualTo: query)
          .where('university', isLessThan: query + 'z')
          .limit(limit)
          .get();

      // الانتظار لجميع الاستعلامات
      final results = await Future.wait([nameQuery, majorQuery, universityQuery]);

      // دمج النتائج وإزالة التكرارات
      final allUsers = results.expand((snapshot) => snapshot.docs).toList();
      final uniqueUsers = allUsers.toSet().toList();

      return uniqueUsers
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'فشل البحث في المستخدمين: ${e.toString()}';
    }
  }

  // البحث المتقدم مع التصفية
  Future<List<PostModel>> advancedSearch({
    String? query,
    String? university,
    String? major,
    String? level,
    List<String>? tags,
    int limit = 20,
  }) async {
    try {
      Query searchQuery = _firestore.collection('posts');

      // تطبيق الفلاتر
      if (university != null && university.isNotEmpty) {
        searchQuery = searchQuery.where('authorUniversity', isEqualTo: university);
      }

      if (major != null && major.isNotEmpty) {
        searchQuery = searchQuery.where('authorMajor', isEqualTo: major);
      }

      if (level != null && level.isNotEmpty) {
        searchQuery = searchQuery.where('authorLevel', isEqualTo: level);
      }

      if (tags != null && tags.isNotEmpty) {
        for (final tag in tags) {
          searchQuery = searchQuery.where('tags', arrayContains: tag);
        }
      }

      // تطبيق الحد
      searchQuery = searchQuery.limit(limit);

      final results = await searchQuery.get();

      return results.docs
          .map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'فشل البحث المتقدم: ${e.toString()}';
    }
  }

  // الحصول على الاقتراحات التلقائية
  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      // اقتراحات من الوسوم
      final tagsQuery = _firestore
          .collection('posts')
          .where('tags', arrayContains: query)
          .limit(5)
          .get();

      // اقتراحات من المحتوى
      final contentQuery = _firestore
          .collection('posts')
          .where('content', isGreaterThanOrEqualTo: query)
          .where('content', isLessThan: query + 'z')
          .limit(5)
          .get();

      final results = await Future.wait([tagsQuery, contentQuery]);

      // استخراج الاقتراحات
      final suggestions = <String>{};
      
      for (final snapshot in results) {
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          
          // إضافة الوسوم
          final postTags = List<String>.from(data['tags'] ?? []);
          for (final tag in postTags) {
            if (tag.toLowerCase().contains(query.toLowerCase())) {
              suggestions.add(tag);
            }
          }
          
          // إضافة كلمات من المحتوى
          final content = data['content'] as String? ?? '';
          final words = content.split(' ');
          for (final word in words) {
            if (word.toLowerCase().contains(query.toLowerCase()) && word.length > 2) {
              suggestions.add(word);
            }
          }
        }
      }

      return suggestions.toList().take(10).toList();
    } catch (e) {
      return [];
    }
  }

  // الحصول على المنشورات الشائعة
  Future<List<PostModel>> getTrendingPosts({int limit = 10}) async {
    try {
      final weekAgo = DateTime.now().subtract(Duration(days: 7));
      
      final query = _firestore
          .collection('posts')
          .where('createdAt', isGreaterThan: weekAgo)
          .orderBy('createdAt', descending: true)
          .limit(limit * 3); // للحصول على المزيد للترتيب

      final results = await query.get();

      final posts = results.docs
          .map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // ترتيب حسب التفاعل
      posts.sort((a, b) => b.engagementScore.compareTo(a.engagementScore));

      return posts.take(limit).toList();
    } catch (e) {
      throw 'فشل جلب المنشورات الشائعة: ${e.toString()}';
    }
  }

  // الحصول على الوسوم الشائعة
  Future<List<String>> getPopularTags({int limit = 10}) async {
    try {
      final weekAgo = DateTime.now().subtract(Duration(days: 7));
      
      final query = _firestore
          .collection('posts')
          .where('createdAt', isGreaterThan: weekAgo)
          .limit(100); // عينة من المنشورات الحديثة

      final results = await query.get();

      final tagCount = <String, int>{};
      
      for (final doc in results.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final tags = List<String>.from(data['tags'] ?? []);
        
        for (final tag in tags) {
          tagCount[tag] = (tagCount[tag] ?? 0) + 1;
        }
      }

      // ترتيب الوسوم حسب الشعبية
      final sortedTags = tagCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedTags.take(limit).map((entry) => entry.key).toList();
    } catch (e) {
      return [];
    }
  }
}