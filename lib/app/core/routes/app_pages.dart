import 'package:firebase_auth_demo/app/modules/auth/authentication_bindings.dart';
import 'package:firebase_auth_demo/app/modules/auth/login/login_page.dart';
import 'package:firebase_auth_demo/app/modules/auth/signup/signup_page.dart';
import 'package:firebase_auth_demo/app/modules/home/home_binding.dart';
import 'package:firebase_auth_demo/app/modules/home/home_page.dart';
import 'package:get/get.dart';
import 'app_routes.dart';

class AppPages {
  static const INITIAL = AppRoutes.LOGIN;

  static final routes = [
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => LoginPage(),
      binding: AuthenticationBindings(),
    ),
    GetPage(
      name: AppRoutes.SIGNUP,
      page: () => SignupPage(),
      binding: AuthenticationBindings(),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => HomePage(),
      binding: HomeBinding(),
    ),
  ];
}
