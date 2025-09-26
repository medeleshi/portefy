import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/points_notification_widget.dart';
import '../controllers/portfolio_controller.dart';

class EditPortfolioItemView extends GetView<PortfolioController> {
  final String type;
  final dynamic item;
  final int index;

  const EditPortfolioItemView({super.key, 
    required this.type,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    controller.initializeEditForm(type, item);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'تعديل ${_getDisplayName(type)}',
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
            // Points Preview (only for adding, not editing)
            
            SizedBox(height: 20),
            
            // Form Content
            _buildFormContent(type),
            
            SizedBox(height: 30),
            
            // Update Button
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value 
                        ? null 
                        : () => _updateForm(type, index),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'تحديث ${_getDisplayName(type)}',
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

  // جميع دوال بناء النماذج (مشابهة لـ add_portfolio_item.dart)
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

  // في ملف edit_portfolio_item.dart، أضف هذه الدوال بعد _buildExperienceForm()

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
      
      // تاريخ البداية والنهاية للمشروع
      Row(
        children: [
          Expanded(
            child: Obx(() => _buildDateField(
              label: 'تاريخ البداية (اختياري)',
              value: controller.startDate.value,
              onTap: controller.selectStartDate,
            )),
          ),
          
          SizedBox(width: 12),
          
          Expanded(
            child: Obx(() => _buildDateField(
              label: 'تاريخ النهاية (اختياري)',
              value: controller.endDate.value,
              onTap: controller.selectEndDate,
            )),
          ),
        ],
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

  // ... (بقية دوال بناء النماذج مشابهة لـ add_portfolio_item.dart)

  // Widgets helpers (مشابهة لـ add_portfolio_item.dart)
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

  void _updateForm(String type, int index) {
    switch (type) {
      case 'education':
        controller.updateEducation(index);
        break;
      case 'experience':
        controller.updateExperience(index);
        break;
      case 'projects':
        controller.updateProject(index);
        break;
      case 'skills':
        controller.updateSkill(index);
        break;
      case 'languages':
        controller.updateLanguage(index);
        break;
      case 'certificates':
        controller.updateCertificate(index);
        break;
      case 'activities':
        controller.updateActivity(index);
        break;
      case 'hobbies':
        controller.updateHobby(index);
        break;
    }
  }
}