import 'package:get/get.dart';
import '../../../data/repository/auth_repository.dart';

class LoginController extends GetxController {
  final AuthRepository _repository;

  LoginController(this._repository);

  final email = ''.obs;
  final password = ''.obs;
  final isLoading = false.obs;

  void login() async {
    final userEmail = email.value.trim();
    final userPassword = password.value.trim();

    if (userEmail.isEmpty && userPassword.isEmpty) {
      Get.snackbar("Error", "Please enter your email and password.");
      return;
    } else if (userEmail.isEmpty) {
      Get.snackbar("Error", "Please enter your email.");
      return;
    } else if (userPassword.isEmpty) {
      Get.snackbar("Error", "Please enter your password.");
      return;
    }

    if (!GetUtils.isEmail(userEmail)) {
      Get.snackbar("Error", "Please enter a valid email.");
      return;
    }

    try {
      isLoading.value = true;
      await _repository.login(userEmail, userPassword);
      Get.offAllNamed('/home');
    } catch (e) {
      String errorMessage = "Login failed. Please try again.";
      if (e.toString().contains("user-not-found")) {
        errorMessage = "No user found with this email.";
      } else if (e.toString().contains("wrong-password")) {
        errorMessage = "Incorrect password.";
      }
      Get.snackbar("Login Failed", errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  void forgotPassword() async {
    final userEmail = email.value.trim();

    if (userEmail.isEmpty) {
      Get.snackbar("Missing Email", "Please enter your email first.");
      return;
    }

    if (!GetUtils.isEmail(userEmail)) {
      Get.snackbar("Invalid Email", "Please enter a valid email address.");
      return;
    }

    try {
      await _repository.forgotPassword(userEmail);
      Get.snackbar(
        "Reset Email Sent",
        "Check your inbox for password reset instructions.",
      );
    } catch (e) {
      String errorMessage = "Unable to send reset email. Please try again.";
      if (e.toString().contains("user-not-found")) {
        errorMessage = "No user found with this email.";
      } else if (e.toString().contains("invalid-email")) {
        errorMessage = "The email address is invalid.";
      }
      Get.snackbar("Reset Failed", errorMessage);
    }
  }

  void goToSignup() {
    Get.toNamed('/signup');
  }
}
