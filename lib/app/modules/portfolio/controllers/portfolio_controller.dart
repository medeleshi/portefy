import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../../models/portfolio_model.dart';
import '../../../models/user_model.dart';
import '../../../services/portfolio_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';

class PortfolioController extends GetxController {
  final PortfolioService _portfolioService = PortfolioService();
  final AuthService _authService = Get.find<AuthService>();
  final StorageService _storageService = StorageService();

  // Form controllers
  final institutionController = TextEditingController();
  final degreeController = TextEditingController();
  final fieldOfStudyController = TextEditingController();
  final companyController = TextEditingController();
  final positionController = TextEditingController();
  final locationController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final skillNameController = TextEditingController();
  final languageNameController = TextEditingController();
  final gpaController = TextEditingController();
  final certificateNameController = TextEditingController();
  final issuerController = TextEditingController();
  final credentialIdController = TextEditingController();
  final credentialUrlController = TextEditingController();
  final activityTitleController = TextEditingController();
  final organizationController = TextEditingController();
  final roleController = TextEditingController();
  final hobbyNameController = TextEditingController();
  final hobbyDescriptionController = TextEditingController();

  // إضافة المتغيرات الجديدة
  final Rx<DateTime?> issueDate = Rx<DateTime?>(null);
  final Rx<DateTime?> expiryDate = Rx<DateTime?>(null);
  final Rx<DateTime?> hobbyStartDate = Rx<DateTime?>(null);
  final RxString selectedActivityType = 'تطوعي'.obs;
  final RxString selectedHobbyCategory = 'أخرى'.obs;
  final RxInt hobbyProficiency = 1.obs;

  // Add to your list of templates
  final List<String> cvTemplates = [
    'Template 1',
    'Template 2',
    'Template 3',
    'Template 4',
  ];

  // إضافة القوائم الجديدة
  final List<String> activityTypes = [
    'تطوعي',
    'نادي',
    'رياضي',
    'خدمة مجتمع',
    'آخر',
  ];
  final List<String> hobbyCategories = [
    'رياضة',
    'فنون',
    'موسيقى',
    'قراءة',
    'سفر',
    'أخرى',
  ];

  // Observables
  final RxBool isLoading = false.obs;
  final RxString selectedCategory = 'معلومات شخصية'.obs;
  final RxString selectedTemplate = 'Template 1'.obs;

  // Portfolio data
  final RxList<EducationModel> education = <EducationModel>[].obs;
  final RxList<ExperienceModel> experience = <ExperienceModel>[].obs;
  final RxList<ProjectModel> projects = <ProjectModel>[].obs;
  final RxList<SkillModel> skills = <SkillModel>[].obs;
  final RxList<LanguageModel> languages = <LanguageModel>[].obs;
  final RxList<ActivityModel> activities = <ActivityModel>[].obs;
  final RxList<CertificateModel> certificates = <CertificateModel>[].obs;
  final RxList<HobbyModel> hobbies = <HobbyModel>[].obs;

  // Form observables
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final RxBool isCurrent = false.obs;
  final RxString selectedSkillCategory = 'تقنية'.obs;
  final RxInt skillLevel = 1.obs;
  final RxString selectedProficiency = 'مبتدئ'.obs;
  final RxBool isCompleted = false.obs;

  // Categories
  final List<String> categories = [
    'معلومات شخصية',
    'التعليم',
    'الخبرات',
    'المشاريع',
    'المهارات',
    'اللغات',
    'الأنشطة',
    'الشهادات',
    'الهوايات',
  ];

  final List<String> skillCategories = ['تقنية', 'ناعمة', 'أكاديمية'];
  final List<String> proficiencyLevels = [
    'مبتدئ',
    'متوسط',
    'متقدم',
    'خبير',
    'أصلي',
  ];

  @override
  void onInit() {
    super.onInit();
    loadPortfolioData();
  }

