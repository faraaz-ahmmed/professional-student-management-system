
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 45),
              const Center(
                child: Icon(
                  Icons.school_rounded,
                  size: 65,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 35),
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.navy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Login to your PSMS admin account.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 35),

              const Text(
                'Email Address',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.navy,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 22),
              const Text(
                'Password',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.navy,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: AppTheme.navy),
                  ),
                ),
              ),

              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.navy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 35),
              const Center(
                child: Text(
                  'Smart Management, Better Education',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
