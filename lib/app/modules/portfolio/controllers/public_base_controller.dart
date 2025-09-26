// lib/app/modules/portfolio/controllers/public_portfolio_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/portfolio_model.dart';
import '../../../models/user_model.dart';
import '../../../services/portfolio_service.dart';
import '../../../services/auth_service.dart';

// Base controller للملف الشخصي العام (للقراءة فقط)
abstract class PublicBaseController<T extends PortfolioItem> extends GetxController {
  final PortfolioService _portfolioService = PortfolioService();
  final String userId;
  
  final RxList<T> items = <T>[].obs;
  final RxBool isLoading = false.obs;
  
  PublicBaseController(this.userId);

  @override
  void onInit() {
    super.onInit();
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      isLoading.value = true;
      List<T> fetchedItems = await fetchItemsFromService(userId);
      items.assignAll(fetchedItems);
    } catch (e) {
      print('خطأ في تحميل العناصر: $e');
      // Silent error handling for public view
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshItems() async {
    await loadItems();
  }

  Future<List<T>> fetchItemsFromService(String userId);
}

// Controllers for public portfolio items
class PublicEducationController extends PublicBaseController<EducationModel> {
  PublicEducationController(String userId) : super(userId);

  @override
  Future<List<EducationModel>> fetchItemsFromService(String userId) async {
    return await _portfolioService.getEducation(userId);
  }
}

class PublicExperienceController extends PublicBaseController<ExperienceModel> {
  PublicExperienceController(String userId) : super(userId);

  @override
  Future<List<ExperienceModel>> fetchItemsFromService(String userId) async {
    return await _portfolioService.getExperience(userId);
  }
}

class PublicProjectsController extends PublicBaseController<ProjectModel> {
  PublicProjectsController(String userId) : super(userId);

  @override
  Future<List<ProjectModel>> fetchItemsFromService(String userId) async {
    return await _portfolioService.getProjects(userId);
  }
}

class PublicSkillsController extends PublicBaseController<SkillModel> {
  PublicSkillsController(String userId) : super(userId);

  @override
  Future<List<SkillModel>> fetchItemsFromService(String userId) async {
    return await _portfolioService.getSkills(userId);
  }
}

class PublicCertificatesController extends PublicBaseController<CertificateModel> {
  PublicCertificatesController(String userId) : super(userId);

  @override
  Future<List<CertificateModel>> fetchItemsFromService(String userId) async {
    return await _portfolioService.getCertificates(userId);
  }
}

// Main public portfolio controller
class PublicPortfolioController extends GetxController {
  final String userId;
  final AuthService _authService = Get.find<AuthService>();
  final FriendshipService _friendshipService = FriendshipService();
  final PortfolioService _portfolioService = PortfolioService();

  // Sub-controllers
  late PublicEducationController educationController;
  late PublicExperienceController experienceController;
  late PublicProjectsController projectsController;
  late PublicSkillsController skillsController;
  late PublicCertificatesController certificatesController;

  // Observable data
  final RxMap<String, int> stats = <String, int>{}.obs;
  final RxInt completionPercentage = 0.obs;
  final RxString connectionStatus = 'غير متصل'.obs;
  final RxBool isCurrentUserBlocked = false.obs;
  final RxBool hasUserBlockedCurrent = false.obs;

  PublicPortfolioController(this.userId);

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _loadPortfolioData();
    _checkConnectionStatus();
  }

  void _initializeControllers() {
    educationController = PublicEducationController(userId);
    experienceController = PublicExperienceController(userId);
    projectsController = PublicProjectsController(userId);
    skillsController = PublicSkillsController(userId);
    certificatesController = PublicCertificatesController(userId);
  }

  Future<void> _loadPortfolioData() async {
    await Future.wait([
      _loadStats(),
      _calculateCompletionPercentage(),
    ]);
  }

  Future<void> _loadStats() async {
    try {
      Map<String, int> portfolioStats = await _portfolioService.getPortfolioStats(userId);
      stats.assignAll(portfolioStats);
    } catch (e) {
      print('خطأ في تحميل الإحصائيات: $e');
      // Handle error silently
    }
  }

  Future<void> _calculateCompletionPercentage() async {
    try {
      int totalSections = 8; // عدد الأقسام في الملف الشخصي
      int completedSections = 0;
      
      if (stats['education'] != null && stats['education']! > 0) completedSections++;
      if (stats['experience'] != null && stats['experience']! > 0) completedSections++;
      if (stats['projects'] != null && stats['projects']! > 0) completedSections++;
      if (stats['skills'] != null && stats['skills']! > 0) completedSections++;
      if (stats['languages'] != null && stats['languages']! > 0) completedSections++;
      if (stats['certificates'] != null && stats['certificates']! > 0) completedSections++;
      if (stats['activities'] != null && stats['activities']! > 0) completedSections++;
      if (stats['hobbies'] != null && stats['hobbies']! > 0) completedSections++;
      
      completionPercentage.value = ((completedSections / totalSections) * 100).round();
    } catch (e) {
      completionPercentage.value = 0;
    }
  }

