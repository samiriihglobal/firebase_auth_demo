import 'package:firebase_auth_demo/app/modules/auth/signup/signup_controller.dart';
import 'package:get/get.dart';
import '../../data/provider/auth_provider.dart';
import '../../data/repository/auth_repository.dart';
import 'login/login_controller.dart';

class AuthenticationBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthProvider>(() => AuthProvider());
    Get.lazyPut<AuthRepository>(() => AuthRepository(Get.find()));
    Get.lazyPut<LoginController>(() => LoginController(Get.find()));
    Get.lazyPut<SignupController>(() => SignupController(Get.find()));
  }
}
