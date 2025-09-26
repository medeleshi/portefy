import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:portefy/app/modules/gamification/controllers/gamification_controller.dart';
import 'package:portefy/app/modules/portfolio/controllers/portfolio_controller.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/services/auth_service.dart';
import 'app/services/fcm_service.dart';
import 'app/services/notification_service.dart';
import 'app/services/theme_service.dart';
import 'app/theme/app_theme.dart';

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  await FcmService.initNotifications();

  // تجيب التوكن وقت اللوجين/الابدا
  String? token = await FcmService.getTokenWithRetry();
  debugPrint("FCM Token at start: $token");
  
  // Initialize FCM background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Initialize Services
  await initServices();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(MyApp());
}

Future<void> initServices() async {
  Get.put(AuthService());
  Get.put(NotificationService());
  Get.put(ThemeService());
  Get.put(GamificationController());
  Get.put(PortfolioController());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Portefy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      locale: Locale('ar', 'TN'),
      fallbackLocale: Locale('en', 'US'),
      initialRoute: AppRoutes.SPLASH,
      getPages: AppPages.routes,
      // Builder for global configurations
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1.0), // Prevent font scaling
          ),
          child: child!,
        );
      },
    );
  }
}