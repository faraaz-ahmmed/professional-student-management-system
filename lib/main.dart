
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'views/splash/splash_screen.dart';

void main() {
  runApp(const PSMSApp());
}

class PSMSApp extends StatelessWidget {
  const PSMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PSMS',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
