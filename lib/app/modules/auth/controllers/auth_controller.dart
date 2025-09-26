import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';
import '../../../services/storage_service.dart';
import '../../../models/user_model.dart';
import '../../../routes/app_routes.dart';
// import '../../gamification/controllers/gamification_controller.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final UserService _userService = UserService();
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();

  // استخدام RxString بدلاً من TextEditingController لتجنب مشاكل Disposal
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxString confirmPassword = ''.obs;
  final RxString firstName = ''.obs;
  final RxString lastName = ''.obs;
  final RxString phone = ''.obs;
  final RxString university = ''.obs;
  final RxString major = ''.obs;
  final RxString bio = ''.obs;

  // Form keys for each step
  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();
  final step1FormKey = GlobalKey<FormState>();
  final step2FormKey = GlobalKey<FormState>();
  final step3FormKey = GlobalKey<FormState>();

  // Observables
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxString selectedGender = ''.obs;
  final RxString selectedCountry = 'Tunis'.obs;
  final RxString selectedCity = 'BEJA'.obs;
  final RxString level = ''.obs;
  final Rx<DateTime?> selectedDateOfBirth = Rx<DateTime?>(null);
  final RxInt currentStep = 0.obs;
  final Rx<XFile?> profileImage = Rx<XFile?>(null);

  // قائمة الولايات التونسية باللاتينية بأحرف كبيرة
  final List<String> tunisianGovernorates = [
    'TUNIS',
    'ARIANA',
    'BEN AROUS',
    'MANOUBA',
    'NABEUL',
    'ZAGHOUAN',
    'BIZERTE',
    'BEJA',
    'JENDOUBA',
    'KEF',
    'SILIANA',
    'KAIROUAN',
    'KASSERINE',
    'SIDI BOUZID',
    'SOUSSE',
    'MONASTIR',
    'MAHDIA',
    'SFAX',
    'GAFSA',
    'TOZEUR',
    'KEBILI',
    'GABES',
    'MEDENINE',
    'TATAOUINE',
  ];

  // قائمة المستويات الأكاديمية
  final List<Map<String, String>> academicLevels = [
    // Licence
    {'value': '1 Licence', 'label': '1 Licence'},
    {'value': '2 Licence', 'label': '2 Licence'},
    {'value': '3 Licence', 'label': '3 Licence'},
    // Master
    {'value': '1 Master recherche', 'label': '1 Master recherche'},
    {'value': '2 Master recherche', 'label': '2 Master recherche'},
    {'value': '1 Master professionel', 'label': '1 Master professionel'},
    {'value': '2 Master professionel', 'label': '2 Master professionel'},
    // Ingenierie
    {'value': '1 Ingénierie', 'label': '1 Ingénierie'},
    {'value': '2 Ingénierie', 'label': '2 Ingénierie'},
    {'value': '3 Ingénierie', 'label': '3 Ingénierie'},
    // Doctorat
    {'value': '1 Doctorat', 'label': '1 Doctorat'},
    {'value': '2 Doctorat', 'label': '2 Doctorat'},
    {'value': '3 Doctorat', 'label': '3 Doctorat'},
  ];

  // Login method
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      UserCredential? result = await _authService.signInWithEmailAndPassword(
        email: email.value.trim(),
        password: password.value,
      );

      if (result != null) {
        // Check if user profile is complete
        bool isProfileComplete = await _checkProfileCompletion(
          result.user!.uid,
        );
        if (isProfileComplete) {
          Get.offNamed(AppRoutes.MAIN);
        } else {
          Get.offNamed(AppRoutes.USER_INFO);
        }
      }
    } catch (e) {
      Get.snackbar('خطأ', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // Register method
  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) return;

    if (password.value != confirmPassword.value) {
      Get.snackbar(
        'خطأ',
        'كلمات المرور غير متطابقة',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      UserCredential? result = await _authService.registerWithEmailAndPassword(
        email: email.value.trim(),
        password: password.value,
      );

      if (result != null) {
        Get.offNamed(AppRoutes.USER_INFO);
      }
    } catch (e) {
      Get.snackbar('خطأ', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // Google Sign In
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      UserCredential? result = await _authService.signInWithGoogle();

      if (result != null) {
        // Check if user profile is complete
        bool isProfileComplete = await _checkProfileCompletion(
          result.user!.uid,
        );
        if (isProfileComplete) {
          Get.offNamed(AppRoutes.MAIN);
        } else {
          Get.offNamed(AppRoutes.USER_INFO);
        }
      }
    } catch (e) {
      Get.snackbar('خطأ', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // Forgot Password
  Future<void> forgotPassword() async {
    if (email.value.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال البريد الإلكتروني',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      await _authService.resetPassword(email.value.trim());
      Get.snackbar(
        'تم الإرسال',
        'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.back();
    } catch (e) {
      Get.snackbar('خطأ', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      await clearProfileCompletionStatus();
      Get.offAllNamed(AppRoutes.LOGIN);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تسجيل الخروج');
    }
  }

  // Pick profile image
  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        profileImage.value = image;
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في اختيار الصورة',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Complete user profile
  Future<void> completeProfile() async {
    try {
      isLoading.value = true;

      // التحقق من صحة رقم الهاتف قبل المتابعة
      if (!phone.value.startsWith('+216') || phone.value.length != 12) {
        Get.snackbar(
          'خطأ',
          'رقم الهاتف غير صحيح',
          snackPosition: SnackPosition.BOTTOM,
        );
        isLoading.value = false;
        return;
      }

      String? userId = _authService.currentUserId;
      if (userId == null) throw 'المستخدم غير مسجل الدخول';

      String? photoUrl;

      // Upload profile image if selected
      if (profileImage.value != null) {
        try {
          File imageFile = File(profileImage.value!.path);

          if (await imageFile.exists()) {
            photoUrl = await _storageService.uploadProfileImage(
              userId,
              imageFile,
            );
          } else {
            Get.snackbar(
              'تنبيه',
              'لا يمكن رفع الصورة، سيتم حفظ الملف بدون صورة',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
          }
        } catch (e) {
          print('Error uploading image: $e');
          Get.snackbar(
            'تنبيه',
            'فشل في رفع الصورة، سيتم حفظ الملف بدون صورة',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      }

      UserModel profileData = UserModel(
        id: userId,
        email: _authService.currentUser!.email!,
        firstName: firstName.value.trim(),
        lastName: lastName.value.trim(),
        phone: formatPhoneNumber(phone.value.trim()),
        university: university.value.trim(),
        major: major.value.trim(),
        level: level.value,
        country: selectedCountry.value,
        city: selectedCity.value,
        bio: bio.value.trim(),
        gender: selectedGender.value,
        dateOfBirth: selectedDateOfBirth.value,
        photoURL: photoUrl,
        isProfileComplete: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to database
      await _userService.completeProfile(userId, profileData);

      // Important: Update AuthService user data immediately
      try {
        var updatedUser = await _userService.getUserData(userId);
        if (updatedUser != null) {
          _authService.appUser.value = updatedUser;
        }
      } catch (e) {
        print('Error updating AuthService user data: $e');
      }

      // Save profile completion status in SharedPreferences
      await _saveProfileCompletionStatus(true);

      // Award points for completing profile
      // try {
      //   final gamificationController = Get.find<GamificationController>();
      //   await gamificationController.awardPoints('complete_profile');
      // } catch (e) {
      //   print('Gamification controller not found: $e');
      // }

      // Show success message
      Get.snackbar(
        'تم بنجاح!',
        'تم إكمال ملفك الشخصي بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );

      // Clear the form
      clearUserInfoForm();

      // Navigate to main screen
      Get.offNamed(AppRoutes.MAIN);
    } catch (e) {
      print('Error completing profile: $e');
      Get.snackbar(
        'خطأ',
        'فشل في إكمال الملف الشخصي: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Check profile completion status
  Future<bool> _checkProfileCompletion(String userId) async {
    try {
      // First check SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? localStatus = prefs.getBool('profile_completed_$userId');

      if (localStatus == true) return true;

      // If not found locally, check from database
      UserModel? userData = await _userService.getUserData(userId);
      bool isComplete = userData?.isProfileComplete ?? false;

      // Save to SharedPreferences for future use
      if (isComplete) {
        await prefs.setBool('profile_completed_$userId', true);
      }

      return isComplete;
    } catch (e) {
      return false;
    }
  }

  // Save profile completion status to SharedPreferences
  Future<void> _saveProfileCompletionStatus(bool isComplete) async {
    try {
      String? userId = _authService.currentUserId;
      if (userId != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('profile_completed_$userId', isComplete);
      }
    } catch (e) {
      print('Error saving profile completion status: $e');
    }
  }

  // Clear profile completion status (for logout)
  Future<void> clearProfileCompletionStatus() async {
    try {
      String? userId = _authService.currentUserId;
      if (userId != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('profile_completed_$userId');
      }
    } catch (e) {
      print('Error clearing profile completion status: $e');
    }
  }

  // Select date of birth
  Future<void> selectDateOfBirth() async {
    DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate:
          selectedDateOfBirth.value ??
          DateTime.now().subtract(Duration(days: 6570)), // 18 years ago
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(
        Duration(days: 4380),
      ), // At least 12 years old
      helpText: 'اختر تاريخ ميلادك',
      cancelText: 'إلغاء',
      confirmText: 'موافق',
    );

    if (picked != null) {
      selectedDateOfBirth.value = picked;
    }
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  // Navigation methods for steps
  void nextStep() {
    if (currentStep.value < 2) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 2) {
      currentStep.value = step;
    }
  }

  // Reset step to beginning
  void resetSteps() {
    currentStep.value = 0;
  }

  // Clear form data
  void clearForm() {
    email.value = '';
    password.value = '';
    confirmPassword.value = '';
    firstName.value = '';
    lastName.value = '';
    phone.value = '';
    university.value = '';
    major.value = '';
    bio.value = '';
    selectedGender.value = '';
    selectedCountry.value = 'Tunis';
    level.value = '';
    selectedDateOfBirth.value = null;
    profileImage.value = null;
    resetSteps();
  }

  // Clear only user info form data
  void clearUserInfoForm() {
    firstName.value = '';
    lastName.value = '';
    phone.value = '';
    university.value = '';
    major.value = '';
    bio.value = '';
    selectedGender.value = '';
    selectedCountry.value = 'Tunis';
    selectedCity.value = 'BEJA';
    level.value = '';
    selectedDateOfBirth.value = null;
    profileImage.value = null;
    resetSteps();
  }

  // Update methods for reactive binding
  void updateEmail(String value) => email.value = value;
  void updatePassword(String value) => password.value = value;
  void updateConfirmPassword(String value) => confirmPassword.value = value;
  void updateFirstName(String value) => firstName.value = value;
  void updateLastName(String value) => lastName.value = value;
  void updatePhone(String value) => phone.value = value;
  void updateUniversity(String value) => university.value = value;
  void updateMajor(String value) => major.value = value;
  void updateBio(String value) => bio.value = value;

  // Validation methods
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }
    if (!GetUtils.isEmail(value)) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال $fieldName';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال رقم الهاتف';
    }

    // التأكد من أن القيمة تحتوي على +216 متبوعة بـ 8 أرقام
    if (!RegExp(r'^\+216\d{8}$').hasMatch(value)) {
      return 'رقم الهاتف يجب أن يبدأ بـ +216 ويتبعه 8 أرقام';
    }

    return null;
  }

  // Validate name fields
  String? validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال $fieldName';
    }

    if (value.trim().length < 2) {
      return '$fieldName يجب أن يكون حرفين على الأقل';
    }

    // Check if it contains only Arabic/English letters and spaces
    if (!RegExp(r'^[a-zA-Zا-ي\s]+$').hasMatch(value.trim())) {
      return '$fieldName يجب أن يحتوي على حروف فقط';
    }

    return null;
  }

  // دالة مساعدة لتنسيق رقم الهاتف
  String formatPhoneNumber(String phone) {
    // التأكد من أن رقم الهاتف يبدأ بـ +216 ويتبعه 8 أرقام
    if (phone.startsWith('+216') && phone.length == 12) {
      return phone;
    }

    // إذا كان الرقم يحتوي على 8 أرقام فقط، نضيف +216
    if (RegExp(r'^\d{8}$').hasMatch(phone)) {
      return '+216$phone';
    }

    // في حالة التنسيق غير المتوقع، نعيده كما هو
    return phone;
  }

  // دالة مساعدة لعرض رقم الهاتف بشكل منسق
  String displayPhoneNumber(String phone) {
    if (phone.startsWith('+216') && phone.length == 12) {
      // تنسيق الرقم: +216 12 345 678
      return '+216 ${phone.substring(4, 6)} ${phone.substring(6, 9)} ${phone.substring(9)}';
    }
    return phone;
  }

  // Get completion percentage for progress indicator
  int getCompletionPercentage() {
    int completedFields = 0;
    int totalRequiredFields = 10; // Total required fields across all steps

    // Step 1 fields (5 required)
    if (firstName.value.isNotEmpty) completedFields++;
    if (lastName.value.isNotEmpty) completedFields++;
    if (phone.value.isNotEmpty) completedFields++;
    if (selectedGender.value.isNotEmpty) completedFields++;
    if (selectedDateOfBirth.value != null) completedFields++;

    // Step 2 fields (4 required)
    if (selectedCountry.value.isNotEmpty) completedFields++;
    if (selectedCity.value.isNotEmpty) completedFields++;
    if (university.value.isNotEmpty) completedFields++;
    if (major.value.isNotEmpty) completedFields++;
    if (level.value.isNotEmpty) completedFields++;

    return ((completedFields / totalRequiredFields) * 100).round();
  }

  // Check if current step is valid
  bool isCurrentStepValid() {
    switch (currentStep.value) {
      case 0:
        return step1FormKey.currentState?.validate() ?? false;
      case 1:
        return step2FormKey.currentState?.validate() ?? false;
      case 2:
        return step3FormKey.currentState?.validate() ?? false;
      default:
        return false;
    }
  }

  // Get step title
  String getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'المعلومات الأساسية';
      case 1:
        return 'المعلومات الأكاديمية';
      case 2:
        return 'اللمسة الأخيرة';
      default:
        return '';
    }
  }

  // Get step description
  String getStepDescription(int step) {
    switch (step) {
      case 0:
        return 'ادخل معلوماتك الشخصية الأساسية';
      case 1:
        return 'ادخل معلوماتك الدراسية والأكاديمية';
      case 2:
        return 'أخبرنا المزيد عن نفسك لنقدم لك تجربة شخصية';
      default:
        return '';
    }
  }
}
