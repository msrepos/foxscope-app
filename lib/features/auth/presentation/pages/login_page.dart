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
import '../../../../core/utils/result.dart';
import '../../../../core/utils/string_set.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<Result<User>> login({
    required String username,
    required String password,
    IAccountStorage<User>? userStorage,
  }) async {
    final loginUrl = Uri.parse(
      "https://api.foxscope.com/foxscope/authentication/",
    );

    final profileUrl = Uri.parse(
      "https://api.foxscope.com/foxscope/profile/min_details",
    );

    try {
      /// 1️⃣ LOGIN REQUEST
      final loginResponse = await http.post(
        loginUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': username.trim(),
          'password': password.trim(),
        }),
      );

      print("LOGIN STATUS: ${loginResponse.statusCode}");
      print("LOGIN BODY: ${loginResponse.body}");

      final loginData = jsonDecode(loginResponse.body);

      if (loginResponse.statusCode != 200 || loginData["token"] == null) {
        return Result(
          null,
          message: StringSet(loginData["message"] ?? "Login failed"),
        );
      }

      final token = loginData["token"];

      /// 2️⃣ SAVE TOKEN
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      /// 3️⃣ FETCH PROFILE MIN DETAILS
      final profileResponse = await http.get(
        profileUrl,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("PROFILE STATUS: ${profileResponse.statusCode}");
      print("PROFILE BODY: ${profileResponse.body}");

      if (profileResponse.statusCode != 200) {
        return Result(
          null,
          message: StringSet("Failed to load user profile"),
        );
      }

      final profileData = jsonDecode(profileResponse.body);

      final userId = profileData["uuid"];
      final userName =
          "${profileData["first_name"]} ${profileData["last_name"]}";

      /// 4️⃣ SAVE USER DATA
      await prefs.setString('user_id', userId);
      await prefs.setString('user_name', userName);
      await prefs.setString('user_email', profileData["email"]);

      /// 5️⃣ MAP USER
      final user = UserMapper().fromMap({
        'token': token,
        'userId': userId,
        'userName': userName,
      });

      (userStorage ?? AccountStorage(UserMapper())).saveAccount(
        user,
        username.trim(),
        password.trim(),
      );

      /// 6️⃣ NAVIGATE
      context.go('/home', extra: userId);

      return Result(user);
    } catch (e, s) {
      print("LOGIN ERROR: $e");
      print(s);
      return Result(null, message: StringSet("Error: $e"));
    }
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

              Center(
                child: Image.asset('assets/images/login.png', height: 250),
              ),

              const SizedBox(height: 10),

              const Text(
                'Sign In',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

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
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () async {
              setState(() => isLoading = true);

              await login(
                username: emailController.text.trim(),
                password: passwordController.text.trim(),
              );

              if (mounted) {
                setState(() => isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.black,
              disabledBackgroundColor: AppColors.black.withOpacity(0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: isLoading
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
                : const Text(
              'Login',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
              const SizedBox(height: 16),

              Center(
                child: TextButton(
                  onPressed: () {
                    context.push('/forgetPassword');
                  },
                  child: const Text(
                    'Forgot your password?',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),

              Center(
                child: TextButton(
                  onPressed: () {
                    // context.push('/createAccount');
                  },
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
