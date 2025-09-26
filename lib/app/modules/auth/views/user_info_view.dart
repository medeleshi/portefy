import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../../theme/app_theme.dart';
import '../controllers/auth_controller.dart';

class UserInfoView extends GetView<AuthController> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('إكمال الملف الشخصي'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            Obx(
              () => Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    _buildStepIndicator(
                      0,
                      'الأساسيات',
                      controller.currentStep.value >= 0,
                    ),
                    Expanded(
                      child: _buildProgressLine(
                        controller.currentStep.value >= 1,
                      ),
                    ),
                    _buildStepIndicator(
                      1,
                      'الأكاديمية',
                      controller.currentStep.value >= 1,
                    ),
                    Expanded(
                      child: _buildProgressLine(
                        controller.currentStep.value >= 2,
                      ),
                    ),
                    _buildStepIndicator(
                      2,
                      'الشخصية',
                      controller.currentStep.value >= 2,
                    ),
                  ],
                ),
              ),
            ),

            // PageView Content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => controller.currentStep.value = index,
                children: [
                  _buildStep1(context),
                  _buildStep2(context),
                  _buildStep3(context),
                ],
              ),
            ),

            // Navigation Buttons
            Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Obx(
                () => Row(
                  children: [
                    if (controller.currentStep.value > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousStep,
                          child: Text('السابق'),
                        ),
                      ),
                    if (controller.currentStep.value > 0) SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : _handleNext,
                        child: controller.isLoading.value
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                controller.currentStep.value == 2
                                    ? 'إكمال الملف الشخصي'
                                    : 'التالي',
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String title, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? AppColors.primary
                : AppColors.textSecondary.withOpacity(0.3),
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool isActive) {
    return Container(
      height: 2,
      margin: EdgeInsets.only(bottom: 20),
      color: isActive
          ? AppColors.primary
          : AppColors.textSecondary.withOpacity(0.3),
    );
  }

  // Step 1: Basic Information
  Widget _buildStep1(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Form(
        key: controller.step1FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'المعلومات الأساسية',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 8),

            Text(
              'ادخل معلوماتك الشخصية الأساسية',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 40),

            // Profile Photo Section
            Center(
              child: GestureDetector(
                onTap: controller.pickProfileImage,
                child: Obx(
                  () => Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.1),
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: controller.profileImage.value != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.file(
                              File(controller.profileImage.value!.path),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: AppColors.primary,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'اضافة صورة',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 32),

            // First Name
            TextFormField(
              decoration: InputDecoration(
                labelText: 'الاسم الأول *',
                prefixIcon: Icon(Icons.person_outline),
                helperText: 'مثال: أحمد',
              ),
              validator: (value) =>
                  controller.validateName(value, 'الاسم الأول'),
              onChanged: controller.firstName.call,
            ),

            SizedBox(height: 20),

            // Last Name
            TextFormField(
              decoration: InputDecoration(
                labelText: 'اسم العائلة *',
                prefixIcon: Icon(Icons.person_outline),
                helperText: 'مثال: محمد',
              ),
              validator: (value) =>
                  controller.validateName(value, 'اسم العائلة'),
              onChanged: controller.lastName.call,
            ),

            SizedBox(height: 20),

            // Phone Number with fixed City code
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // City Code (Fixed for Tunisia)
                Container(
                  width: 100,
                  child: TextFormField(
                    enabled: false,
                    initialValue: '+216',
                    decoration: InputDecoration(
                      // labelText: 'ر.د',
                      prefixIcon: Icon(Icons.flag_outlined),
                    ),
                  ),
                ),
                SizedBox(width: 16),

                // Phone Number
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف *',
                      prefixIcon: Icon(Icons.phone_outlined),
                      helperText: '8 أرقام بدون مسافات، مثال: 12345678',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال رقم الهاتف';
                      }
                      if (!RegExp(r'^\d{8}$').hasMatch(value)) {
                        return '8 أرقام فقط';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      // تخزين رقم الهاتف كاملاً مع الرمز الدولي
                      controller.phone.value = '+216$value';
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Gender
            Obx(
              () => DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'الجنس *',
                  prefixIcon: Icon(Icons.person_2_outlined),
                  helperText: 'اختر الجنس المناسب',
                ),
                value: controller.selectedGender.value.isNotEmpty
                    ? controller.selectedGender.value
                    : null,
                items: [
                  DropdownMenuItem(value: 'ذكر', child: Text('ذكر')),
                  DropdownMenuItem(value: 'أنثى', child: Text('أنثى')),
                ],
                onChanged: (value) =>
                    controller.selectedGender.value = value ?? '',
                validator: (value) =>
                    controller.validateRequired(value, 'الجنس'),
              ),
            ),

            SizedBox(height: 20),

            // Date of Birth
            Obx(
              () => InkWell(
                onTap: controller.selectDateOfBirth,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'تاريخ الميلاد *',
                    prefixIcon: Icon(Icons.cake_outlined),
                    suffixIcon: Icon(Icons.arrow_drop_down),
                    helperText: 'اختر تاريخ ميلادك',
                  ),
                  child: Text(
                    controller.selectedDateOfBirth.value != null
                        ? DateFormat(
                            'dd/MM/yyyy',
                          ).format(controller.selectedDateOfBirth.value!)
                        : 'اختر تاريخ الميلاد',
                    style: TextStyle(
                      color: controller.selectedDateOfBirth.value != null
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 2: Academic Information
  Widget _buildStep2(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Form(
        key: controller.step2FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'المعلومات الأكاديمية',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 8),

            Text(
              'ادخل معلوماتك الدراسية والأكاديمية',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 40),

            // City
            Obx(
              () => DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'الولاية *',
                  prefixIcon: Icon(Icons.flag_outlined),
                  helperText: 'اختر ولاية جامعتك',
                ),
                initialValue: controller.selectedCity.value.isNotEmpty
                    ? controller.selectedCity.value
                    : 'BEJA',
                items: controller.tunisianGovernorates
                    .map(
                      (city) =>
                          DropdownMenuItem(value: city, child: Text(city)),
                    )
                    .toList(),
                onChanged: (value) =>
                    controller.selectedCity.value = value ?? 'BEJA',
                validator: (value) =>
                    controller.validateRequired(value, 'الولاية'),
              ),
            ),

            SizedBox(height: 20),

            // University (with abbreviation example)
            TextFormField(
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zأ-ي\s]')),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  return newValue.copyWith(text: newValue.text.toUpperCase());
                }),
              ],
              decoration: InputDecoration(
                labelText: 'الجامعة *',
                prefixIcon: Icon(Icons.school_outlined),
                helperText:
                    'اكتب اسم الجامعة مختصراً، مثال: IHEC SFAX, ISET KEBILI, ENIM MONASTIR',
              ),
              validator: (value) =>
                  controller.validateRequired(value, 'الجامعة'),
              onChanged: controller.university.call,
            ),

            SizedBox(height: 20),

            // Major in French
            TextFormField(
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zأ-ي\s]')),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  return newValue.copyWith(text: newValue.text.toUpperCase());
                }),
              ],
              decoration: InputDecoration(
                labelText: 'التخصص (بالفرنسية) *',
                prefixIcon: Icon(Icons.book_outlined),
                helperText: 'مثال: INFORMATIQUE, GESTION, MEDECINE',
              ),
              validator: (value) =>
                  controller.validateRequired(value, 'التخصص'),
              onChanged: controller.major.call,
            ),

            SizedBox(height: 20),

            // Academic level with correct abbreviations
            Obx(
              () => DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'المستوى الأكاديمي *',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  helperText: 'اختر مستواك الدراسي الحالي',
                ),
                initialValue: controller.level.value.isNotEmpty
                    ? controller.level.value
                    : null,
                items: controller.academicLevels.map((level) {
                  return DropdownMenuItem(
                    value: level['value'],
                    child: Text(level['label']!),
                  );
                }).toList(),
                onChanged: (value) => controller.level.value = value ?? '',
                validator: (value) =>
                    controller.validateRequired(value, 'المستوى الأكاديمي'),
              ),
            ),

            SizedBox(height: 40),

            // Academic Info Card
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.primary,
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'نصيحة',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'ستساعدك هذه المعلومات في العثور على المحتوى المناسب لتخصصك ومستواك الدراسي',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 3: Personal Information
  Widget _buildStep3(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Form(
        key: controller.step3FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'اللمسة الأخيرة',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 8),

            Text(
              'أخبرنا المزيد عن نفسك لنقدم لك تجربة شخصية',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 40),

            // Bio
            TextFormField(
              decoration: InputDecoration(
                labelText: 'نبذة عنك (اختياري)',
                prefixIcon: Icon(Icons.description_outlined),
                hintText: 'اكتب نبذة مختصرة عن نفسك، اهتماماتك، وأهدافك...',
                helperText: 'مثال: طالب علوم حاسوب مهتم بالذكاء الاصطناعي',
              ),
              maxLines: 4,
              maxLength: 200,
              onChanged: controller.bio.call,
            ),

            SizedBox(height: 40),

            // Completion Summary Card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.celebration, color: AppColors.primary, size: 40),
                  SizedBox(height: 12),
                  Text(
                    'مرحباً بك!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'أنت على وشك إكمال ملفك الشخصي والانضمام إلى مجتمعنا التعليمي',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFeatureItem(Icons.group, 'تواصل مع الطلاب'),
                      _buildFeatureItem(Icons.book, 'محتوى تعليمي'),
                      _buildFeatureItem(Icons.star, 'نقاط وإنجازات'),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Required Fields Note
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'الحقول المميزة بـ * مطلوبة',
                      style: TextStyle(color: AppColors.warning, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _nextStep() {
    if (controller.currentStep.value < 2) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (controller.currentStep.value > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleNext() {
    bool isValid = false;

    switch (controller.currentStep.value) {
      case 0:
        isValid = controller.step1FormKey.currentState?.validate() ?? false;
        if (isValid && controller.selectedDateOfBirth.value == null) {
          Get.snackbar(
            'خطأ',
            'يرجى اختيار تاريخ الميلاد',
            snackPosition: SnackPosition.BOTTOM,
          );
          isValid = false;
        }
        if (isValid && controller.selectedGender.value.isEmpty) {
          Get.snackbar(
            'خطأ',
            'يرجى اختيار الجنس',
            snackPosition: SnackPosition.BOTTOM,
          );
          isValid = false;
        }
        break;
      case 1:
        isValid = controller.step2FormKey.currentState?.validate() ?? false;
        break;
      case 2:
        isValid = controller.step3FormKey.currentState?.validate() ?? false;
        if (isValid) {
          controller.completeProfile();
          return;
        }
        break;
    }

    if (isValid) {
      _nextStep();
    }
  }
}
