import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'user_service.dart';

class AuthService extends GetxService {
  static AuthService get instance => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserService _userService = UserService();

  // Observable user
  Rx<User?> firebaseUser = Rx<User?>(null);
  Rx<UserModel?> appUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    // Bind the firebase user to the observable
    firebaseUser.bindStream(_auth.authStateChanges());
    
    // Listen to auth state changes
    ever(firebaseUser, _setInitialScreen);
  }

  // Determine initial screen based on auth state
  void _setInitialScreen(User? user) async {
    if (user != null) {
      // User is signed in, check if profile is complete
      final userData = await _userService.getUserData(user.uid);
      if (userData != null) {
        appUser.value = userData;
      }
    } else {
      appUser.value = null;
    }
  }

  // Register with email and password
  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user document in Firestore
      if (result.user != null) {
        await _createUserDocument(result.user!);
      }
      
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      
      // Create user document if new user
      if (result.additionalUserInfo?.isNewUser == true && result.user != null) {
        await _createUserDocument(result.user!);
      }
      
      return result;
    } catch (e) {
      throw 'فشل تسجيل الدخول بـ Google: ${e.toString()}';
    }
  }

  // // Sign in with Facebook
  // Future<UserCredential?> signInWithFacebook() async {
  //   try {
  //     final LoginResult result = await FacebookAuth.instance.login();
      
  //     if (result.status == LoginStatus.success) {
  //       final AccessToken accessToken = result.accessToken!;
  //       final OAuthCredential credential = FacebookAuthProvider.credential(accessToken.tokenString);
        
  //       UserCredential userCredential = await _auth.signInWithCredential(credential);
        
  //       // Create user document if new user
  //       if (userCredential.additionalUserInfo?.isNewUser == true && userCredential.user != null) {
  //         await _createUserDocument(userCredential.user!);
  //       }
        
  //       return userCredential;
  //     }
  //     return null;
  //   } catch (e) {
  //     throw 'فشل تسجيل الدخول بـ Facebook: ${e.toString()}';
  //   }
  // }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// تحقق مما إذا كان ملف المستخدم الحالي مكتملاً مع عدة خيارات احتياطية
Future<bool> isProfileCompleteReliable() async {
  try {
    if (!isSignedIn || currentUserId == null) return false;

    // الطريقة 1: تحقق من SharedPreferences أولاً
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? localStatus = prefs.getBool('profile_completed_$currentUserId');
    
    if (localStatus == true) return true;

    // الطريقة 2: تحقق من بيانات المستخدم المخزنة مؤقتاً
    if (appUser.value != null) {
      bool isComplete = appUser.value!.isProfileComplete ?? false;
      if (isComplete) {
        // تحديث SharedPreferences
        await prefs.setBool('profile_completed_$currentUserId', true);
        return true;
      }
    }

    // الطريقة 3: جلب من قاعدة البيانات
    UserModel? userData = await UserService().getUserData(currentUserId!);
    if (userData != null) {
      bool isComplete = userData.isProfileComplete ?? false;
      await prefs.setBool('profile_completed_$currentUserId', isComplete);
      appUser.value = userData;
      return isComplete;
    }

    return false;
  } catch (e) {
    print('خطأ في التحقق من اكتمال الملف الشخصي: $e');
    return false;
  }
}

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      // await FacebookAuth.instance.logOut();
      await _auth.signOut();
      appUser.value = null;
    } catch (e) {
      throw 'فشل تسجيل الخروج: ${e.toString()}';
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user) async {
    final userData = UserModel(
      id: user.uid,
      email: user.email!,
      displayName: user.displayName,
      photoURL: user.photoURL,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isProfileComplete: false,
    );
    
    await _userService.createUser(userData);
  }

  // Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      if (_auth.currentUser != null) {
        await _auth.currentUser!.updateDisplayName(displayName);
        await _auth.currentUser!.updatePhotoURL(photoURL);
      }
    } catch (e) {
      throw 'فشل تحديث الملف الشخصي: ${e.toString()}';
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'لا يوجد حساب بهذا البريد الإلكتروني';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      case 'too-many-requests':
        return 'تم إرسال طلبات كثيرة. حاول مرة أخرى لاحقاً';
      case 'operation-not-allowed':
        return 'هذه العملية غير مسموحة';
      default:
        return 'حدث خطأ: ${e.message}';
    }
  }

  // Add this method to your AuthService class

/// Force refresh user data from database
Future<void> refreshUserData() async {
  try {
    if (currentUserId != null) {
      UserModel? userData = await UserService().getUserData(currentUserId!);
      if (userData != null) {
        appUser.value = userData;
        
        // Update SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('profile_completed_$currentUserId', userData.isProfileComplete ?? false);
        
        print('User data refreshed: ${userData.isProfileComplete}');
      }
    }
  } catch (e) {
    print('Error refreshing user data: $e');
  }
}

  // Getters
  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;
  String? get currentUserId => _auth.currentUser?.uid;
}