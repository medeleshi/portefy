import 'package:get/get.dart';

import 'base_posts_controller.dart';
import '../../../services/auth_service.dart';

class LevelPostsController extends BasePostsController {
  @override
  String get filterKey => 'level';

  @override
  Map<String, dynamic> get filterParams {
    final currentUser = Get.find<AuthService>().appUser.value;
    return {
      'status': 'active',
      'audience': 'level',
      'authorUniversity': currentUser?.university,
      'authorMajor': currentUser?.major,
      'authorLevel': currentUser?.level,
    };
  }
}
