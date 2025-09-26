import 'package:get/get.dart';

import 'base_posts_controller.dart';
import '../../../services/auth_service.dart';

class UniversityPostsController extends BasePostsController {
  @override
  String get filterKey => 'university';

  @override
  Map<String, dynamic> get filterParams {
    final currentUser = Get.find<AuthService>().appUser.value;
    return {
      'status': 'active',
      'audience': 'university',
      'authorUniversity': currentUser?.university,
    };
  }
}