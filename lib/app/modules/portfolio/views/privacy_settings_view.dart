// // lib/app/modules/portfolio/views/privacy_settings_view.dart

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../theme/app_theme.dart';
// import '../../../services/auth_service.dart';

// class PrivacySettingsView extends StatefulWidget {
//   @override
//   _PrivacySettingsViewState createState() => _PrivacySettingsViewState();
// }

// class _PrivacySettingsViewState extends State<PrivacySettingsView> {
//   final AuthService _authService = Get.find<AuthService>();
//   final RxString selectedPrivacy = 'public'.obs;
//   final RxBool showEmail = false.obs;
//   final RxBool showPhone = false.obs;
//   final RxBool allowFriendRequests = true.obs;
//   final RxBool showOnlineStatus = true.obs;
//   final RxBool allowMessagesFromStrangers = false.obs;
//   final RxBool allowTagging = true.obs;
//   final RxBool isLoading = true.obs;
//   final RxBool isSaving = false.obs;

//   @override
//   void initState() {
//     super.initState();
//     _loadCurrentSettings();
//   }

//   Future<void> _loadCurrentSettings() async {
//     try {
//       String? userId = _authService.currentUserId;
//       if (userId == null) return;

//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userId)
//           .get();

//       if (userDoc.exists) {
//         Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
//         selectedPrivacy.value = data['portfolioPrivacy'] ?? 'public';
//         showEmail.value = data['showEmail'] ?? false;
//         showPhone.value = data['showPhone'] ?? false;
//         allowFriendRequests.value = data['allowFriendRequests'] ?? true;
//         showOnlineStatus.value = data['showOnlineStatus'] ?? true;
//         allowMessagesFromStrangers.value = data['allowMessagesFromStrangers'] ?? false;
//         allowTagging.value = data['allowTagging'] ?? true;
//       }
//     } catch (e) {
//       Get.snackbar('خطأ', 'فشل حذف البيانات: ${e.toString()}');
//     }
//   }

//   void _temporaryHideAccount() {
//     Get.dialog(
//       AlertDialog(
//         title: Text('إخفاء الحساب مؤقتاً'),
//         content: Text(
//           'هل تريد إخفاء حسابك مؤقتاً؟\n\n'
//           'سيصبح ملفك الشخصي غير مرئي للآخرين ولكن يمكنك إظهاره مرة أخرى في أي وقت.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               Get.back();
//               try {
//                 String? userId = _authService.currentUserId;
//                 if (userId != null) {
//                   await FirebaseFirestore.instance
//                       .collection('users')
//                       .doc(userId)
//                       .update({
//                     'isHidden': true,
//                     'hiddenAt': FieldValue.serverTimestamp(),
//                   });
//                   Get.snackbar(
//                     'تم',
//                     'تم إخفاء الحساب مؤقتاً',
//                     backgroundColor: AppColors.warning.withOpacity(0.1),
//                     colorText: AppColors.warning,
//                   );
//                 }
//               } catch (e) {
//                 Get.snackbar('خطأ', 'فشل إخفاء الحساب');
//               }
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
//             child: Text('إخفاء', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
// }('خطأ', 'فشل تحميل الإعدادات: ${e.toString()}');
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: AppColors.primary,
//         title: Text('إعدادات الخصوصية'),
//         elevation: 0,
//         actions: [
//           Obx(() => TextButton(
//             onPressed: isSaving.value ? null : _saveSettings,
//             child: isSaving.value
//                 ? SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(
//                       color: Colors.white,
//                       strokeWidth: 2,
//                     ),
//                   )
//                 : Text(
//                     'حفظ',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//           )),
//         ],
//       ),
//       body: Obx(() => isLoading.value 
//           ? Center(child: CircularProgressIndicator())
//           : _buildSettingsList()
//       ),
//     );
//   }

//   Widget _buildSettingsList() {
//     return ListView(
//       padding: EdgeInsets.all(16),
//       children: [
//         _buildSection(
//           'خصوصية الملف الشخصي',
//           'تحديد من يمكنه رؤية ملفك الشخصي',
//           Icons.visibility,
//           [
//             _buildPrivacyOption(
//               'عام',
//               'يمكن لأي شخص رؤية ملفك الشخصي',
//               'public',
//               Icons.public,
//             ),
//             _buildPrivacyOption(
//               'الأصدقاء فقط',
//               'الأصدقاء فقط يمكنهم رؤية ملفك الشخصي',
//               'friends',
//               Icons.group,
//             ),
//             _buildPrivacyOption(
//               'خاص',
//               'لا أحد يمكنه رؤية ملفك الشخصي',
//               'private',
//               Icons.lock,
//             ),
//           ],
//         ),
        
