import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/theme_toggle_widget.dart';
import '../../home/views/home_view.dart';
import '../../portfolio/views/portfolio_view.dart';
import '../controllers/main_controller.dart';

class MainView extends GetView<MainController> {
  final List<Widget> _pages = [HomeView(), PortfolioView()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getCurrentBackgroundColor(),
      body: Obx(
        () => IndexedStack(
          index: controller.selectedIndex.value >= _pages.length
              ? 0 // Fallback to first page if index is out of bounds
              : controller.selectedIndex.value,
          children: _pages,
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomAppBar(
          color: AppTheme.getCurrentSurfaceColor(),
          elevation: 8,
          notchMargin: 8.0,
          shape: CircularNotchedRectangle(),
          child: Container(
            height: 65,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Home Tab
                Expanded(
                  child: InkWell(
                    onTap: () => controller.changeIndex(0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          controller.selectedIndex.value == 0
                              ? Icons.home
                              : Icons.home_outlined,
                          size: 24,
                          color: controller.selectedIndex.value == 0
                              ? AppTheme.getCurrentPrimaryColor()
                              : AppTheme.getCurrentTextSecondaryColor(),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'الرئيسية',
                          style: TextStyle(
                            fontSize: 10,
                            color: controller.selectedIndex.value == 0
                                ? AppTheme.getCurrentPrimaryColor()
                                : AppTheme.getCurrentTextSecondaryColor(),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),

                // Empty space for FAB
                SizedBox(width: 80),

                // Portfolio Tab
                Expanded(
                  child: InkWell(
                    onTap: () => controller.changeIndex(1),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          controller.selectedIndex.value == 1
                              ? Icons.person
                              : Icons.person_outline,
                          size: 24,
                          color: controller.selectedIndex.value == 1
                              ? AppTheme.getCurrentPrimaryColor()
                              : AppTheme.getCurrentTextSecondaryColor(),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'ملفي',
                          style: TextStyle(
                            fontSize: 10,
                            color: controller.selectedIndex.value == 1
                                ? AppTheme.getCurrentPrimaryColor()
                                : AppTheme.getCurrentTextSecondaryColor(),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 48,
        height: 48,
        child: FloatingActionButton(
          heroTag: 'fab_main_page',
          onPressed: () => Get.toNamed(AppRoutes.ADD_POST),
          backgroundColor: AppColors.accent,
          elevation: 0,
          mini: true,
          child: Icon(Icons.add, color: Colors.white, size: 20),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
