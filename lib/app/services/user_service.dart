import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collections
  String get usersCollection => 'users';

  // Create user
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection(usersCollection).doc(user.id).set(user.toMap());
    } catch (e) {
      throw 'فشل إنشاء المستخدم: ${e.toString()}';
    }
  }

  // Get user data
  Future<UserModel?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(usersCollection).doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw 'فشل جلب بيانات المستخدم: ${e.toString()}';
    }
  }

  // Update user data
  Future<void> updateUser(String userId, UserModel data) async {
    try {
      await _firestore.collection(usersCollection).doc(userId).update(data.toMap());
    } catch (e) {
      throw 'فشل تحديث المستخدم: ${e.toString()}';
    }
  }

  // Update user profile completion
  Future<void> completeProfile(String userId, UserModel profileData) async {
    try {
      await _firestore.collection(usersCollection).doc(userId).set(profileData.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw 'فشل إكمال الملف الشخصي: ${e.toString()}';
    }
  }

  // Update user points
  // Future<void> updateUserPoints(String userId, int points) async {
  //   try {
  //     await _firestore.collection(usersCollection).doc(userId).update({
  //       'points': FieldValue.increment(points),
  //       'updatedAt': DateTime.now(),
  //     });
  //   } catch (e) {
  //     throw 'فشل تحديث النقاط: ${e.toString()}';
  //   }
  // }

  // Get users by university
  Future<List<UserModel>> getUsersByUniversity(String university, {int limit = 10}) async {
    try {
      QuerySnapshot query = await _firestore
          .collection(usersCollection)
          .where('university', isEqualTo: university)
          .where('isProfileComplete', isEqualTo: true)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'فشل جلب المستخدمين: ${e.toString()}';
    }
  }

  // Get users by major
  Future<List<UserModel>> getUsersByMajor(String university, String major, {int limit = 10}) async {
    try {
      QuerySnapshot query = await _firestore
          .collection(usersCollection)
          .where('university', isEqualTo: university)
          .where('major', isEqualTo: major)
          .where('isProfileComplete', isEqualTo: true)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'فشل جلب المستخدمين: ${e.toString()}';
    }
  }
  // Get users by major
  Future<List<UserModel>> getUsersByLevel(String university, String major, String level, {int limit = 10}) async {
    try {
      QuerySnapshot query = await _firestore
          .collection(usersCollection)
          .where('university', isEqualTo: university)
          .where('major', isEqualTo: major)
          .where('level', isEqualTo: level)
          .where('isProfileComplete', isEqualTo: true)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'فشل جلب المستخدمين: ${e.toString()}';
    }
  }

  // Search users
  Future<List<UserModel>> searchUsers(String query, {int limit = 10}) async {
    try {
      // Search by name (this is a basic implementation, you might want to use Algolia for better search)
      QuerySnapshot nameQuery = await _firestore
          .collection(usersCollection)
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThan: query + 'z')
          .where('isProfileComplete', isEqualTo: true)
          .limit(limit)
          .get();

      return nameQuery.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw 'فشل البحث عن المستخدمين: ${e.toString()}';
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection(usersCollection).doc(userId).delete();
    } catch (e) {
      throw 'فشل حذف المستخدم: ${e.toString()}';
    }
  }

  // Get user stream for real-time updates
  Stream<UserModel?> getUserStream(String userId) {
    return _firestore.collection(usersCollection).doc(userId).snapshots().map(
      (doc) {
        if (doc.exists) {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }
        return null;
      },
    );
  }
}