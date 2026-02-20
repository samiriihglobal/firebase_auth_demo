import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'signup_controller.dart';

class SignupPage extends GetView<SignupController> {
  SignupPage({super.key});

  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: InkWell(onTap: (){
          Get.back();
        },child: Icon(Icons.arrow_back_ios,color: colors.secondary,)),
        title: Text('Sign Up',style: textTheme.headlineMedium,),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  /// Title
                  Text(
                    "Create Account",
                    style: textTheme.headlineMedium,
                  ),

                  const SizedBox(height: 24),

                  /// Username
                  TextField(
                    onChanged: (v) => controller.username.value = v,
                    decoration: const InputDecoration(
                      labelText: "Username",
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Email
                  TextField(
                    onChanged: (v) => controller.email.value = v,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Password
                  Obx(() => TextField(
                    onChanged: (v) => controller.password.value = v,
                    obscureText: !isPasswordVisible.value,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: isPasswordVisible.toggle,
                      ),
                    ),
                  )),

                  const SizedBox(height: 16),

                  /// Confirm Password
                  Obx(() => TextField(
                    onChanged: (v) =>
                    controller.confirmPassword.value = v,
                    obscureText: !isConfirmPasswordVisible.value,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      prefixIcon:
                      const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isConfirmPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed:
                        isConfirmPasswordVisible.toggle,
                      ),
                    ),
                  )),

                  const SizedBox(height: 24),

                  /// Sign Up Button
                  Obx(() => controller.isLoading.value
                      ? const CircularProgressIndicator()
                      : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.signup,
                      child: const Text("Sign Up"),
                    ),
                  )),

                  const SizedBox(height: 16),

                  /// Login Redirect
                  TextButton(
                    onPressed: controller.goToLogin,
                    child: Text(
                      "Already have an account? Login",
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
