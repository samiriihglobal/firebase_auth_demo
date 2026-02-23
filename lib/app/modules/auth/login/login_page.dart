import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart';

class LoginPage extends GetView<LoginController> {
  LoginPage({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool isPasswordVisible = false.obs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      // ✅ No hardcoded background
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [

                /// 🔵 Logo
                Icon(
                  Icons.lightbulb_circle_rounded,
                  size: 100,
                  color: colors.primary, // ✅ From theme
                ),

                const SizedBox(height: 24),

                /// 🧾 Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  // ❌ removed hardcoded white
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        /// ✨ Heading
                        Text(
                          'Welcome Back!',
                          style: textTheme.headlineMedium,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Login to your account',
                          style: textTheme.bodyMedium,
                        ),

                        const SizedBox(height: 24),

                        /// 📧 Email
                        TextField(
                          controller: emailController,
                          onChanged: (v) => controller.email.value = v,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// 🔒 Password
                        Obx(() => TextField(
                          controller: passwordController,
                          onChanged: (v) =>
                          controller.password.value = v,
                          obscureText: !isPasswordVisible.value,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon:
                            const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed:
                              isPasswordVisible.toggle,
                            ),
                          ),
                        )),

                        /// 🔗 Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: controller.forgotPassword,
                            child: Text(
                              'Forgot Password?',
                              style: textTheme.bodyMedium,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// 🔘 Login Button
                        Obx(() => controller.isLoading.value
                            ? const CircularProgressIndicator()
                            : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.login,
                            // ✅ No manual style
                            child: const Text('Login'),
                          ),
                        )),

                        const SizedBox(height: 16),

                        /// 👤 Sign Up
                        TextButton(
                          onPressed: controller.goToSignup,
                          child: Text(
                            "Don't have an account? Sign up",
                            style: textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