//         SizedBox(height: 24),
        
//         _buildSection(
//           'معلومات الاتصال',
//           'اختر المعلومات التي تريد إظهارها للآخرين',
//           Icons.contact_mail,
//           [
//             _buildContactOption(
//               'إظهار البريد الإلكتروني',
//               'عرض بريدك الإلكتروني في الملف الشخصي',
//               Icons.email,
//               showEmail,
//             ),
//             _buildContactOption(
//               'إظهار رقم الهاتف',
//               'عرض رقم هاتفك في الملف الشخصي',
//               Icons.phone,
//               showPhone,
//             ),
//           ],
//         ),
        
//         SizedBox(height: 24),
        
//         _buildSection(
//           'إعدادات التفاعل',
//           'تحكم في كيفية تفاعل الآخرين معك',
//           Icons.people,
//           [
//             _buildContactOption(
//               'السماح بطلبات الصداقة',
//               'يمكن للآخرين إرسال طلبات صداقة لك',
//               Icons.person_add,
//               allowFriendRequests,
//             ),
//             _buildContactOption(
//               'إظهار حالة الاتصال',
//               'عرض آخر ظهور لك للأصدقاء',
//               Icons.online_prediction,
//               showOnlineStatus,
//             ),
//             _buildContactOption(
//               'السماح بالرسائل من الغرباء',
//               'استقبال رسائل من أشخاص ليسوا أصدقاء',
//               Icons.message,
//               allowMessagesFromStrangers,
//             ),
//             _buildContactOption(
//               'السماح بالإشارة في المنشورات',
//               'يمكن للآخرين الإشارة إليك في منشوراتهم',
//               Icons.tag,
//               allowTagging,
//             ),
//           ],
//         ),
        
//         SizedBox(height: 24),
        
//         _buildWarningSection(),
        
//         SizedBox(height: 24),
        
//         _buildDangerZone(),
        
//         SizedBox(height: 100), // مساحة إضافية في الأسفل
//       ],
//     );
//   }