  Future<void> _checkConnectionStatus() async {
    String? currentUserId = _authService.currentUserId;
    if (currentUserId == null || currentUserId == userId) {
      connectionStatus.value = '';
      return;
    }

    try {
      FriendshipStatus status = await _friendshipService.getFriendshipStatus(currentUserId, userId);
      
      switch (status) {
        case FriendshipStatus.none:
          connectionStatus.value = 'غير متصل';
          break;
        case FriendshipStatus.requestSent:
          connectionStatus.value = 'طلب صداقة مرسل';
          break;
        case FriendshipStatus.requestReceived:
          connectionStatus.value = 'طلب صداقة مستقبل';
          break;
        case FriendshipStatus.friends:
          connectionStatus.value = 'صديق';
          break;
        case FriendshipStatus.blocked:
          connectionStatus.value = 'محظور';
          break;
      }
    } catch (e) {
      print('خطأ في فحص حالة الصداقة: $e');
      connectionStatus.value = 'غير متصل';
    }
  }

  // Friendship actions
  Future<void> sendFriendRequest() async {
    String? currentUserId = _authService.currentUserId;
    if (currentUserId == null) {
      Get.snackbar('خطأ', 'يجب تسجيل الدخول أولاً');
      return;
    }

    try {
      await _friendshipService.sendFriendRequest(currentUserId, userId);
      connectionStatus.value = 'طلب صداقة مرسل';
      Get.snackbar('تم', 'تم إرسال طلب الصداقة');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل إرسال طلب الصداقة');
    }
  }

  Future<void> acceptFriendRequest() async {
    String? currentUserId = _authService.currentUserId;
    if (currentUserId == null) return;

    try {
      await _friendshipService.acceptFriendRequest(userId, currentUserId);
      connectionStatus.value = 'صديق';
      Get.snackbar('تم', 'تم قبول طلب الصداقة');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل قبول طلب الصداقة');
    }
  }

  Future<void> rejectFriendRequest() async {
    String? currentUserId = _authService.currentUserId;
    if (currentUserId == null) return;

    try {
      await _friendshipService.rejectFriendRequest(userId, currentUserId);
      connectionStatus.value = 'غير متصل';
      Get.snackbar('تم', 'تم رفض طلب الصداقة');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل رفض طلب الصداقة');
    }
  }

  Future<void> blockUser() async {
    String? currentUserId = _authService.currentUserId;
    if (currentUserId == null) return;

    try {
      await _friendshipService.blockUser(currentUserId, userId);
      connectionStatus.value = 'محظور';
      Get.snackbar('تم', 'تم حظر المستخدم');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل حظر المستخدم');
    }
  }

  Future<void> unblockUser() async {
    String? currentUserId = _authService.currentUserId;
    if (currentUserId == null) return;

    try {
      await _friendshipService.unblockUser(currentUserId, userId);
      connectionStatus.value = 'غير متصل';
      Get.snackbar('تم', 'تم إلغاء حظر المستخدم');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل إلغاء حظر المستخدم');
    }
  }

  @override
  void onClose() {
    educationController.dispose();
    experienceController.dispose();
    projectsController.dispose();
    skillsController.dispose();
    certificatesController.dispose();
    super.onClose();
  }
}

