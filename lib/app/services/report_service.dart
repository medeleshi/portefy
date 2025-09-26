import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/post_report_model.dart';
import 'auth_service.dart';

class ReportService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();

  // دالة التحقق إذا كان المستخدم قد أبلغ عن المنشور مسبقاً
  Future<bool> hasUserReportedPost(String postId) async {
    final String userId = _authService.currentUserId!;
    
    final querySnapshot = await _firestore
        .collection('reports')
        .where('postId', isEqualTo: postId)
        .where('reporterId', isEqualTo: userId)
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  // دالة إرسال التبليغ
  Future<void> submitPostReport({
    required String postId,
    required ReportReason reason,
    String? description,
  }) async {
    final String userId = _authService.currentUserId!;
    final String reportId = _firestore.collection('reports').doc().id;

    final reportData = {
      'id': reportId,
      'postId': postId,
      'reporterId': userId,
      'reason': reason.toString().split('.').last, // تحويل الـ enum إلى string
      'description': description,
      'status': 'pending', // pending, reviewed, resolved
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    };

    await _firestore.collection('reports').doc(reportId).set(reportData);

    // تحديث عدد الإبلاغات على المنشور
    await _updatePostReportsCount(postId);
  }

  // دالة تحديث عدد الإبلاغات على المنشور
  Future<void> _updatePostReportsCount(String postId) async {
    final postRef = _firestore.collection('posts').doc(postId);
    
    await _firestore.runTransaction((transaction) async {
      final postDoc = await transaction.get(postRef);
      
      if (postDoc.exists) {
        int currentReports = postDoc.data()?['reportsCount'] ?? 0;
        transaction.update(postRef, {
          'reportsCount': currentReports + 1,
          'updatedAt': DateTime.now(),
        });
      }
    });
  }

  // دالة جلب جميع الإبلاغات (لـ Admin)
  Future<List<PostReportModel>> getPostReports({int limit = 50}) async {
    final querySnapshot = await _firestore
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return querySnapshot.docs.map((doc) {
      return PostReportModel.fromMap(doc.data());
    }).toList();
  }
}