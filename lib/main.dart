import 'package:firebase_auth_demo/firebase_options.dart';
import 'package:firebase_auth_demo/temp/polygone_selection.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/core/theme/app_theme.dart';

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
    return MaterialApp(
      home: PolygonImageSelectionPage(),
      theme: AppTheme.lightTheme,
    );
  }
}
