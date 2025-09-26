import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/theme_service.dart';
import '../theme/app_theme.dart';

class ThemeToggleWidget extends StatelessWidget {
  final bool showLabel;
  final MainAxisSize mainAxisSize;

  const ThemeToggleWidget({
    Key? key,
    this.showLabel = true,
    this.mainAxisSize = MainAxisSize.min,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    
    return Obx(() => Row(
          mainAxisSize: mainAxisSize,
          children: [
            Icon(
              Icons.light_mode,
              size: 20,
              color: themeService.isDarkMode.value 
                  ? AppTheme.getCurrentTextSecondaryColor()
                  : AppTheme.getCurrentPrimaryColor(),
            ),
            
            SizedBox(width: 8),
            
            Switch(
              value: themeService.isDarkMode.value,
              onChanged: (value) => themeService.toggleTheme(),
              activeColor: AppTheme.getCurrentPrimaryColor(),
            ),
            
            SizedBox(width: 8),
            
            Icon(
              Icons.dark_mode,
              size: 20,
              color: themeService.isDarkMode.value 
                  ? AppTheme.getCurrentPrimaryColor()
                  : AppTheme.getCurrentTextSecondaryColor(),
            ),
            
            if (showLabel) ...[
              SizedBox(width: 12),
              Text(
                themeService.currentThemeName,
                style: TextStyle(
                  color: AppTheme.getCurrentTextPrimaryColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ));
  }
}

class ThemeToggleListTile extends StatelessWidget {
  const ThemeToggleListTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    
    return Obx(() => ListTile(
          leading: Icon(
            themeService.isDarkMode.value ? Icons.dark_mode : Icons.light_mode,
            color: AppTheme.getCurrentPrimaryColor(),
          ),
          title: Text(
            'المظهر',
            style: TextStyle(
              color: AppTheme.getCurrentTextPrimaryColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            themeService.currentThemeName,
            style: TextStyle(color: AppTheme.getCurrentTextSecondaryColor()),
          ),
          trailing: ThemeToggleWidget(showLabel: false),
          onTap: () => themeService.toggleTheme(),
        ));
  }
}

class ThemeSelectionDialog extends StatelessWidget {
  const ThemeSelectionDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    
    return AlertDialog(
      backgroundColor: AppTheme.getCurrentSurfaceColor(),
      title: Text(
        'اختيار المظهر',
        style: TextStyle(
          color: AppTheme.getCurrentTextPrimaryColor(),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() => RadioListTile<bool>(
                title: Row(
                  children: [
                    Icon(Icons.light_mode, 
                         color: AppTheme.getCurrentPrimaryColor()),
                    SizedBox(width: 8),
                    Text(
                      'فاتح',
                      style: TextStyle(
                        color: AppTheme.getCurrentTextPrimaryColor(),
                      ),
                    ),
                  ],
                ),
                value: false,
                groupValue: themeService.isDarkMode.value,
                onChanged: (value) => themeService.setTheme(false),
                activeColor: AppTheme.getCurrentPrimaryColor(),
              )),
          
          Obx(() => RadioListTile<bool>(
                title: Row(
                  children: [
                    Icon(Icons.dark_mode, 
                         color: AppTheme.getCurrentPrimaryColor()),
                    SizedBox(width: 8),
                    Text(
                      'داكن',
                      style: TextStyle(
                        color: AppTheme.getCurrentTextPrimaryColor(),
                      ),
                    ),
                  ],
                ),
                value: true,
                groupValue: themeService.isDarkMode.value,
                onChanged: (value) => themeService.setTheme(true),
                activeColor: AppTheme.getCurrentPrimaryColor(),
              )),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'تم',
            style: TextStyle(color: AppTheme.getCurrentPrimaryColor()),
          ),
        ),
      ],
    );
  }
}

class AnimatedThemeButton extends StatelessWidget {
  final double size;
  final bool showTooltip;

  const AnimatedThemeButton({
    Key? key,
    this.size = 24,
    this.showTooltip = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    
    return Obx(() => AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: IconButton(
            key: ValueKey(themeService.isDarkMode.value),
            icon: AnimatedRotation(
              turns: themeService.isDarkMode.value ? 0.5 : 0,
              duration: Duration(milliseconds: 300),
              child: Icon(
                themeService.isDarkMode.value 
                    ? Icons.light_mode 
                    : Icons.dark_mode,
                size: size,
                color: AppTheme.getCurrentPrimaryColor(),
              ),
            ),
            tooltip: showTooltip 
                ? 'التبديل إلى المظهر ${themeService.oppositeThemeName}'
                : null,
            onPressed: () => themeService.toggleTheme(),
          ),
        ));
  }
}