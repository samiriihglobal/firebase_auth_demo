
import 'package:firebase_auth_demo/app/core/translations/en_US/en_us_translations.dart';
import 'package:firebase_auth_demo/app/core/translations/vi_VN/vi_vn_translations.dart' show viVn;

/**
 * GetX Template Generator - fb.com/htngu.99
 * */

abstract class AppTranslation {
  static Map<String, Map<String, String>> translations = {
    'en': enUs,
    'vi': viVn,
  };
}