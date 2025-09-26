import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/points_notification_widget.dart';
import '../controllers/portfolio_controller.dart';

class AddPortfolioItemView extends GetView<PortfolioController> {
  @override
  Widget build(BuildContext context) {
    final String type = Get.arguments['type'] ?? 'education';
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'إضافة ${_getDisplayName(type)}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Points Preview
            _buildPointsPreview(type),
            
            SizedBox(height: 20),
            
            // Form Content
            _buildFormContent(type),
            
            SizedBox(height: 30),
            
            // Submit Button
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value 
                        ? null 
                        : () => _submitForm(type),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'إضافة ${_getDisplayName(type)}',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  String _getDisplayName(String type) {
    switch (type) {
      case 'education':
        return 'تعليم';
      case 'experience':
        return 'خبرة عملية';
      case 'projects':
        return 'مشروع';
      case 'skills':
        return 'مهارة';
      case 'languages':
        return 'لغة';
      case 'certificates':
        return 'شهادة';
      case 'activities':
        return 'نشاط';
      case 'hobbies':
        return 'هواية';
      default:
        return 'عنصر';
    }
  }

  Widget _buildPointsPreview(String type) {
    String action = _getActionForType(type);
    String description = _getPointsDescription(type);
    IconData icon = _getIconForType(type);
    
    return PointsPreviewWidget(
      action: action,
      description: description,
      icon: icon,
    );
  }

  Widget _buildFormContent(String type) {
    switch (type) {
      case 'education':
        return _buildEducationForm();
      case 'experience':
        return _buildExperienceForm();
      case 'projects':
        return _buildProjectForm();
      case 'skills':
        return _buildSkillForm();
      case 'languages':
        return _buildLanguageForm();
      case 'certificates':
        return _buildCertificateForm();
      case 'activities':
        return _buildActivityForm();
      case 'hobbies':
        return _buildHobbyForm();
      default:
        return _buildEducationForm();
    }
  }

  Widget _buildEducationForm() {
    return Column(
      children: [
        _buildFormField(
          controller: controller.institutionController,
          label: 'المؤسسة التعليمية *',
          icon: Icons.school,
        ),
        
        SizedBox(height: 16),
        
        _buildFormField(
          controller: controller.degreeController,
          label: 'الدرجة العلمية *',
          icon: Icons.school,
        ),
        
        SizedBox(height: 16),
        
        _buildFormField(
          controller: controller.fieldOfStudyController,
          label: 'التخصص *',
          icon: Icons.book,
        ),
        
        SizedBox(height: 16),
        
        // Date Fields
        Row(
          children: [
            Expanded(
              child: Obx(() => _buildDateField(
                label: 'تاريخ البداية *',
                value: controller.startDate.value,
                onTap: controller.selectStartDate,
              )),
            ),
            
            SizedBox(width: 12),
            
            Expanded(
              child: Obx(() => controller.isCurrent.value
                  ? _buildCurrentIndicator('مستمر حالياً')
                  : _buildDateField(
                      label: 'تاريخ النهاية',
                      value: controller.endDate.value,
                      onTap: controller.selectEndDate,
                    )),
            ),
          ],
        ),
        
        SizedBox(height: 16),
        
        // Current checkbox
        Obx(() => _buildCheckbox(
          title: 'مستمر حالياً',
          value: controller.isCurrent.value,
          onChanged: (value) => controller.isCurrent.value = value ?? false,
        )),
        
        SizedBox(height: 16),
        
        _buildFormField(
          controller: controller.gpaController,
          label: 'المعدل التراكمي (اختياري)',
          icon: Icons.grade,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
        
        SizedBox(height: 16),
        
        _buildFormField(
          controller: controller.descriptionController,
          label: 'وصف (اختياري)',
          icon: Icons.description,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildExperienceForm() {
    return Column(
      children: [
        _buildFormField(
          controller: controller.companyController,
          label: 'اسم الشركة *',
          icon: Icons.business,
        ),
        
        SizedBox(height: 16),
        
        _buildFormField(
          controller: controller.positionController,
          label: 'المنصب *',
          icon: Icons.work,
        ),
        
        SizedBox(height: 16),
        
        _buildFormField(
          controller: controller.locationController,
          label: 'الموقع (اختياري)',
          icon: Icons.location_on,
        ),
        
        SizedBox(height: 16),
        
        // Date fields
        Row(
          children: [
            Expanded(
              child: Obx(() => _buildDateField(
                label: 'تاريخ البداية *',
                value: controller.startDate.value,
                onTap: controller.selectStartDate,
              )),
            ),
            
            SizedBox(width: 12),
            
            Expanded(
              child: Obx(() => controller.isCurrent.value
                  ? _buildCurrentIndicator('أعمل حالياً')
                  : _buildDateField(
                      label: 'تاريخ النهاية',
                      value: controller.endDate.value,
                      onTap: controller.selectEndDate,
                    )),
            ),
          ],
        ),
        
        SizedBox(height: 16),
        
        Obx(() => _buildCheckbox(
          title: 'أعمل حالياً',
          value: controller.isCurrent.value,
          onChanged: (value) => controller.isCurrent.value = value ?? false,
        )),
        
        SizedBox(height: 16),
        
        _buildFormField(
          controller: controller.descriptionController,
          label: 'وصف العمل (اختياري)',
          icon: Icons.description,
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildProjectForm() {
    return Column(
      children: [
        _buildFormField(
          controller: controller.titleController,
          label: 'عنوان المشروع *',
          icon: Icons.lightbulb,
        ),
        
        SizedBox(height: 16),
        
        _buildFormField(
          controller: controller.descriptionController,
          label: 'وصف المشروع *',
          icon: Icons.description,
          maxLines: 4,
        ),
        
        SizedBox(height: 16),
        
        Obx(() => _buildCheckbox(
          title: 'المشروع مكتمل',
          value: controller.isCompleted.value,
          onChanged: (value) => controller.isCompleted.value = value ?? false,
        )),
      ],
    );
  }

  Widget _buildSkillForm() {
    return Column(
      children: [
        _buildFormField(
          controller: controller.skillNameController,
          label: 'اسم المهارة *',
          icon: Icons.star,
        ),
        
        SizedBox(height: 16),
        
        Obx(() => _buildDropdown(
          label: 'فئة المهارة *',
          icon: Icons.category,
          value: controller.selectedSkillCategory.value,
          items: controller.skillCategories,
          onChanged: (value) => controller.selectedSkillCategory.value = value ?? 'تقنية',
        )),
        
        SizedBox(height: 16),
        
        Text('مستوى المهارة', style: TextStyle(fontWeight: FontWeight.bold)),
        Obx(() => Slider(
              value: controller.skillLevel.value.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: '${controller.skillLevel.value}/5',
              onChanged: (value) => controller.skillLevel.value = value.round(),
            )),
        
        SizedBox(height: 16),
        
        _buildFormField(
          controller: controller.descriptionController,
          label: 'وصف المهارة (اختياري)',
          icon: Icons.description,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildLanguageForm() {
    return Column(
      children: [
        _buildFormField(
          controller: controller.languageNameController,
          label: 'اسم اللغة *',
          icon: Icons.language,
        ),
        
        SizedBox(height: 16),
        
        Obx(() => _buildDropdown(
          label: 'مستوى الإتقان *',
          icon: Icons.bar_chart,
          value: controller.selectedProficiency.value,
          items: controller.proficiencyLevels,
          onChanged: (value) => controller.selectedProficiency.value = value ?? 'مبتدئ',
        )),
      ],
    );
  }

  Widget _buildCertificateForm() {
    return Column(
      children: [
        _buildFormField(
          controller: controller.certificateNameController,
          label: 'اسم الشهادة *',
          icon: Icons.card_membership,
        ),
        
        SizedBox(height: 16),
        
        _buildFormField(
          controller: controller.issuerController,
          label: 'اسم الجهة المانحة *',
          icon: Icons.business,
        ),
        
        SizedBox(height: 16),
        
        Obx(() => _buildDateField(
          label: 'تاريخ الإصدار *',
          value: controller.issueDate.value,
          onTap: () => controller.selectIssueDate(),
        )),
        
        SizedBox(height: 16),
        
        Obx(() => _buildDateField(
          label: 'تاريخ الانتهاء (اختياري)',
          value: controller.expiryDate.value,
          onTap: () => controller.selectExpiryDate(),
        )),
        
        SizedBox(height: 16),
        
        _buildFormField(
          controller: controller.credentialIdController,
          label: 'رقم الشهادة (اختياري)',
          icon: Icons.numbers,
        ),
        
        SizedBox(height: 16),
        
        _buildFormField(
          controller: controller.credentialUrlController,
          label: 'رابط الشهادة (اختياري)',
          icon: Icons.link,
        ),
        
        SizedBox(height: 16),
        
        _buildFormField(
          controller: controller.descriptionController,
          label: 'وصف الشهادة (اختياري)',
          icon: Icons.description,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildActivityForm() {
    return Column(
      children: [
        _buildFormField(
          controller: controller.activityTitleController,
          label: 'عنوان النشاط *',
          icon: Icons.group_work,
        ),
        
        SizedBox(height: 16),
        
        _buildFormField(
          controller: controller.organizationController,
          label: 'اسم المنظمة *',
          icon: Icons.business,
        ),
        
        SizedBox(height: 16),
        
        Obx(() => _buildDropdown(
          label: 'نوع النشاط *',
          icon: Icons.category,
          value: controller.selectedActivityType.value,
          items: controller.activityTypes,
          onChanged: (value) => controller.selectedActivityType.value = value ?? 'تطوعي',
        )),
        
        SizedBox(height: 16),
        
        _buildFormField(
          controller: controller.roleController,
          label: 'الدور (اختياري)',
          icon: Icons.person,
        ),
        
        SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: Obx(() => _buildDateField(
                label: 'تاريخ البداية *',
                value: controller.startDate.value,
                onTap: controller.selectStartDate,
              )),
            ),
            
            SizedBox(width: 12),
            
            Expanded(
              child: Obx(() => controller.isCurrent.value
                  ? _buildCurrentIndicator('مستمر حالياً')
                  : _buildDateField(
                      label: 'تاريخ النهاية',
                      value: controller.endDate.value,
                      onTap: controller.selectEndDate,
                    )),
            ),
          ],
        ),
        
        SizedBox(height: 16),
        
        Obx(() => _buildCheckbox(
          title: 'مستمر حالياً',
          value: controller.isCurrent.value,
          onChanged: (value) => controller.isCurrent.value = value ?? false,
        )),
        
        SizedBox(height: 16),
        
        _buildFormField(
          controller: controller.descriptionController,
          label: 'وصف النشاط (اختياري)',
          icon: Icons.description,
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildHobbyForm() {
    return Column(
      children: [
        _buildFormField(
          controller: controller.hobbyNameController,
          label: 'اسم الهواية *',
          icon: Icons.music_note,
        ),
        
        SizedBox(height: 16),
        
        _buildFormField(
          controller: controller.hobbyDescriptionController,
          label: 'وصف الهواية (اختياري)',
          icon: Icons.description,
          maxLines: 3,
        ),
        
        SizedBox(height: 16),
        
        Obx(() => _buildDropdown(
          label: 'فئة الهواية',
          icon: Icons.category,
          value: controller.selectedHobbyCategory.value,
          items: controller.hobbyCategories,
          onChanged: (value) => controller.selectedHobbyCategory.value = value ?? 'أخرى',
        )),
        
        SizedBox(height: 16),
        
        Text('مستوى الإتقان', style: TextStyle(fontWeight: FontWeight.bold)),
        Obx(() => Slider(
              value: controller.hobbyProficiency.value.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: '${controller.hobbyProficiency.value}/5',
              onChanged: (value) => controller.hobbyProficiency.value = value.round(),
            )),
        
        SizedBox(height: 16),
        
        Obx(() => _buildDateField(
          label: 'تاريخ البدء (اختياري)',
          value: controller.hobbyStartDate.value,
          onTap: () => controller.selectHobbyStartDate(),
        )),
      ],
    );
  }

  // Widgets helpers
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          value != null
              ? DateFormat('dd/MM/yyyy').format(value)
              : 'اختر التاريخ',
        ),
      ),
    );
  }

  Widget _buildCurrentIndicator(String text) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCheckbox({
    required String title,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return CheckboxListTile(
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      value: value,
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  void _submitForm(String type) {
    switch (type) {
      case 'education':
        controller.addEducation();
        break;
      case 'experience':
        controller.addExperience();
        break;
      case 'projects':
        controller.addProject();
        break;
      case 'skills':
        controller.addSkill();
        break;
      case 'languages':
        controller.addLanguage();
        break;
      case 'certificates':
        controller.addCertificate();
        break;
      case 'activities':
        controller.addActivity();
        break;
      case 'hobbies':
        controller.addHobby();
        break;
    }
  }

  String _getActionForType(String type) {
    switch (type) {
      case 'education':
        return 'add_education';
      case 'experience':
        return 'add_experience';
      case 'projects':
        return 'add_project';
      case 'skills':
        return 'add_skill';
      case 'languages':
        return 'add_language';
      case 'certificates':
        return 'add_certificate';
      case 'activities':
        return 'add_activity';
      case 'hobbies':
        return 'add_hobby';
      default:
        return 'add_education';
    }
  }

  String _getPointsDescription(String type) {
    switch (type) {
      case 'education':
        return 'احصل على نقاط بإضافة معلومات تعليمية';
      case 'experience':
        return 'احصل على نقاط بإضافة خبرة عملية';
      case 'projects':
        return 'احصل على نقاط بإضافة مشروع';
      case 'skills':
        return 'احصل على نقاط بإضافة مهارة';
      case 'languages':
        return 'احصل على نقاط بإضافة لغة';
      case 'certificates':
        return 'احصل على نقاط بإضافة شهادة';
      case 'activities':
        return 'احصل على نقاط بإضافة نشاط';
      case 'hobbies':
        return 'احصل على نقاط بإضافة هواية';
      default:
        return 'احصل على نقاط';
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'education':
        return Icons.school;
      case 'experience':
        return Icons.work;
      case 'projects':
        return Icons.lightbulb;
      case 'skills':
        return Icons.star;
      case 'languages':
        return Icons.language;
      case 'certificates':
        return Icons.card_membership;
      case 'activities':
        return Icons.group_work;
      case 'hobbies':
        return Icons.music_note;
      default:
        return Icons.add;
    }
  }
}