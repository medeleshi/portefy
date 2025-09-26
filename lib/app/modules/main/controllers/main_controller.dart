import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class MainController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  final List<BottomNavItem> navItems = [
    BottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'الرئيسية',
      route: AppRoutes.HOME,
    ),
    BottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'الملف الشخصي',
      route: AppRoutes.PORTFOLIO,
    ),
  ];

  void changeIndex(int index) {
    // Only allow valid indices (0 for Home, 1 for Portfolio)
    if (index >= 0 && index < navItems.length) {
      selectedIndex.value = index;
    }
  }

  String get currentRoute {
    return navItems[selectedIndex.value].route;
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}