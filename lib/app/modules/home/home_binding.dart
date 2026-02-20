import 'package:firebase_auth_demo/app/data/repository/auth_repository.dart';
import 'package:get/get.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController(Get.find<AuthRepository>()));
  }
}
