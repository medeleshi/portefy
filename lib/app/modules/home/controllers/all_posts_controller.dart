import 'base_posts_controller.dart';

class AllPostsController extends BasePostsController {
  @override
  String get filterKey => 'all';

  @override
  Map<String, dynamic> get filterParams => {
    'status': 'active',
    'audience': 'public'
  };
}