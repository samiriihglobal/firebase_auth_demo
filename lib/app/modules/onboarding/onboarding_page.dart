import 'package:firebase_auth_demo/app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pages = [
      _OnboardingData(
        icon: Icons.security,
        title: 'Secure Sign In',
        description:
            'Authenticate quickly and safely with Firebase-powered login.',
      ),
      _OnboardingData(
        icon: Icons.person_add_alt_1,
        title: 'Easy Registration',
        description:
            'Create your account in seconds and start exploring features.',
      ),
      _OnboardingData(
        icon: Icons.dashboard_customize,
        title: 'Get Started Fast',
        description: 'Access your personalized home experience right away.',
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    final item = pages[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item.icon, size: 100, color: theme.colorScheme.primary),
                        const SizedBox(height: 24),
                        Text(
                          item.title,
                          style: theme.textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.description,
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _finishOnboarding,
                  child: const Text('Continue to Login'),
                ),
              ),
              TextButton(
                onPressed: _finishOnboarding,
                child: const Text('Skip'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
  });
}
