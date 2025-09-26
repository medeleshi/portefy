import 'package:get/get.dart';
import '../../../services/pagination_service.dart';
import '../../../services/post_service.dart';
import '../controllers/base_portfolio_controller.dart';
import '../controllers/portfolio_controller.dart';
import '../controllers/portfolio_routing_controller.dart';
import '../controllers/public_base_controller.dart';
import '../controllers/user_post_controller.dart';

class PortfolioBinding extends Bindings {
  @override
  void dependencies() {
    // Portfolio Controllers
    // Get.lazyPut(() => UserPostController());
    Get.lazyPut(() => EducationController());
    Get.lazyPut(() => ExperienceController());
    Get.lazyPut(() => ProjectsController());
    Get.lazyPut(() => SkillsController());
    Get.lazyPut(() => LanguagesController());
    Get.lazyPut(() => CertificatesController());
    Get.lazyPut(() => ActivitiesController());
    Get.lazyPut(() => HobbiesController());
    
    
    // Services
    Get.lazyPut(() => UserService());
    Get.lazyPut(() => PaginationService());
    Get.lazyPut(() => FriendshipService());
    Get.lazyPut(() => PostService()); // إضافة Post Service
  }
}