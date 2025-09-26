import 'package:get/get.dart';
import '../controllers/gamification_controller.dart';

class GamificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GamificationController>(() => GamificationController());
  }
}