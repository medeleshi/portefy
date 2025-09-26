import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/all_posts_controller.dart';
import '../controllers/university_posts_controller.dart';
import '../controllers/major_posts_controller.dart';
import '../controllers/level_posts_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Main home controller
    Get.lazyPut<HomeController>(() => HomeController());
    
    // Tab controllers - these are created with tags in HomeController.onInit()
    // but we can also prepare them here if needed
    Get.lazyPut<AllPostsController>(() => AllPostsController(), tag: 'all');
    Get.lazyPut<UniversityPostsController>(() => UniversityPostsController(), tag: 'university');
    Get.lazyPut<MajorPostsController>(() => MajorPostsController(), tag: 'major');
    Get.lazyPut<LevelPostsController>(() => LevelPostsController(), tag: 'level');
  }
}