  // Load portfolio data
  Future<void> loadPortfolioData() async {
    try {
      isLoading.value = true;
      String? userId = _authService.currentUserId;
      if (userId == null) return;

      // Load all portfolio data
      education.assignAll(await _portfolioService.getEducation(userId));
      experience.assignAll(await _portfolioService.getExperience(userId));
      projects.assignAll(await _portfolioService.getProjects(userId));
      skills.assignAll(await _portfolioService.getSkills(userId));
      languages.assignAll(await _portfolioService.getLanguages(userId));
      certificates.assignAll(await _portfolioService.getCertificates(userId));
      activities.assignAll(await _portfolioService.getActivities(userId));
      hobbies.assignAll(await _portfolioService.getHobbies(userId));
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحميل بيانات الملف الشخصي');
    } finally {
      isLoading.value = false;
    }
  }

  // Education methods
  // في دوال الإضافة، تأكد من تمرير جميع الحقول المطلوبة
  Future<void> addEducation() async {
    if (!_validateEducationForm()) return;

    try {
      isLoading.value = true;
      String? userId = _authService.currentUserId;
      if (userId == null) throw 'المستخدم غير مسجل الدخول';

      EducationModel educationItem = EducationModel(
        id: '', // سيتم إنشاء ID تلقائياً من Firebase
        userId: userId,
        institution: institutionController.text.trim(),
        degree: degreeController.text.trim(),
        fieldOfStudy: fieldOfStudyController.text.trim(),
        startDate: startDate.value!,
        endDate: isCurrent.value ? null : endDate.value,
        isCurrent: isCurrent.value,
        gpa: gpaController.text.isNotEmpty
            ? double.parse(gpaController.text)
            : null,
        description: descriptionController.text.trim().isNotEmpty
            ? descriptionController.text.trim()
            : null,
        achievements: null, // يمكنك إضافة حقل للإنجازات لاحقاً
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _portfolioService.addEducation(educationItem);
      education.add(educationItem);

      Get.back();
      Get.snackbar('نجح', 'تم إضافة التعليم بنجاح');
      _clearEducationForm();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل إضافة التعليم: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Experience methods
  Future<void> addExperience() async {
    if (!_validateExperienceForm()) return;

    try {
      isLoading.value = true;
      String? userId = _authService.currentUserId;
      if (userId == null) throw 'المستخدم غير مسجل الدخول';

      ExperienceModel experienceItem = ExperienceModel(
        id: '',
        userId: userId,
        company: companyController.text.trim(),
        position: positionController.text.trim(),
        location: locationController.text.trim().isNotEmpty
            ? locationController.text.trim()
            : null,
        startDate: startDate.value!,
        endDate: isCurrent.value ? null : endDate.value,
        isCurrent: isCurrent.value,
        description: descriptionController.text.trim().isNotEmpty
            ? descriptionController.text.trim()
            : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _portfolioService.addExperience(experienceItem);
      experience.add(experienceItem);

      Get.back();
      Get.snackbar('نجح', 'تم إضافة الخبرة بنجاح');
      _clearExperienceForm();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل إضافة الخبرة: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Project methods
  Future<void> addProject() async {
    if (!_validateProjectForm()) return;

    try {
      isLoading.value = true;
      String? userId = _authService.currentUserId;
      if (userId == null) throw 'المستخدم غير مسجل الدخول';

      ProjectModel project = ProjectModel(
        id: '',
        userId: userId,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        startDate: startDate.value,
        endDate: endDate.value,
        isCompleted: isCompleted.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _portfolioService.addProject(project);
      projects.add(project);

      Get.back();
      Get.snackbar('نجح', 'تم إضافة المشروع بنجاح');
      _clearProjectForm();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل إضافة المشروع: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Skill methods
  Future<void> addSkill() async {
    if (!_validateSkillForm()) return;

    try {
      isLoading.value = true;
      String? userId = _authService.currentUserId;
      if (userId == null) throw 'المستخدم غير مسجل الدخول';

      SkillModel skill = SkillModel(
        id: '',
        userId: userId,
        name: skillNameController.text.trim(),
        category: selectedSkillCategory.value,
        level: skillLevel.value,
        description: descriptionController.text.trim().isNotEmpty
            ? descriptionController.text.trim()
            : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _portfolioService.addSkill(skill);
      skills.add(skill);

      Get.back();
      Get.snackbar('نجح', 'تم إضافة المهارة بنجاح');
      _clearSkillForm();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل إضافة المهارة: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Language methods
  Future<void> addLanguage() async {
    if (!_validateLanguageForm()) return;

    try {
      isLoading.value = true;
      String? userId = _authService.currentUserId;
      if (userId == null) throw 'المستخدم غير مسجل الدخول';

      LanguageModel language = LanguageModel(
        id: '',
        userId: userId,
        name: languageNameController.text.trim(),
        proficiency: selectedProficiency.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _portfolioService.addLanguage(language);
      languages.add(language);

      Get.back();
      Get.snackbar('نجح', 'تم إضافة اللغة بنجاح');
      _clearLanguageForm();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل إضافة اللغة: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete methods
  Future<void> deleteEducation(String id, int index) async {
    try {
      await _portfolioService.deleteEducation(id);
      education.removeAt(index);
      Get.snackbar('تم', 'تم حذف التعليم');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل حذف التعليم');
    }
  }

  Future<void> deleteExperience(String id, int index) async {
    try {
      await _portfolioService.deleteExperience(id);
      experience.removeAt(index);
      Get.snackbar('تم', 'تم حذف الخبرة');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل حذف الخبرة');
    }
  }

  Future<void> deleteProject(String id, int index) async {
    try {
      await _portfolioService.deleteProject(id);
      projects.removeAt(index);
      Get.snackbar('تم', 'تم حذف المشروع');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل حذف المشروع');
    }
  }

  Future<void> deleteSkill(String id, int index) async {
    try {
      await _portfolioService.deleteSkill(id);
      skills.removeAt(index);
      Get.snackbar('تم', 'تم حذف المهارة');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل حذف المهارة');
    }
  }

  Future<void> deleteLanguage(String id, int index) async {
    try {
      await _portfolioService.deleteLanguage(id);
      languages.removeAt(index);
      Get.snackbar('تم', 'تم حذف اللغة');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل حذف اللغة');
    }
  }

  // إضافة دوال الحذف للأنواع الجديدة
  Future<void> deleteCertificate(String id, int index) async {
    try {
      await _portfolioService.deleteCertificate(id);
      certificates.removeAt(index);
      Get.snackbar('تم', 'تم حذف الشهادة');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل حذف الشهادة');
    }
  }

  Future<void> deleteActivity(String id, int index) async {
    try {
      await _portfolioService.deleteActivity(id);
      activities.removeAt(index);
      Get.snackbar('تم', 'تم حذف النشاط');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل حذف النشاط');
    }
  }

  Future<void> deleteHobby(String id, int index) async {
    try {
      await _portfolioService.deleteHobby(id);
      hobbies.removeAt(index);
      Get.snackbar('تم', 'تم حذف الهواية');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل حذف الهواية');
    }
  }

  // إضافة دوال اختيار التاريخ الجديدة
  Future<void> selectIssueDate() async {
    DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: issueDate.value ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      issueDate.value = picked;
    }
  }

  Future<void> selectExpiryDate() async {
    DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: expiryDate.value ?? DateTime.now(),
      firstDate: issueDate.value ?? DateTime(1950),
      lastDate: DateTime(2050),
    );

    if (picked != null) {
      expiryDate.value = picked;
    }
  }

  Future<void> selectHobbyStartDate() async {
    DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: hobbyStartDate.value ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      hobbyStartDate.value = picked;
    }
  }

  // إضافة دوال الإرسال الجديدة
  Future<void> addCertificate() async {
    if (!_validateCertificateForm()) return;

    try {
      isLoading.value = true;
      String? userId = _authService.currentUserId;
      if (userId == null) throw 'المستخدم غير مسجل الدخول';

      CertificateModel certificate = CertificateModel(
        id: '',
        userId: userId,
        name: certificateNameController.text.trim(),
        issuer: issuerController.text.trim(),
        issueDate: issueDate.value!,
        expiryDate: expiryDate.value,
        credentialId: credentialIdController.text.trim().isNotEmpty
            ? credentialIdController.text.trim()
            : null,
        credentialUrl: credentialUrlController.text.trim().isNotEmpty
            ? credentialUrlController.text.trim()
            : null,
        description: descriptionController.text.trim().isNotEmpty
            ? descriptionController.text.trim()
            : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _portfolioService.addCertificate(certificate);
      certificates.add(certificate);

      Get.back();
      Get.snackbar('نجح', 'تم إضافة الشهادة بنجاح');
      _clearCertificateForm();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل إضافة الشهادة: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addActivity() async {
    if (!_validateActivityForm()) return;

    try {
      isLoading.value = true;
      String? userId = _authService.currentUserId;
      if (userId == null) throw 'المستخدم غير مسجل الدخول';

      ActivityModel activity = ActivityModel(
        id: '',
        userId: userId,
        title: activityTitleController.text.trim(),
        organization: organizationController.text.trim(),
        type: selectedActivityType.value,
        role: roleController.text.trim().isNotEmpty
            ? roleController.text.trim()
            : null,
        startDate: startDate.value!,
        endDate: isCurrent.value ? null : endDate.value,
        isCurrent: isCurrent.value,
        description: descriptionController.text.trim().isNotEmpty
            ? descriptionController.text.trim()
            : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _portfolioService.addActivity(activity);
      activities.add(activity);

      Get.back();
      Get.snackbar('نجح', 'تم إضافة النشاط بنجاح');
      _clearActivityForm();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل إضافة النشاط: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addHobby() async {
    if (!_validateHobbyForm()) return;

    try {
      isLoading.value = true;
      String? userId = _authService.currentUserId;
      if (userId == null) throw 'المستخدم غير مسجل الدخول';

      HobbyModel hobby = HobbyModel(
        id: '',
        userId: userId,
        name: hobbyNameController.text.trim(),
        description: hobbyDescriptionController.text.trim().isNotEmpty
            ? hobbyDescriptionController.text.trim()
            : null,
        category: selectedHobbyCategory.value,
        proficiency: hobbyProficiency.value,
        startedDate: hobbyStartDate.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _portfolioService.addHobby(hobby);
      hobbies.add(hobby);

      Get.back();
      Get.snackbar('نجح', 'تم إضافة الهواية بنجاح');
      _clearHobbyForm();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل إضافة الهواية: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // إضافة دوال التحقق من الصحة الجديدة
  bool _validateCertificateForm() {
    if (certificateNameController.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال اسم الشهادة');
      return false;
    }
    if (issuerController.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال اسم الجهة المانحة');
      return false;
    }
    if (issueDate.value == null) {
      Get.snackbar('خطأ', 'يرجى اختيار تاريخ الإصدار');
      return false;
    }
    return true;
  }

  bool _validateActivityForm() {
    if (activityTitleController.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال عنوان النشاط');
      return false;
    }
    if (organizationController.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال اسم المنظمة');
      return false;
    }
    if (startDate.value == null) {
      Get.snackbar('خطأ', 'يرجى اختيار تاريخ البداية');
      return false;
    }
    return true;
  }

  bool _validateHobbyForm() {
    if (hobbyNameController.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال اسم الهواية');
      return false;
    }
    return true;
  }

  // إضافة دوال مسح النماذج الجديدة
  void _clearCertificateForm() {
    certificateNameController.clear();
    issuerController.clear();
    credentialIdController.clear();
    credentialUrlController.clear();
    descriptionController.clear();
    issueDate.value = null;
    expiryDate.value = null;
  }

  void _clearActivityForm() {
    activityTitleController.clear();
    organizationController.clear();
    roleController.clear();
    descriptionController.clear();
    startDate.value = null;
    endDate.value = null;
    isCurrent.value = false;
    selectedActivityType.value = 'تطوعي';
  }

  void _clearHobbyForm() {
    hobbyNameController.clear();
    hobbyDescriptionController.clear();
    selectedHobbyCategory.value = 'أخرى';
    hobbyProficiency.value = 1;
    hobbyStartDate.value = null;
  }

  // Date picker methods
  Future<void> selectStartDate() async {
    DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: startDate.value ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      startDate.value = picked;
    }
  }

  Future<void> selectEndDate() async {
    DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: endDate.value ?? DateTime.now(),
      firstDate: startDate.value ?? DateTime(1950),
      lastDate: DateTime(2050),
    );

    if (picked != null) {
      endDate.value = picked;
    }
  }

  // Validation methods
  bool _validateEducationForm() {
    if (institutionController.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال اسم المؤسسة التعليمية');
      return false;
    }
    if (degreeController.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال الدرجة العلمية');
      return false;
    }
    if (fieldOfStudyController.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال التخصص');
      return false;
    }
    if (startDate.value == null) {
      Get.snackbar('خطأ', 'يرجى اختيار تاريخ البداية');
      return false;
    }
    return true;
  }

  bool _validateExperienceForm() {
    if (companyController.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال اسم الشركة');
      return false;
    }
    if (positionController.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال المنصب');
      return false;
    }
    if (startDate.value == null) {
      Get.snackbar('خطأ', 'يرجى اختيار تاريخ البداية');
      return false;
    }
    return true;
  }

  bool _validateProjectForm() {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال عنوان المشروع');
      return false;
    }
    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال وصف المشروع');
      return false;
    }
    return true;
  }

  bool _validateSkillForm() {
    if (skillNameController.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال اسم المهارة');
      return false;
    }
    return true;
  }

  bool _validateLanguageForm() {
    if (languageNameController.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال اسم اللغة');
      return false;
    }
    return true;
  }

  // Clear form methods
  void _clearEducationForm() {
    institutionController.clear();
    degreeController.clear();
    fieldOfStudyController.clear();
    gpaController.clear();
    descriptionController.clear();
    startDate.value = null;
    endDate.value = null;
    isCurrent.value = false;
  }

  void _clearExperienceForm() {
    companyController.clear();
    positionController.clear();
    locationController.clear();
    descriptionController.clear();
    startDate.value = null;
    endDate.value = null;
    isCurrent.value = false;
  }

  void _clearProjectForm() {
    titleController.clear();
    descriptionController.clear();
    startDate.value = null;
    endDate.value = null;
    isCompleted.value = false;
  }

  void _clearSkillForm() {
    skillNameController.clear();
    descriptionController.clear();
    selectedSkillCategory.value = 'تقنية';
    skillLevel.value = 1;
  }

  void _clearLanguageForm() {
    languageNameController.clear();
    selectedProficiency.value = 'مبتدئ';
  }

  @override
  void onClose() {
    institutionController.dispose();
    degreeController.dispose();
    fieldOfStudyController.dispose();
    companyController.dispose();
    positionController.dispose();
    locationController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    skillNameController.dispose();
    languageNameController.dispose();
    gpaController.dispose();
    certificateNameController.dispose();
    issuerController.dispose();
    credentialIdController.dispose();
    credentialUrlController.dispose();
    activityTitleController.dispose();
    organizationController.dispose();
    roleController.dispose();
    hobbyNameController.dispose();
    hobbyDescriptionController.dispose();
    super.onClose();
  }

  // Edit Portfolio Item
  // إضافة هذه الدوال في PortfolioController

  // دوال التهيئة للتعديل
  void initializeEditForm(String type, dynamic item) {
    _clearAllForms();

    switch (type) {
      case 'education':
        _initializeEducationForm(item as EducationModel);
        break;
      case 'experience':
        _initializeExperienceForm(item as ExperienceModel);
        break;
      case 'projects':
        _initializeProjectForm(item as ProjectModel);
        break;
      case 'skills':
        _initializeSkillForm(item as SkillModel);
        break;
      case 'languages':
        _initializeLanguageForm(item as LanguageModel);
        break;
      case 'certificates':
        _initializeCertificateForm(item as CertificateModel);
        break;
      case 'activities':
        _initializeActivityForm(item as ActivityModel);
        break;
      case 'hobbies':
        _initializeHobbyForm(item as HobbyModel);
        break;
    }
  }

  void _initializeEducationForm(EducationModel education) {
    institutionController.text = education.institution;
    degreeController.text = education.degree;
    fieldOfStudyController.text = education.fieldOfStudy;
    startDate.value = education.startDate;
    endDate.value = education.endDate;
    isCurrent.value = education.isCurrent;
    gpaController.text = education.gpa?.toString() ?? '';
    descriptionController.text = education.description ?? '';
  }

  void _initializeExperienceForm(ExperienceModel experience) {
    companyController.text = experience.company;
    positionController.text = experience.position;
    locationController.text = experience.location ?? '';
    startDate.value = experience.startDate;
    endDate.value = experience.endDate;
    isCurrent.value = experience.isCurrent;
    descriptionController.text = experience.description ?? '';
  }

  void _initializeProjectForm(ProjectModel project) {
    titleController.text = project.title;
    descriptionController.text = project.description;
    startDate.value = project.startDate;
    endDate.value = project.endDate;
    isCompleted.value = project.isCompleted;
  }

  void _initializeSkillForm(SkillModel skill) {
    skillNameController.text = skill.name;
    selectedSkillCategory.value = skill.category;
    skillLevel.value = skill.level;
    descriptionController.text = skill.description ?? '';
  }

  void _initializeLanguageForm(LanguageModel language) {
    languageNameController.text = language.name;
    selectedProficiency.value = language.proficiency;
  }

  void _initializeCertificateForm(CertificateModel certificate) {
    certificateNameController.text = certificate.name;
    issuerController.text = certificate.issuer;
    issueDate.value = certificate.issueDate;
    expiryDate.value = certificate.expiryDate;
    credentialIdController.text = certificate.credentialId ?? '';
    credentialUrlController.text = certificate.credentialUrl ?? '';
    descriptionController.text = certificate.description ?? '';
  }

  void _initializeActivityForm(ActivityModel activity) {
    activityTitleController.text = activity.title;
    organizationController.text = activity.organization;
    selectedActivityType.value = activity.type;
    roleController.text = activity.role ?? '';
    startDate.value = activity.startDate;
    endDate.value = activity.endDate;
    isCurrent.value = activity.isCurrent;
    descriptionController.text = activity.description ?? '';
  }

  void _initializeHobbyForm(HobbyModel hobby) {
    hobbyNameController.text = hobby.name;
    hobbyDescriptionController.text = hobby.description ?? '';
    selectedHobbyCategory.value = hobby.category;
    hobbyProficiency.value = hobby.proficiency;
    hobbyStartDate.value = hobby.startedDate;
  }

  // دوال التعديل
  Future<void> updateEducation(int index) async {
    if (!_validateEducationForm()) return;

    try {
      isLoading.value = true;
      EducationModel educationItem = education[index];

      EducationModel updatedEducation = EducationModel(
        id: educationItem.id,
        userId: educationItem.userId,
        institution: institutionController.text.trim(),
        degree: degreeController.text.trim(),
        fieldOfStudy: fieldOfStudyController.text.trim(),
        startDate: startDate.value!,
        endDate: isCurrent.value ? null : endDate.value,
        isCurrent: isCurrent.value,
        gpa: gpaController.text.isNotEmpty
            ? double.parse(gpaController.text)
            : null,
        description: descriptionController.text.trim().isNotEmpty
            ? descriptionController.text.trim()
            : null,
        createdAt: educationItem.createdAt,
        updatedAt: DateTime.now(),
      );

      await _portfolioService.updateEducation(
        educationItem.userId,
        educationItem.id,
        updatedEducation.toMap(),
      );
      education[index] = updatedEducation;

      Get.back();
      Get.snackbar('نجح', 'تم تحديث التعليم بنجاح');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحديث التعليم: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateExperience(int index) async {
    if (!_validateExperienceForm()) return;

    try {
      isLoading.value = true;
      ExperienceModel experienceItem = experience[index];

      ExperienceModel updatedExperience = ExperienceModel(
        id: experienceItem.id,
        userId: experienceItem.userId,
        company: companyController.text.trim(),
        position: positionController.text.trim(),
        location: locationController.text.trim().isNotEmpty
            ? locationController.text.trim()
            : null,
        startDate: startDate.value!,
        endDate: isCurrent.value ? null : endDate.value,
        isCurrent: isCurrent.value,
        description: descriptionController.text.trim().isNotEmpty
            ? descriptionController.text.trim()
            : null,
        createdAt: experienceItem.createdAt,
        updatedAt: DateTime.now(),
      );

      await _portfolioService.updateExperience(
        experienceItem.userId,
        experienceItem.id,
        updatedExperience.toMap(),
      );
      experience[index] = updatedExperience;

      Get.back();
      Get.snackbar('نجح', 'تم تحديث الخبرة بنجاح');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحديث الخبرة: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProject(int index) async {
    if (!_validateProjectForm()) return;

    try {
      isLoading.value = true;
      ProjectModel projectItem = projects[index];

      ProjectModel updatedProject = ProjectModel(
        id: projectItem.id,
        userId: projectItem.userId,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        startDate: startDate.value,
        endDate: endDate.value,
        isCompleted: isCompleted.value,
        createdAt: projectItem.createdAt,
        updatedAt: DateTime.now(),
      );

      await _portfolioService.updateProject(
        projectItem.userId,
        projectItem.id,
        updatedProject.toMap(),
      );
      projects[index] = updatedProject;

      Get.back();
      Get.snackbar('نجح', 'تم تحديث المشروع بنجاح');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحديث المشروع: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSkill(int index) async {
    if (!_validateSkillForm()) return;

    try {
      isLoading.value = true;
      SkillModel skillItem = skills[index];

      SkillModel updatedSkill = SkillModel(
        id: skillItem.id,
        userId: skillItem.userId,
        name: skillNameController.text.trim(),
        category: selectedSkillCategory.value,
        level: skillLevel.value,
        description: descriptionController.text.trim().isNotEmpty
            ? descriptionController.text.trim()
            : null,
        createdAt: skillItem.createdAt,
        updatedAt: DateTime.now(),
      );

      await _portfolioService.updateSkill(
        skillItem.userId,
        skillItem.id,
        updatedSkill.toMap(),
      );
      skills[index] = updatedSkill;

      Get.back();
      Get.snackbar('نجح', 'تم تحديث المهارة بنجاح');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحديث المهارة: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateLanguage(int index) async {
    if (!_validateLanguageForm()) return;

    try {
      isLoading.value = true;
      LanguageModel languageItem = languages[index];

      LanguageModel updatedLanguage = LanguageModel(
        id: languageItem.id,
        userId: languageItem.userId,
        name: languageNameController.text.trim(),
        proficiency: selectedProficiency.value,
        createdAt: languageItem.createdAt,
        updatedAt: DateTime.now(),
      );

      await _portfolioService.updateLanguage(
        languageItem.userId,
        languageItem.id,
        updatedLanguage.toMap(),
      );
      languages[index] = updatedLanguage;

      Get.back();
      Get.snackbar('نجح', 'تم تحديث اللغة بنجاح');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحديث اللغة: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCertificate(int index) async {
    if (!_validateCertificateForm()) return;

    try {
      isLoading.value = true;
      CertificateModel certificateItem = certificates[index];

      CertificateModel updatedCertificate = CertificateModel(
        id: certificateItem.id,
        userId: certificateItem.userId,
        name: certificateNameController.text.trim(),
        issuer: issuerController.text.trim(),
        issueDate: issueDate.value!,
        expiryDate: expiryDate.value,
        credentialId: credentialIdController.text.trim().isNotEmpty
            ? credentialIdController.text.trim()
            : null,
        credentialUrl: credentialUrlController.text.trim().isNotEmpty
            ? credentialUrlController.text.trim()
            : null,
        description: descriptionController.text.trim().isNotEmpty
            ? descriptionController.text.trim()
            : null,
        createdAt: certificateItem.createdAt,
        updatedAt: DateTime.now(),
      );

      await _portfolioService.updateCertificate(
        certificateItem.userId,
        certificateItem.id,
        updatedCertificate.toMap(),
      );
      certificates[index] = updatedCertificate;

      Get.back();
      Get.snackbar('نجح', 'تم تحديث الشهادة بنجاح');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحديث الشهادة: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateActivity(int index) async {
    if (!_validateActivityForm()) return;

    try {
      isLoading.value = true;
      ActivityModel activityItem = activities[index];

      ActivityModel updatedActivity = ActivityModel(
        id: activityItem.id,
        userId: activityItem.userId,
        title: activityTitleController.text.trim(),
        organization: organizationController.text.trim(),
        type: selectedActivityType.value,
        role: roleController.text.trim().isNotEmpty
            ? roleController.text.trim()
            : null,
        startDate: startDate.value!,
        endDate: isCurrent.value ? null : endDate.value,
        isCurrent: isCurrent.value,
        description: descriptionController.text.trim().isNotEmpty
            ? descriptionController.text.trim()
            : null,
        createdAt: activityItem.createdAt,
        updatedAt: DateTime.now(),
      );

      await _portfolioService.updateActivity(
        activityItem.userId,
        activityItem.id,
        updatedActivity.toMap(),
      );
      activities[index] = updatedActivity;

      Get.back();
      Get.snackbar('نجح', 'تم تحديث النشاط بنجاح');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحديث النشاط: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateHobby(int index) async {
    if (!_validateHobbyForm()) return;

    try {
      isLoading.value = true;
      HobbyModel hobbyItem = hobbies[index];

      HobbyModel updatedHobby = HobbyModel(
        id: hobbyItem.id,
        userId: hobbyItem.userId,
        name: hobbyNameController.text.trim(),
        description: hobbyDescriptionController.text.trim().isNotEmpty
            ? hobbyDescriptionController.text.trim()
            : null,
        category: selectedHobbyCategory.value,
        proficiency: hobbyProficiency.value,
        startedDate: hobbyStartDate.value,
        createdAt: hobbyItem.createdAt,
        updatedAt: DateTime.now(),
      );

      await _portfolioService.updateHobby(
        hobbyItem.userId,
        hobbyItem.id,
        hobbyItem.toMap(),
      );
      hobbies[index] = updatedHobby;

      Get.back();
      Get.snackbar('نجح', 'تم تحديث الهواية بنجاح');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحديث الهواية: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // دالة لمسح جميع الحقول
  void _clearAllForms() {
    institutionController.clear();
    degreeController.clear();
    fieldOfStudyController.clear();
    companyController.clear();
    positionController.clear();
    locationController.clear();
    titleController.clear();
    descriptionController.clear();
    skillNameController.clear();
    languageNameController.clear();
    gpaController.clear();
    certificateNameController.clear();
    issuerController.clear();
    credentialIdController.clear();
    credentialUrlController.clear();
    activityTitleController.clear();
    organizationController.clear();
    roleController.clear();
    hobbyNameController.clear();
    hobbyDescriptionController.clear();

    startDate.value = null;
    endDate.value = null;
    issueDate.value = null;
    expiryDate.value = null;
    hobbyStartDate.value = null;

    isCurrent.value = false;
    isCompleted.value = false;

    selectedSkillCategory.value = 'تقنية';
    selectedProficiency.value = 'مبتدئ';
    selectedActivityType.value = 'تطوعي';
    selectedHobbyCategory.value = 'أخرى';

    skillLevel.value = 1;
    hobbyProficiency.value = 1;
  }
}
