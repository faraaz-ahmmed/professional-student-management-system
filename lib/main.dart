
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/theme/app_theme.dart';
import 'views/splash/splash_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