// Friendship service
class FriendshipService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<FriendshipStatus> getFriendshipStatus(String userId1, String userId2) async {
    try {
      // Check if blocked
      QuerySnapshot blockedQuery = await _firestore
          .collection('blocks')
          .where('blockerId', isEqualTo: userId1)
          .where('blockedId', isEqualTo: userId2)
          .get();
      
      if (blockedQuery.docs.isNotEmpty) {
        return FriendshipStatus.blocked;
      }

      // Check friendship status
      QuerySnapshot friendshipQuery = await _firestore
          .collection('friendships')
          .where('users', arrayContains: userId1)
          .get();

      for (var doc in friendshipQuery.docs) {
        List<String> users = List<String>.from(doc['users']);
        if (users.contains(userId2)) {
          String status = doc['status'];
          String requesterId = doc['requesterId'];
          
          switch (status) {
            case 'pending':
              return requesterId == userId1 
                  ? FriendshipStatus.requestSent 
                  : FriendshipStatus.requestReceived;
            case 'accepted':
              return FriendshipStatus.friends;
            case 'rejected':
              return FriendshipStatus.none;
          }
        }
      }

      return FriendshipStatus.none;
    } catch (e) {
      print('خطأ في getFriendshipStatus: $e');
      return FriendshipStatus.none;
    }
  }

  Future<void> sendFriendRequest(String fromUserId, String toUserId) async {
    try {
      // Check if request already exists
      QuerySnapshot existingRequest = await _firestore
          .collection('friendships')
          .where('users', arrayContains: fromUserId)
          .get();

      for (var doc in existingRequest.docs) {
        List<String> users = List<String>.from(doc['users']);
        if (users.contains(toUserId)) {
          throw 'طلب الصداقة موجود بالفعل';
        }
      }

      await _firestore.collection('friendships').add({
        'users': [fromUserId, toUserId],
        'requesterId': fromUserId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Send notification to the other user
      await _sendFriendRequestNotification(fromUserId, toUserId);
      
    } catch (e) {
      throw 'فشل إرسال طلب الصداقة: ${e.toString()}';
    }
  }

  Future<void> acceptFriendRequest(String fromUserId, String toUserId) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('friendships')
          .where('users', arrayContains: fromUserId)
          .where('status', isEqualTo: 'pending')
          .get();

      for (var doc in query.docs) {
        List<String> users = List<String>.from(doc['users']);
        if (users.contains(toUserId)) {
          await doc.reference.update({
            'status': 'accepted',
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // Send notification
          await _sendFriendAcceptedNotification(fromUserId, toUserId);
          break;
        }
      }
    } catch (e) {
      throw 'فشل قبول طلب الصداقة: ${e.toString()}';
    }
  }

  Future<void> rejectFriendRequest(String fromUserId, String toUserId) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('friendships')
          .where('users', arrayContains: fromUserId)
          .where('status', isEqualTo: 'pending')
          .get();

      for (var doc in query.docs) {
        List<String> users = List<String>.from(doc['users']);
        if (users.contains(toUserId)) {
          await doc.reference.delete();
          break;
        }
      }
    } catch (e) {
      throw 'فشل رفض طلب الصداقة: ${e.toString()}';
    }
  }

  Future<void> blockUser(String blockerId, String blockedId) async {
    try {
      // Check if already blocked
      QuerySnapshot existingBlock = await _firestore
          .collection('blocks')
          .where('blockerId', isEqualTo: blockerId)
          .where('blockedId', isEqualTo: blockedId)
          .get();

      if (existingBlock.docs.isNotEmpty) {
        throw 'المستخدم محظور بالفعل';
      }

      // Add to blocks collection
      await _firestore.collection('blocks').add({
        'blockerId': blockerId,
        'blockedId': blockedId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Remove friendship if exists
      QuerySnapshot friendshipQuery = await _firestore
          .collection('friendships')
          .where('users', arrayContains: blockerId)
          .get();

      for (var doc in friendshipQuery.docs) {
        List<String> users = List<String>.from(doc['users']);
        if (users.contains(blockedId)) {
          await doc.reference.delete();
          break;
        }
      }
    } catch (e) {
      throw 'فشل حظر المستخدم: ${e.toString()}';
    }
  }

  Future<void> unblockUser(String blockerId, String blockedId) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('blocks')
          .where('blockerId', isEqualTo: blockerId)
          .where('blockedId', isEqualTo: blockedId)
          .get();

      for (var doc in query.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw 'فشل إلغاء حظر المستخدم: ${e.toString()}';
    }
  }

  Future<List<UserModel>> getFriends(String userId) async {
    try {
      QuerySnapshot friendshipQuery = await _firestore
          .collection('friendships')
          .where('users', arrayContains: userId)
          .where('status', isEqualTo: 'accepted')
          .get();

      List<String> friendIds = [];
      for (var doc in friendshipQuery.docs) {
        List<String> users = List<String>.from(doc['users']);
        String friendId = users.firstWhere((id) => id != userId);
        friendIds.add(friendId);
      }

      if (friendIds.isEmpty) return [];

      // Get friends data (in batches of 10 due to Firestore limitations)
      List<UserModel> friends = [];
      for (int i = 0; i < friendIds.length; i += 10) {
        List<String> batch = friendIds.skip(i).take(10).toList();
        QuerySnapshot usersSnapshot = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        friends.addAll(usersSnapshot.docs.map((doc) => 
            UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)));
      }

      return friends;
    } catch (e) {
      print('خطأ في getFriends: $e');
      return [];
    }
  }

  Future<List<UserModel>> getPendingFriendRequests(String userId) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('friendships')
          .where('users', arrayContains: userId)
          .where('status', isEqualTo: 'pending')
          .get();

      List<String> requesterIds = [];
      for (var doc in query.docs) {
        String requesterId = doc['requesterId'];
        if (requesterId != userId) {
          requesterIds.add(requesterId);
        }
      }

      if (requesterIds.isEmpty) return [];

      List<UserModel> requesters = [];
      for (int i = 0; i < requesterIds.length; i += 10) {
        List<String> batch = requesterIds.skip(i).take(10).toList();
        QuerySnapshot usersSnapshot = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        requesters.addAll(usersSnapshot.docs.map((doc) => 
            UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)));
      }

      return requesters;
    } catch (e) {
      print('خطأ في getPendingFriendRequests: $e');
      return [];
    }
  }

  // Helper methods for notifications
  Future<void> _sendFriendRequestNotification(String fromUserId, String toUserId) async {
    try {
      await _firestore.collection('notifications').add({
        'type': 'friend_request',
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('خطأ في إرسال إشعار طلب الصداقة: $e');
    }
  }

  Future<void> _sendFriendAcceptedNotification(String fromUserId, String toUserId) async {
    try {
      await _firestore.collection('notifications').add({
        'type': 'friend_accepted',
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('خطأ في إرسال إشعار قبول الصداقة: $e');
    }
  }
}

// Friendship status enum
enum FriendshipStatus {
  none,
  requestSent,
  requestReceived,
  friends,
  blocked,
}