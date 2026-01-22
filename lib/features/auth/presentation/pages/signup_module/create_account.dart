import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foxscope/core/utils/account_storage.dart';
import 'package:foxscope/features/auth/data/models/user.dart';
import 'package:foxscope/features/auth/data/repositories/auth_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/constants/app_env.dart';
import '../../../../../core/utils/result.dart';
import '../../../../../core/utils/string_set.dart';
import 'api.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;


  Future<Result<void>> signupStep1({
    required String email,
  })
  async {
    final url = Uri.parse(
      "https://api.foxscope.com/foxscope/create_account_first_step/",
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
        }),
      );

      print("SIGNUP STEP 1 STATUS: ${response.statusCode}");
      print("SIGNUP STEP 1 BODY: ${response.body}");

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        return Result(
          null,
          message: StringSet(data["message"] ?? "Signup failed"),
        );
      }

      final data = jsonDecode(response.body);

      final signupToken = data["email"]["token"];
      final signupEmail = data["email"]["value"];

      /// Save for next steps
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt('signup_token', signupToken);
      await prefs.setString('signup_email', signupEmail);

      return Result(null);
    } catch (e, s) {
      print("SIGNUP STEP 1 ERROR: $e");
      print(s);
      return Result(null, message: StringSet("Error: $e"));
    }
  }



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
                onPressed: () => context.go('/onboarding'),
                icon: const Icon(Icons.arrow_back,
                    color: Colors.black87, size: 28),
              ),

              const SizedBox(height: 40),

              Center(
                child: Image.asset('assets/images/login.png', height: 280),
              ),

              const SizedBox(height: 10),

              const Text(
                'create your account',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                    final email = emailController.text.trim();
                    if (email.isEmpty) return;

                    setState(() => isLoading = true);

                    final result = await signupStep1(email: email);

                    setState(() => isLoading = false);

                    if (result.message == null) {
                      /// Optional: keep in memory
                      SignupSession().draft.email = email;

                      /// Go to verification code screen
                      context.push('/verifyAccountSignUp');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result.message?.toString() ?? 'Signup failed',
                          ),
                        ),
                      );
                    }
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
                    'Create',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),

                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Sign up with',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        fontSize: 20),
                  ),
                ),
              ),
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
