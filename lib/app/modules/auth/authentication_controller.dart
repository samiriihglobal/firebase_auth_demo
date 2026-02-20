import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_demo/app/data/repository/auth_repository.dart';
import 'package:get/get.dart';
/**
 * GetX Template Generator - fb.com/htngu.99
 * */

class AuthenticationController extends GetxController {
  final AuthRepository _repository;

  AuthenticationController(this._repository);

  final email = ''.obs;
  final password = ''.obs;
  final isLoading = false.obs;

  void login() async {
    // Trim spaces
    final userEmail = email.value.trim();
    final userPassword = password.value.trim();

    // Edge case checks
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

    // Optional: check for valid email format
    if (!GetUtils.isEmail(userEmail)) {
      Get.snackbar("Error", "Please enter a valid email address.");
      return;
    }
    // Optional: check for password length
    if (userPassword.length < 6){
      Get.snackbar("Error", "Password must be at least 6 characters long.");
      return;
    }

    try {
      isLoading.value = true;
      await _repository.login(userEmail, userPassword);
      Get.offAllNamed('/home');
    } on FirebaseAuthException catch (e) {
      // Firebase throws generic error, map to user-friendly messages
      String errorMessage = "Login failed. Please try again.";
      if (e.toString().contains("user-not-found")) {
        errorMessage = "No user found with this email.";
      } else if (e.toString().contains("wrong-password")) {
        errorMessage = "Incorrect password. Try again.";
      } else if (e.toString().contains("invalid-email")) {
        errorMessage = "Email is invalid. Check spelling.";
      }
      Get.snackbar("Login Failed", errorMessage);
    } finally {
      isLoading.value = false;
    }
  }


  void register() async {
    try {
      isLoading.value = true;
      await _repository.register(email.value, password.value);
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar("Registration Failed", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    await _repository.logout();
    Get.offAllNamed('/login');
  }
}