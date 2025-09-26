import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';
import 'notification_service.dart';
import 'user_service.dart';

class PaginatedComments {
  final List<CommentModel> comments;
  final DocumentSnapshot? lastDoc;
  final bool? hasMore;

  PaginatedComments({required this.comments, this.lastDoc, this.hasMore});
}

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  final UserService _userService = UserService();

  // Collections
  String get postsCollection => 'posts';

  // Add comment
  Future<String> addComment(CommentModel comment) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(postsCollection)
          .doc(comment.postId)
          .collection('comments')
          .add(comment.toMap());

      // Update post comments count
      await _updatePostCommentsCount(comment.postId, 1);

      // Update parent comment replies count if it's a reply
      if (comment.parentCommentId != null) {
        await _updateCommentRepliesCount(
          comment.postId,
          comment.parentCommentId!,
          1,
        );
      }

      // Send notification
      await _sendCommentNotification(comment);

      // Award points
      // await _userService.updateUserPoints(comment.userId, 2);

      return docRef.id;
    } catch (e) {
      throw 'فشل إضافة التعليق: ${e.toString()}';
    }
  }

  // Get comments for a post with pagination
  // جلب تعليقات المنشور مع التقسيم إلى صفحات
  Future<PaginatedComments> getPostComments(
    String postId, {
    int limit = 20,
    DocumentSnapshot? lastDoc,
  }) async {
    Query query = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .where('parentCommentId', isNull: true)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    QuerySnapshot querySnapshot = await query.get();

    final comments = querySnapshot.docs
        .map(
          (doc) =>
              CommentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();

    // ✅ إرجاع النتيجة مع التحقق من وجود المزيد
    return PaginatedComments(
      comments: comments,
      lastDoc: querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null,
      hasMore: comments.length == limit, // ✅ هذا مهم جداً
    );
  }

  // Get replies for a comment with pagination
  // جلب الردود على تعليق مع التقسيم إلى صفحات
  Future<List<CommentModel>> getCommentReplies(
    String postId,
    String commentId, {
    int limit = 10,
    DocumentSnapshot? lastDoc,
  }) async {
    try {
      // بناء الاستعلام لجلب الردود الخاصة بالتعليق
      Query query = _firestore
          .collection(postsCollection)
          .doc(postId)
          .collection('comments')
          .where(
            'parentCommentId',
            isEqualTo: commentId,
          ) // الردود على التعليق المحدد
          .orderBy(
            'createdAt',
            descending: false,
          ) // الترتيب من الأقدم إلى الأحدث
          .limit(limit);

      // إذا كان هناك مستند أخير، البدء من بعده
      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      QuerySnapshot querySnapshot = await query.get();

      // تحويل البيانات إلى نموذج التعليق
      return querySnapshot.docs
          .map(
            (doc) => CommentModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw 'فشل جلب الردود: ${e.toString()}'; // رمي خطأ في حالة الفشل
    }
  }

  // Update comment
  Future<void> updateComment(
    String postId,
    String commentId,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updatedAt'] = DateTime.now();
      data['isEdited'] = true;
      await _firestore
          .collection(postsCollection)
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .update(data);
    } catch (e) {
      throw 'فشل تحديث التعليق: ${e.toString()}';
    }
  }

  // Delete comment
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      DocumentReference commentRef = _firestore
          .collection(postsCollection)
          .doc(postId)
          .collection('comments')
          .doc(commentId);

      DocumentSnapshot commentDoc = await commentRef.get();
      if (!commentDoc.exists) return;

      CommentModel comment = CommentModel.fromMap(
        commentDoc.data() as Map<String, dynamic>,
        commentDoc.id,
      );

      // Delete all replies
      QuerySnapshot replies = await _firestore
          .collection(postsCollection)
          .doc(postId)
          .collection('comments')
          .where('parentCommentId', isEqualTo: commentId)
          .get();

      WriteBatch batch = _firestore.batch();
      for (QueryDocumentSnapshot reply in replies.docs) {
        batch.delete(reply.reference);
      }

      // Delete the comment itself
      batch.delete(commentRef);

      await batch.commit();

      // Update post comments count
      int deletedCount = replies.docs.length + 1;
      await _updatePostCommentsCount(postId, -deletedCount);

      // Update parent comment replies count
      if (comment.parentCommentId != null) {
        await _updateCommentRepliesCount(postId, comment.parentCommentId!, -1);
      }
    } catch (e) {
      throw 'فشل حذف التعليق: ${e.toString()}';
    }
  }

  // Like/Unlike comment
  // تبديل الإعجاب على التعليق أو الرد
