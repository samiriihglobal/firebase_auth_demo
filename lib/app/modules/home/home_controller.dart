import 'package:firebase_auth_demo/app/data/repository/auth_repository.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final AuthRepository _repository;

  HomeController(this._repository);

  final username = ''.obs;
  RxString profilePicture = ''.obs;
  RxString cubeOfTheDay = 'Solve a 3x3 in under 30 seconds!'.obs;

  @override
  void onInit() {
    super.onInit();
    // Load current user info if needed
    final user = _repository.currentUser;
    if (user != null) {
      username.value = user.displayName ?? user.email ?? 'User';
    }
  }

  void logout() async {
    await _repository.logout();
    Get.offAllNamed('/login');
  }
}
