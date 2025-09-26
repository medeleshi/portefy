import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import 'notification_service.dart';
import 'user_service.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  final UserService _userService = UserService();
  
  // Collections
  String get postsCollection => 'posts';
  String get commentsCollection => 'comments';

  // Create post
  Future<String> createPost(PostModel post) async {
    try {
      DocumentReference docRef = await _firestore.collection(postsCollection).add(post.toMap());
      
      // Send notifications to relevant users
      await _sendNewPostNotifications(post);
      
      // Award points to user
      // await _userService.updateUs
      //erPoints(post.userId, 5); // 5 points for creating a post
      
      return docRef.id;
    } catch (e) {
      throw 'فشل إنشاء المنشور: ${e.toString()}';
    }
  }

  // Get posts with pagination and filters
  Future<List<PostModel>> getPosts({
    DocumentSnapshot? lastDocument,
    int limit = 10,
    Map<String, dynamic>? filterParams,
  }) async {
    try {
      Query query = _firestore
          .collection(postsCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      // Apply filters from filterParams
      if (filterParams != null) {
        filterParams.forEach((key, value) {
          if (value != null && value != '') {
            query = query.where(key, isEqualTo: value);
          }
        });
      }

      // Start after last document for pagination
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      QuerySnapshot querySnapshot = await query.get();
      
      return querySnapshot.docs.map((doc) {
        PostModel post = PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        // Attach DocumentSnapshot for pagination
        return post.copyWith(documentSnapshot: doc);
      }).toList();
    } catch (e) {
      throw 'فشل جلب المنشورات: ${e.toString()}';
    }
  }

  // Get posts stream for real-time updates
  Stream<List<PostModel>> getPostsStream({
    int limit = 10,
    Map<String, dynamic>? filterParams,
  }) {
    Query query = _firestore
        .collection(postsCollection)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    // Apply filters from filterParams
    if (filterParams != null) {
      filterParams.forEach((key, value) {
        if (value != null && value != '') {
          query = query.where(key, isEqualTo: value);
        }
      });
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) {
        PostModel post = PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        // Attach DocumentSnapshot for pagination
        return post.copyWith(documentSnapshot: doc);
      }).toList(),
    );
  }

  // Get single post
  Future<PostModel?> getPost(String postId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(postsCollection).doc(postId).get();
      if (doc.exists) {
        PostModel post = PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        return post.copyWith(documentSnapshot: doc);
      }
      return null;
    } catch (e) {
      throw 'فشل جلب المنشور: ${e.toString()}';
    }
  }

  // Update post
  Future<void> updatePost(String postId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = DateTime.now();
      data['isEdited'] = true;
      await _firestore.collection(postsCollection).doc(postId).update(data);
    } catch (e) {
      throw 'فشل تحديث المنشور: ${e.toString()}';
    }
  }

  // Delete post
  Future<void> deletePost(String postId) async {
    try {
      // Delete all comments for this post
      QuerySnapshot comments = await _firestore
          .collection(commentsCollection)
          .where('postId', isEqualTo: postId)
          .get();
      
      WriteBatch batch = _firestore.batch();
      for (QueryDocumentSnapshot comment in comments.docs) {
        batch.delete(comment.reference);
      }
      
      // Delete the post
      batch.delete(_firestore.collection(postsCollection).doc(postId));
      
      await batch.commit();
    } catch (e) {
      throw 'فشل حذف المنشور: ${e.toString()}';
    }
  }

  // Like/Unlike post
  Future<void> togglePostLike(String postId, String userId) async {
    try {
      DocumentReference postRef = _firestore.collection(postsCollection).doc(postId);
      
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot postDoc = await transaction.get(postRef);
        
        if (postDoc.exists) {
          PostModel post = PostModel.fromMap(postDoc.data() as Map<String, dynamic>, postDoc.id);
          List<String> likedBy = List<String>.from(post.likedBy);
          
          if (likedBy.contains(userId)) {
            // Unlike
            likedBy.remove(userId);
          } else {
            // Like
            likedBy.add(userId);
            
            // Send notification to post author if it's not the same user
            if (post.userId != userId) {
              await _notificationService.sendPostLikeNotification(
                postId: postId,
                postAuthorId: post.userId,
                likerId: userId,
              );
              
              // Award points to post author
              // await _userService.updateUserPoints(post.userId, 1); // 1 point for receiving a like
            }
          }
          
          transaction.update(postRef, {
            'likedBy': likedBy,
            'updatedAt': DateTime.now(),
          });
        }
      });
    } catch (e) {
      throw 'فشل في الإعجاب بالمنشور: ${e.toString()}';
    }
  }

  // Get user posts with pagination support
