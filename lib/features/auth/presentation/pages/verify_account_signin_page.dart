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

class VerifyAccountSignIn extends StatefulWidget {
  const VerifyAccountSignIn({super.key});

  @override
  State<VerifyAccountSignIn> createState() => _VerifyAccountSignInState();
}

class _VerifyAccountSignInState extends State<VerifyAccountSignIn> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => context.pop(), //todo
                icon: const Icon(Icons.arrow_back,
                    color: Colors.black87, size: 28),
              ),

              const SizedBox(height: 40),

              //to be changed
              Center(
                child: Image.asset('assets/images/verifyAccountSI.png', height: 260),
              ),

              const SizedBox(height: 40),

              const Text(
                'Verify your account',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Verification code',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:(){
                    context.push('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Reset',
                    style: TextStyle(fontSize: 16, color: Colors.white),
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
