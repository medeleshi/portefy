import 'package:get/get.dart';
import 'package:portefy/app/modules/notifications/views/notifications_view.dart';
import '../modules/portfolio/views/add_portfolio_item.dart';
import '../modules/posts/bindings/post_binding.dart';
import '../modules/search/bindings/search_binding.dart';
import '../modules/search/views/search_view.dart';
import '../modules/settings/views/contact_view.dart';
import '../modules/settings/views/edit_profile_view.dart';
import '../modules/settings/views/notifications_settings_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/auth/views/forgot_password_view.dart';
import '../modules/auth/views/user_info_view.dart';
import '../modules/main/bindings/main_binding.dart';
import '../modules/main/views/main_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/posts/views/add_post_view.dart';
import '../modules/posts/views/edit_post_view.dart';
import '../modules/posts/views/post_details_view.dart';
import '../modules/posts/views/comments_view.dart';
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/portfolio/bindings/portfolio_binding.dart';
import '../modules/portfolio/views/portfolio_view.dart';
import '../modules/gamification/bindings/gamification_binding.dart';
import '../modules/gamification/views/gamification_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/settings/views/about_view.dart';
import '../modules/settings/views/faq_view.dart';

import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.ONBOARDING,
      page: () => OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.FORGOT_PASSWORD,
      page: () => ForgotPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.USER_INFO,
      page: () => UserInfoView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.MAIN,
      page: () => MainView(),
      binding: MainBinding(),
      bindings: [HomeBinding(), NotificationsBinding()],
    ),
    GetPage(
      name: AppRoutes.SEARCH,
      page: () => SearchView(),
      binding: SearchBinding(),
      fullscreenDialog: true,
    ),
    GetPage(
      name: AppRoutes.NOTIFICATIONS,
      page: () => NotificationsView(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: AppRoutes.ADD_POST,
      page: () => AddPostView(),
      binding: PostsBinding(),
      fullscreenDialog: true,
    ),
    GetPage(
      name: AppRoutes.EDIT_POST,
      page: () => EditPostView(),
      binding: PostsBinding(),
      fullscreenDialog: true,
    ),
    GetPage(
      name: AppRoutes.POST_DETAILS,
      page: () => PostDetailsView(),
      binding: PostsBinding(),
      fullscreenDialog: true,
    ),
    GetPage(
      name: AppRoutes.COMMENTS,
      page: () => CommentsView(),
      binding: PostsBinding(),
      fullscreenDialog: true,
    ),
    GetPage(
      name: AppRoutes.PORTFOLIO,
      page: () => PortfolioView(),
      binding: PortfolioBinding(),
    ),
    
    GetPage(
      name: AppRoutes.ADD_PORTFOLIO_ITEM,
      page: () => AddPortfolioItemView(),
      binding: PortfolioBinding(),
      fullscreenDialog: true,
    ),
    // GetPage(
    //   name: AppRoutes.EDIT_PORTFOLIO_ITEM,
    //   page: () => EditPortfolioItemView(),
    //   binding: PortfolioBinding(),
    //   fullscreenDialog: true,
    // ),
    // GetPage(
    //   name: AppRoutes.CV_TEMPLATES,
    //   page: () => CvTemplatesView(),
    //   binding: PortfolioBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.CV_PREVIEW,
    //   page: () => CvPreviewView(),
    //   binding: PortfolioBinding(),
    // ),
    GetPage(
      name: AppRoutes.GAMIFICATION,
      page: () => GamificationView(),
      binding: GamificationBinding(),
    ),
    GetPage(
      name: AppRoutes.EDIT_PROFILE,
      page: () => EditProfileView(),
      binding: SettingsBinding(),
    ),
    // Settings Routes
    GetPage(
      name: AppRoutes.SETTINGS,
      page: () => SettingsView(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.NOTIFICATIONS_SETTINGS,
      page: () => NotificationsSettingsView(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
    ),
    // GetPage(
    //   name: AppRoutes.PRIVACY_SETTINGS,
    //   page: () => PrivacySettingsView(),
    //   binding: SettingsBinding(),
    //   transition: Transition.rightToLeft,
    //   transitionDuration: Duration(milliseconds: 300),
    // ),
    // GetPage(
    //   name: AppRoutes.THEME_SETTINGS,
    //   page: () => ThemeSettingsView(),
    //   binding: SettingsBinding(),
    //   transition: Transition.rightToLeft,
    //   transitionDuration: Duration(milliseconds: 300),
    // ),
    // GetPage(
    //   name: AppRoutes.ACCOUNT_SETTINGS,
    //   page: () => AccountSettingsView(),
    //   binding: SettingsBinding(),
    //   transition: Transition.rightToLeft,
    //   transitionDuration: Duration(milliseconds: 300),
    // ),
    // GetPage(
    //   name: AppRoutes.DATA_SETTINGS,
    //   page: () => DataSettingsView(),
    //   binding: SettingsBinding(),
    //   transition: Transition.rightToLeft,
    //   transitionDuration: Duration(milliseconds: 300),
    // ),

    // Support Routes
    // GetPage(
    //   name: AppRoutes.HELP,
    //   page: () => HelpView(),
    //   binding: SupportBinding(),
    //   transition: Transition.rightToLeft,
    //   transitionDuration: Duration(milliseconds: 300),
    // ),
    GetPage(
      name: AppRoutes.FAQ,
      page: () => FAQView(),
      // binding: SupportBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.CONTACT_SUPPORT,
      page: () => ContactView(),
      // binding: SupportBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.ABOUT,
      page: () => AboutView(),
      // binding: SupportBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
    ),
    // GetPage(
    //   name: AppRoutes.PRIVACY_POLICY,
    //   page: () => PrivacySettingsView(),
    //   // binding: SupportBinding(),
    //   transition: Transition.rightToLeft,
    //   transitionDuration: Duration(milliseconds: 300),
    // ),
    // GetPage(
    //   name: AppRoutes.TERMS_OF_SERVICE,
    //   page: () => TermsOfServiceView(),
    //   binding: SupportBinding(),
    //   transition: Transition.rightToLeft,
    //   transitionDuration: Duration(milliseconds: 300),
    // ),

    // Error handling
    // unknownRoute: GetPage(
    //   name: '/not-found',
    //   page: () => NotFoundPage(),
    // ),
  ];
}