Future<void> toggleCommentLike(
  String postId,
  String commentId,
  String userId,
) async {
  try {
    DocumentReference commentRef = _firestore
        .collection(postsCollection)
        .doc(postId)
        .collection('comments')
        .doc(commentId);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot commentDoc = await transaction.get(commentRef);

      if (commentDoc.exists) {
        Map<String, dynamic> data = commentDoc.data() as Map<String, dynamic>;
        List<String> likedBy = List<String>.from(data['likedBy'] ?? []);

        bool wasLiked = likedBy.contains(userId);
        
        if (wasLiked) {
          likedBy.remove(userId); // إزالة الإعجاب
        } else {
          likedBy.add(userId); // إضافة الإعجاب

          // إرسال إشعار فقط إذا لم يكن المستخدم يعجب بنفسه
          if (data['userId'] != userId) {
            await _notificationService.sendCommentLikeNotification(
              commentId: commentId,
              commentAuthorId: data['userId'],
              likerId: userId,
              // postId: postId,
            );
          }
        }

        transaction.update(commentRef, {
          'likedBy': likedBy,
          'updatedAt': DateTime.now(),
        });
      }
    });
  } catch (e) {
    throw 'فشل في الإعجاب بالتعليق: ${e.toString()}';
  }
}

  // Get comments stream for real-time updates
  Stream<List<CommentModel>> getPostCommentsStream(String postId) {
    return _firestore
        .collection(postsCollection)
        .doc(postId)
        .collection('comments')
        .where('parentCommentId', isNull: true)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommentModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Get comment replies stream
  Stream<List<CommentModel>> getCommentRepliesStream(
    String postId,
    String commentId,
  ) {
    return _firestore
        .collection(postsCollection)
        .doc(postId)
        .collection('comments')
        .where('parentCommentId', isEqualTo: commentId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommentModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Update post comments count
  Future<void> _updatePostCommentsCount(String postId, int increment) async {
    try {
      await _firestore.collection(postsCollection).doc(postId).update({
        'commentsCount': FieldValue.increment(increment),
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      print('خطأ في تحديث عداد التعليقات: $e');
    }
  }

  // Update comment replies count
  Future<void> _updateCommentRepliesCount(
    String postId,
    String commentId,
    int increment,
  ) async {
    try {
      await _firestore
          .collection(postsCollection)
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .update({
            'repliesCount': FieldValue.increment(increment),
            'updatedAt': DateTime.now(),
          });
    } catch (e) {
      print('خطأ في تحديث عداد الردود: $e');
    }
  }

  // Send comment notification
  Future<void> _sendCommentNotification(CommentModel comment) async {
    try {
      if (comment.parentCommentId != null) {
        // It's a reply
        DocumentSnapshot parentCommentDoc = await _firestore
            .collection(postsCollection)
            .doc(comment.postId)
            .collection('comments')
            .doc(comment.parentCommentId!)
            .get();

        if (parentCommentDoc.exists) {
          CommentModel parentComment = CommentModel.fromMap(
            parentCommentDoc.data() as Map<String, dynamic>,
            parentCommentDoc.id,
          );

          if (parentComment.userId != comment.userId) {
            await _notificationService.sendCommentReplyNotification(
              commentId: comment.parentCommentId!,
              commentAuthorId: parentComment.userId,
              replierId: comment.userId,
            );
          }
        }
      } else {
        // It's a main comment
        DocumentSnapshot postDoc = await _firestore
            .collection(postsCollection)
            .doc(comment.postId)
            .get();

        if (postDoc.exists) {
          PostModel post = PostModel.fromMap(
            postDoc.data() as Map<String, dynamic>,
            postDoc.id,
          );

          if (post.userId != comment.userId) {
            await _notificationService.sendPostCommentNotification(
              postId: comment.postId,
              postAuthorId: post.userId,
              commenterId: comment.userId,
            );

            // await _userService.updateUserPoints(post.userId, 1);
          }
        }
      }
    } catch (e) {
      print('خطأ في إرسال إشعار التعليق: $e');
    }
  }
}