//   Widget _buildSection(String title, String description, IconData icon, List<Widget> children) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, color: AppColors.primary, size: 24),
//                 SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         title,
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.textPrimary,
//                         ),
//                       ),
//                       SizedBox(height: 4),
//                       Text(
//                         description,
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: AppColors.textSecondary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//             ...children,
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPrivacyOption(String title, String description, String value, IconData icon) {
//     return Obx(() => Container(
//       margin: EdgeInsets.only(bottom: 8),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(
//           color: selectedPrivacy.value == value 
//               ? AppColors.primary 
//               : Colors.transparent,
//           width: 2,
//         ),
//         color: selectedPrivacy.value == value 
//             ? AppColors.primary.withOpacity(0.1) 
//             : Colors.transparent,
//       ),
//       child: RadioListTile<String>(
//         title: Row(
//           children: [
//             Icon(
//               icon,
//               size: 20,
//               color: selectedPrivacy.value == value 
//                   ? AppColors.primary 
//                   : AppColors.textSecondary,
//             ),
//             SizedBox(width: 8),
//             Text(
//               title,
//               style: TextStyle(
//                 fontWeight: selectedPrivacy.value == value 
//                     ? FontWeight.bold 
//                     : FontWeight.normal,
//               ),
//             ),
//           ],
//         ),
//         subtitle: Text(
//           description,
//           style: TextStyle(fontSize: 12),
//         ),
//         value: value,
//         groupValue: selectedPrivacy.value,
//         onChanged: (String? newValue) {
//           if (newValue != null) {
//             selectedPrivacy.value = newValue;
//           }
//         },
//         activeColor: AppColors.primary,
//       ),
//     ));
//   }

//   Widget _buildContactOption(String title, String description, IconData icon, RxBool value) {
//     return Obx(() => Container(
//       margin: EdgeInsets.only(bottom: 8),
//       child: SwitchListTile(
//         title: Row(
//           children: [
//             Icon(icon, size: 20, color: AppColors.textSecondary),
//             SizedBox(width: 8),
//             Expanded(child: Text(title)),
//           ],
//         ),
//         subtitle: Text(
//           description,
//           style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
//         ),
//         value: value.value,
//         onChanged: (bool newValue) {
//           value.value = newValue;
//         },
//         activeColor: AppColors.primary,
//         contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       ),
//     ));
//   }

//   Widget _buildWarningSection() {
//     return Card(
//       color: AppColors.warning.withOpacity(0.1),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: AppColors.warning.withOpacity(0.3)),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.info, color: AppColors.warning),
//                 SizedBox(width: 12),
//                 Text(
//                   'ملاحظات مهمة',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.warning,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 12),
//             Text(
//               '• تغيير إعدادات الخصوصية قد يؤثر على رؤية الآخرين لملفك الشخصي\n'
//               '• الملفات الخاصة لن تظهر في نتائج البحث\n'
//               '• يمكن للأصدقاء الحاليين رؤية ملفك حتى لو كان للأصدقاء فقط\n'
//               '• بعض المعلومات الأساسية قد تبقى مرئية دائماً',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: AppColors.textSecondary,
//                 height: 1.5,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDangerZone() {
//     return Card(
//       color: AppColors.error.withOpacity(0.1),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: AppColors.error.withOpacity(0.3)),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.warning, color: AppColors.error),
//                 SizedBox(width: 12),
//                 Text(
//                   'المنطقة الخطيرة',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.error,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//             _buildDangerAction(
//               'حذف جميع بيانات الملف الشخصي',
//               'حذف جميع المعلومات من التعليم والخبرات والمشاريع',
//               Icons.delete_forever,
//               _deleteAllPortfolioData,
//             ),
//             SizedBox(height: 8),
//             _buildDangerAction(
//               'إخفاء الحساب مؤقتاً',
//               'جعل حسابك غير مرئي مؤقتاً دون حذفه',
//               Icons.visibility_off,
//               _temporaryHideAccount,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDangerAction(String title, String description, IconData icon, VoidCallback onPressed) {
//     return OutlinedButton(
//       onPressed: onPressed,
//       style: OutlinedButton.styleFrom(
//         foregroundColor: AppColors.error,
//         side: BorderSide(color: AppColors.error),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         padding: EdgeInsets.all(16),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: AppColors.error),
//           SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                   ),
//                 ),
//                 Text(
//                   description,
//                   style: TextStyle(fontSize: 12),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _saveSettings() async {
//     try {
//       isSaving.value = true;
      
//       String? userId = _authService.currentUserId;
//       if (userId == null) return;

//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userId)
//           .update({
//         'portfolioPrivacy': selectedPrivacy.value,
//         'showEmail': showEmail.value,
//         'showPhone': showPhone.value,
//         'allowFriendRequests': allowFriendRequests.value,
//         'showOnlineStatus': showOnlineStatus.value,
//         'allowMessagesFromStrangers': allowMessagesFromStrangers.value,
//         'allowTagging': allowTagging.value,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });

//       Get.snackbar(
//         'تم',
//         'تم حفظ إعدادات الخصوصية بنجاح',
//         backgroundColor: AppColors.success.withOpacity(0.1),
//         colorText: AppColors.success,
//       );
      
//     } catch (e) {
//       Get.snackbar('خطأ', 'فشل حفظ الإعدادات: ${e.toString()}');
//     } finally {
//       isSaving.value = false;
//     }
//   }

//   void _deleteAllPortfolioData() {
//     Get.dialog(
//       AlertDialog(
//         title: Text(
//           'تحذير!',
//           style: TextStyle(color: AppColors.error),
//         ),
//         content: Text(
//           'هل أنت متأكد من حذف جميع بيانات الملف الشخصي؟\n\n'
//           'سيتم حذف:\n'
//           '• جميع معلومات التعليم\n'
//           '• جميع الخبرات المهنية\n'
//           '• جميع المشاريع\n'
//           '• جميع المهارات\n'
//           '• جميع الشهادات\n\n'
//           'هذا الإجراء لا يمكن التراجع عنه!',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Get.back();
//               _confirmDeleteAllData();
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
//             child: Text('حذف', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _confirmDeleteAllData() {
//     Get.dialog(
//       AlertDialog(
//         title: Text('تأكيد الحذف'),
//         content: Text(
//           'اكتب "أريد الحذف" للتأكيد:',
//         ),
//         actions: [
//           TextField(
//             onChanged: (value) {
//               // يمكن إضافة منطق للتحقق من النص المدخل
//             },
//             decoration: InputDecoration(
//               hintText: 'أريد الحذف',
//               border: OutlineInputBorder(),
//             ),
//           ),
//           SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               TextButton(
//                 onPressed: () => Get.back(),
//                 child: Text('إلغاء'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   Get.back();
//                   _performDeleteAllData();
//                 },
//                 style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
//                 child: Text('حذف نهائي', style: TextStyle(color: Colors.white)),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _performDeleteAllData() async {
//     try {
//       // هنا يجب إضافة منطق حذف جميع البيانات
//       Get.snackbar(
//         'تم',
//         'تم حذف جميع بيانات الملف الشخصي',
//         backgroundColor: AppColors.success.withOpacity(0.1),
//         colorText: AppColors.success,
//       );
//     } catch (e) {
//       Get.snackbar