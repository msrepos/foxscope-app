import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foxscope/core/utils/account_storage.dart';
import 'package:foxscope/features/auth/data/models/user.dart';
import 'package:foxscope/features/auth/data/repositories/auth_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_env.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);

    final user = await AuthRepository().login(
      username: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    if (mounted) {
      if (user.result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login Successful"),
            backgroundColor: Colors.green,
          ),
        );

        context.go('/home', extra: user.result?.userId);
      }
      //
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(user.message?.get(true) ?? "Login failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true, // 👈 IMPORTANT to avoid keyboard overlap
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => context.go('/onboarding'),
                icon: const Icon(Icons.arrow_back,
                    color: Colors.black87, size: 28),
              ),

              const SizedBox(height: 40),

              Center(
                child: Image.asset('assets/images/login.png', height: 160),
              ),

              const SizedBox(height: 40),

              const Text(
                'Sign In',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please Login to continue',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 40),

              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Login',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Forgot your password?',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.google,
                        color: Colors.red, size: 32),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.apple,
                        color: Colors.black, size: 36),
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 40), // Extra padding for smooth scroll
            ],
          ),
        ),
      ),
    );
  }
}
