import 'package:get/get.dart';

import 'base_posts_controller.dart';
import '../../../services/auth_service.dart';

class MajorPostsController extends BasePostsController {
  @override
  String get filterKey => 'major';

  @override
  Map<String, dynamic> get filterParams {
    final currentUser = Get.find<AuthService>().appUser.value;
    return {
      'status': 'active',
      'audience': 'major',
      'authorUniversity': currentUser?.university,
      'authorMajor': currentUser?.major,
    };
  }
}