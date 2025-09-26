import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_theme.dart';
import '../controllers/settings_controller.dart';

class EditProfileView extends GetView<SettingsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('تعديل الملف الشخصي'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Obx(() => TextButton(
            onPressed: controller.isUpdatingProfile.value 
                ? null 
                : controller.updateProfile,
            child: controller.isUpdatingProfile.value
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'حفظ',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          )),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Image Section
            _buildProfileImageSection(),
            
            SizedBox(height: 24),
            
            // Personal Information
            _buildSection(
              title: 'المعلومات الشخصية',
              icon: Icons.person_outline,
              children: [
                _buildTextFormField(
                  controller: controller.firstNameController,
                  label: 'الاسم الأول',
                  icon: Icons.person,
                  validator: (value) => 
                      value?.isEmpty == true ? 'مطلوب' : null,
                ),
                SizedBox(height: 16),
                _buildTextFormField(
                  controller: controller.lastNameController,
                  label: 'الاسم الأخير',
                  icon: Icons.person,
                  validator: (value) => 
                      value?.isEmpty == true ? 'مطلوب' : null,
                ),
                SizedBox(height: 16),
                _buildTextFormField(
                  controller: controller.phoneController,
                  label: 'رقم الهاتف',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  hint: '+966xxxxxxxxx',
                ),
                SizedBox(height: 16),
                _buildGenderSelector(),
                SizedBox(height: 16),
                _buildDateSelector(),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Academic Information
            _buildSection(
              title: 'المعلومات الأكاديمية',
              icon: Icons.school_outlined,
              children: [
                _buildTextFormField(
                  controller: controller.universityController,
                  label: 'الجامعة',
                  icon: Icons.school,
                ),
                SizedBox(height: 16),
                _buildTextFormField(
                  controller: controller.majorController,
                  label: 'التخصص',
                  icon: Icons.bookmark,
                ),
                SizedBox(height: 16),
                _buildTextFormField(
                  controller: controller.yearController,
                  label: 'المستوى الدراسي',
                  icon: Icons.grade,
                  hint: 'البكالوريوس - السنة الثالثة',
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Location Information
            _buildSection(
              title: 'معلومات الموقع',
              icon: Icons.location_on_outlined,
              children: [
                _buildTextFormField(
                  controller: controller.cityController,
                  label: 'المدينة',
                  icon: Icons.location_city,
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Bio Section
            _buildSection(
              title: 'النبذة الشخصية',
              icon: Icons.description_outlined,
              children: [
                _buildTextFormField(
                  controller: controller.bioController,
                  label: 'اكتب نبذة عن نفسك',
                  icon: Icons.description,
                  maxLines: 4,
                  hint: 'أخبر الآخرين عن اهتماماتك وأهدافك...',
                ),
              ],
            ),
            
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Obx(() => Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: controller.selectedProfileImage.value != null
                      ? FileImage(controller.selectedProfileImage.value!)
                      : (controller.profileImageUrl.value.isNotEmpty
                          ? NetworkImage(controller.profileImageUrl.value)
                          : null),
                  child: (controller.selectedProfileImage.value == null && 
                          controller.profileImageUrl.value.isEmpty)
                      ? Icon(
                          Icons.person,
                          size: 50,
                          color: AppColors.primary,
                        )
                      : null,
                ),
              )),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showImagePicker,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'اضغط لتغيير الصورة',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(color: AppColors.textPrimary),
    );
  }

  Widget _buildGenderSelector() {
    return Obx(() => Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Icon(Icons.person_outline),
        title: Text(
          controller.selectedGender.value.isEmpty 
              ? 'الجنس' 
              : controller.selectedGender.value,
          style: TextStyle(
            color: controller.selectedGender.value.isEmpty 
                ? AppColors.textSecondary 
                : AppColors.textPrimary,
          ),
        ),
        children: controller.genderOptions.map((gender) => 
          ListTile(
            title: Text(gender),
            onTap: () {
              controller.selectedGender.value = gender;
            },
            trailing: controller.selectedGender.value == gender
                ? Icon(Icons.check, color: AppColors.primary)
                : null,
          ),
        ).toList(),
      ),
    ));
  }

  Widget _buildDateSelector() {
    return Obx(() => GestureDetector(
      onTap: controller.selectDateOfBirth,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.textSecondary),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                controller.selectedDateOfBirth.value != null
                    ? '${controller.selectedDateOfBirth.value!.day}/${controller.selectedDateOfBirth.value!.month}/${controller.selectedDateOfBirth.value!.year}'
                    : 'تاريخ الميلاد',
                style: TextStyle(
                  color: controller.selectedDateOfBirth.value != null 
                      ? AppColors.textPrimary 
                      : AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    ));
  }

  void _showImagePicker() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'تغيير صورة الملف الشخصي',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildImageOption(
                    icon: Icons.photo_library,
                    title: 'المعرض',
                    onTap: () {
                      Get.back();
                      controller.pickProfileImage();
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildImageOption(
                    icon: Icons.camera_alt,
                    title: 'الكاميرا',
                    onTap: () {
                      Get.back();
                      controller.takePhoto();
                    },
                  ),
                ),
              ],
            ),
            if (controller.profileImageUrl.value.isNotEmpty || 
                controller.selectedProfileImage.value != null) ...[
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Get.back();
                    controller.removeProfileImage();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline),
                      SizedBox(width: 8),
                      Text('إزالة الصورة'),
                    ],
                  ),
                ),
              ),
            ],
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}