import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👇 Back Arrow Button
              IconButton(
                onPressed: () {
                  context.go('/onboarding');
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black87,
                  size: 28,
                ),
              ),

              const SizedBox(height: 40),

              // ✅ Top Center Image
              Center(
                child: Image.asset(
                  'assets/images/login.png',
                  height: 160,
                ),
              ),

              const SizedBox(height: 40),

              // ✅ Heading (aligned left)
              const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),

              const SizedBox(height: 8),

              // ✅ Subtext
              const Text(
                'Please Login to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.left,
              ),

              const SizedBox(height: 40),

              // ✅ Email TextField
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ✅ Password TextField
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ✅ Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ✅ Forgot Password link
              Center(
                child: TextButton(
                  onPressed: () {
                    // handle forgot password
                  },
                  child: const Text(
                    'Forgot your password?',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ✅ Sign up with Section
              const Center(
                child: Text(
                  'Sign up with',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ✅ Icon buttons (Gmail and Apple)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Gmail
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red, size: 32),
                    onPressed: () {
                      // handle Gmail signup
                    },
                  ),
                  const SizedBox(width: 24),

                  // Apple
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.apple, color: Colors.black, size: 36),
                    onPressed: () {
                      // handle Apple signup
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
