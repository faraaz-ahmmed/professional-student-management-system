
import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.background,
              Color(0xFFFFE9A8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.school_rounded,
                size: 65,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'PSMS',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppTheme.navy,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Professional Student Management System',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.navy,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Smart Management, Better Education',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(
              color: AppTheme.navy,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
