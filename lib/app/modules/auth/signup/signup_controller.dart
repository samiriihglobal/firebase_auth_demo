import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/repository/auth_repository.dart';
import 'package:flutter/material.dart';

class SignupController extends GetxController {
  final AuthRepository _repository;

  SignupController(this._repository);

  final username = ''.obs;
  final email = ''.obs;
  final password = ''.obs;
  final confirmPassword = ''.obs;
  final isLoading = false.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Timer? _emailCheckTimer;
  int _elapsedSeconds = 0;

  void signup() async {
    final userNameVal = username.value.trim();
    final userEmail = email.value.trim();
    final userPassword = password.value.trim();
    final userConfirm = confirmPassword.value.trim();

    // 🔹 Validation
    if (userNameVal.isEmpty ||
        userEmail.isEmpty ||
        userPassword.isEmpty ||
        userConfirm.isEmpty) {
      Get.snackbar("Error", "All fields are required.");
      return;
    }

    if (!GetUtils.isEmail(userEmail)) {
      Get.snackbar("Error", "Enter a valid email.");
      return;
    }

    if (userPassword.length < 6) {
      Get.snackbar("Error", "Password must be at least 6 characters.");
      return;
    }

    if (userPassword != userConfirm) {
      Get.snackbar("Error", "Passwords do not match.");
      return;
    }

    try {
      isLoading.value = true;

      // 1️⃣ Register user
      final userCredential =
      await _repository.register(userEmail, userPassword);
      final user = userCredential.user;
      if (user == null) throw Exception("Failed to register user.");

      // 2️⃣ Send verification email
      await user.sendEmailVerification();

      // 3️⃣ Show dialog: verification email sent
      Get.defaultDialog(
        title: "Verify your Email",
        middleText:
        "A verification email has been sent to ${user.email}. Please check your inbox.",
        textConfirm: "OK",
        onConfirm: () {
          Get.back(); // close dialog
          _startEmailVerificationPolling(user, userNameVal);
        },
      );
    } catch (e) {
      String errorMessage = "Signup failed. Try again.";
      if (e.toString().contains("email-already-in-use")) {
        errorMessage = "Email is already registered.";
      }
      Get.snackbar("Signup Failed", errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  void _startEmailVerificationPolling(User user, String usernameVal) {
    _elapsedSeconds = 0;
    print("🔹 Starting email verification polling...");

    // Show progress dialog
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text("Waiting for Verification"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text("Checking your email verification..."),
              SizedBox(height: 20),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    _emailCheckTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) async {
          _elapsedSeconds += 5;
          print("⏱ Polling email verification: ${_elapsedSeconds}s elapsed");

          try {
            User? freshUser = FirebaseAuth.instance.currentUser;
            await freshUser?.reload();
            freshUser = FirebaseAuth.instance.currentUser;
            print("🔄 User info refreshed. emailVerified = ${freshUser?.emailVerified}");

            if (freshUser != null && freshUser.emailVerified) {
              print("✅ User email verified!");
              timer.cancel();
              Get.back(); // close progress dialog
              print("🟢 Progress dialog closed");

              // 🔹 Store in Firestore BEFORE navigation
              try {
                // Store in Firestore
                await _firestore.collection('users').doc(freshUser.uid).set({
                  'userId': freshUser.uid,
                  'username': usernameVal,
                  'email': freshUser.email,
                  'dateJoined': DateTime.now().millisecondsSinceEpoch,
                  'profilePicture': '',
                  'progressLevel': 1,
                });
                print("💾 User data stored in Firestore");

                Get.back();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Get.snackbar("Success", "Email verified and account created!");
                  Get.offAllNamed('/home'); // navigate after snackbar
                });

              } catch (e) {
                print("❌ Failed to store user data: $e");
                Get.snackbar("Error", "Failed to store user data: $e");
              }
            } else if (_elapsedSeconds >= 600) {
              print("⏳ Email verification timeout reached");
              timer.cancel();
              Get.back(); // close progress dialog
              Get.snackbar(
                "Timeout",
                "Email verification not detected. You can try resending the email.",
              );
            }
          } catch (e) {
            print("❌ Error while polling email verification: $e");
          }
        });
  }

  @override
  void onClose() {
    _emailCheckTimer?.cancel();
    super.onClose();
  }

  void goToLogin() {
    Get.back();
  }
}
