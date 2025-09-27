import 'package:get/get.dart';
import 'en_US.dart';
import 'ar_AR.dart';
import 'fr_FR.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': en_US,
    'ar_AR': ar_AR,
    'fr_FR': fr_FR,
  };
}
