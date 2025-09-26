import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends GetxService {
  static ThemeService get instance => Get.find();

  final RxBool isDarkMode = false.obs;
  final String _themeKey = 'theme_mode';

  @override
  void onInit() {
    super.onInit();
    loadThemeFromPrefs();
  }

  // Load theme from SharedPreferences
  Future<void> loadThemeFromPrefs() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool savedTheme = prefs.getBool(_themeKey) ?? false;
      isDarkMode.value = savedTheme;
      Get.changeThemeMode(savedTheme ? ThemeMode.dark : ThemeMode.light);
    } catch (e) {
      print('خطأ في تحميل المظهر: $e');
    }
  }

  // Save theme to SharedPreferences
  Future<void> saveThemeToPrefs(bool isDark) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, isDark);
    } catch (e) {
      print('خطأ في حفظ المظهر: $e');
    }
  }

  // Toggle theme
  Future<void> toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    await saveThemeToPrefs(isDarkMode.value);
  }

  // Set specific theme
  Future<void> setTheme(bool isDark) async {
    isDarkMode.value = isDark;
    Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
    await saveThemeToPrefs(isDark);
  }

  // Get current theme name
  String get currentThemeName => isDarkMode.value ? 'داكن' : 'فاتح';
  
  // Get opposite theme name
  String get oppositeThemeName => isDarkMode.value ? 'فاتح' : 'داكن';
}