Future<List<PostModel>> getUserPosts(
  String userId, {
  int limit = 10,
  DocumentSnapshot? lastDocument,
}) async {
  try {
    Query query = _firestore
        .collection(postsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    // إضافة نقطة البداية للتصفح إذا كانت متوفرة
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    QuerySnapshot querySnapshot = await query.get();

    return querySnapshot.docs.map((doc) {
      PostModel post = PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      return post.copyWith(documentSnapshot: doc);
    }).toList();
  } catch (e) {
    throw 'فشل جلب منشورات المستخدم: ${e.toString()}';
  }
}

  // Search posts
  Future<List<PostModel>> searchPosts(String searchQuery, {int limit = 10}) async {
    try {
      // Basic text search (consider using Algolia for better search)
      QuerySnapshot query = await _firestore
          .collection(postsCollection)
          .where('content', isGreaterThanOrEqualTo: searchQuery)
          .where('content', isLessThan: searchQuery + 'z')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) {
        PostModel post = PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        return post.copyWith(documentSnapshot: doc);
      }).toList();
    } catch (e) {
      throw 'فشل البحث في المنشورات: ${e.toString()}';
    }
  }

  // Send new post notifications
  Future<void> _sendNewPostNotifications(PostModel post) async {
    try {
      // Get users to notify based on filters
      List<UserModel> usersToNotify = [];

      // Notify users from same university
      if (post.audience == 'university' && post.authorUniversity != null) {
        List<UserModel> universityUsers = await _userService.getUsersByUniversity(
          post.authorUniversity!,
          limit: 50,
        );
        usersToNotify.addAll(universityUsers);
      }

      // Notify users from same major
      if (post.authorUniversity != null && post.audience == 'major' && post.authorMajor != null) {
        List<UserModel> majorUsers = await _userService.getUsersByMajor(
          post.authorUniversity!,
          post.authorMajor!,
          limit: 50,
        );
        usersToNotify.addAll(majorUsers);
      }

      // Notify users from same Level
      if (post.authorUniversity != null && post.authorMajor != null && post.audience == 'level' && post.authorLevel != null) {
        List<UserModel> levelUsers = await _userService.getUsersByLevel(
          post.authorUniversity!,
          post.authorMajor!,
          post.authorLevel!,
          limit: 50,
        );
        usersToNotify.addAll(levelUsers);
      }

      // Remove duplicates and the post author
      usersToNotify = usersToNotify
          .where((user) => user.id != post.userId)
          .toSet()
          .toList();

      // Send notifications
      for (UserModel user in usersToNotify) {
        await _notificationService.sendNewPostNotification(
          postId: post.id,
          userId: user.id,
          authorName: post.authorName,
        );
      }
    } catch (e) {
      print('خطأ في إرسال إشعارات المنشور الجديد: $e');
    }
  }

  // Increment shares count
  Future<void> incrementSharesCount(String postId) async {
    try {
      await _firestore.collection(postsCollection).doc(postId).update({
        'sharesCount': FieldValue.increment(1),
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw 'فشل تحديث عداد المشاركات: ${e.toString()}';
    }
  }
}