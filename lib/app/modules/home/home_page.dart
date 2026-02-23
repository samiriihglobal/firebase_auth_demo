import 'package:firebase_auth_demo/app/main_layout.dart';
import 'package:firebase_auth_demo/app/modules/home/home_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Example values, later fetch from Firestore
    // final String profileUrl = controller.profilePicture.value;

    return MainLayout(
      userName: controller.username.value,
      profileUrl: "",
      child: LiquidGlassRenderer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// Cube of the Day Card
              LiquidGlass(
                borderRadius: BorderRadius.circular(20),
                blur: 18,
                tintColor: Colors.white.withValues(alpha: 0.25),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline,
                          color: Colors.amber, size: 36),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Cube of the Day",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(controller.cubeOfTheDay.value),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// Grid of Features
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3 / 2,
                children: [
                  _buildHomeButton(context, "Scan & Solve", Icons.qr_code_scanner,
                      '/scan'),
                  _buildHomeButton(
                      context, "Play Cube", CupertinoIcons.cube, '/rubik'),
                  _buildHomeButton(context, "Timer", Icons.timer, '/timer'),
                  _buildHomeButton(
                      context, "Lessons", Icons.menu_book, '/lessonlist'),
                  _buildHomeButton(
                      context, "Progress", Icons.show_chart, '/progress'),
                  _buildHomeButton(context, "Achievements", Icons.emoji_events,
                      '/achievement'),
                  _buildHomeButton(
                      context, "Algorithms", Icons.functions, '/algorithm'),
                  _buildHomeButton(context, "Time List", Icons.list, '/timelist'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeButton(
      BuildContext context, String label, IconData icon, String route) {
    return GestureDetector(
      onTap: () => Get.toNamed(route),
      child: LiquidGlass(
        borderRadius: BorderRadius.circular(20),
        blur: 12,
        tintColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.2),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
