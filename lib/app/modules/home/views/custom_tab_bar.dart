// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/home_controller.dart';

// class CustomTabBar extends GetView<HomeController> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Get.theme.colorScheme.surface,
//         border: Border(bottom: BorderSide(color: Get.theme.dividerColor)),
//       ),
//       height: 48,
//       child: Row(
//         children: List.generate(controller.tabTitles.length, (index) {
//           return Expanded(
//             child: Obx(() => InkWell(
//               onTap: () => controller.changeTab(index),
//               child: Container(
//                 decoration: BoxDecoration(
//                   border: Border(
//                     bottom: BorderSide(
//                       color: controller.currentTabIndex.value == index
//                           ? Get.theme.colorScheme.primary
//                           : Colors.transparent,
//                       width: 2,
//                     ),
//                   ),
//                 ),
//                 child: Center(
//                   child: Text(
//                     controller.tabTitles[index],
//                     style: Get.textTheme.bodyMedium?.copyWith(
//                       color: controller.currentTabIndex.value == index
//                           ? Get.theme.colorScheme.primary
//                           : Get.theme.colorScheme.onSurface.withOpacity(0.6),
//                       fontWeight: controller.currentTabIndex.value == index
//                           ? FontWeight.bold
//                           : FontWeight.normal,
//                     ),
//                   ),
//                 ),
//               ),
//             )),
//           );
//         }),
//       ),
//     );
//   }
// }