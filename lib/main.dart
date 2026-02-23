import 'package:firebase_auth_demo/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'app/core/routes/app_pages.dart';
import 'app/core/theme/app_theme.dart';
import 'app/core/theme/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ThemeService themeService = Get.put(ThemeService());
    // return GetMaterialApp(
    //   title: "Ultimate Cube",
    //   debugShowCheckedModeBanner: false,
    //   theme: AppTheme.lightTheme,
    //   darkTheme: AppTheme.darkTheme,
    //   themeMode: themeService.themeMode,
    //   initialRoute: AppPages.INITIAL,
    //   getPages: AppPages.routes,
    // );
    ThemeService themeService = Get.put(ThemeService());
    return GetMaterialApp(
      title: "Firebase Auth Demo",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeService.themeMode,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
