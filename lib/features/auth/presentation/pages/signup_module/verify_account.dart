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
import '../../../../../core/widgets/widgets.dart';

class VerifyAccount extends StatefulWidget {
  const VerifyAccount({super.key});

  @override
  State<VerifyAccount> createState() => _VerifyAccountState();
}

class _VerifyAccountState extends State<VerifyAccount> {
  final TextEditingController emailVerificationCodeController = TextEditingController();
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
                onPressed: () => context.go('/onboarding'),
                icon: const Icon(Icons.arrow_back,
                    color: Colors.black87, size: 28),
              ),

              const SizedBox(height: 40),

              Center(
                child: Image.asset('assets/images/verify_signup.png', height: 280),
              ),

              const SizedBox(height: 10),

              const Text(
                'Verify your account',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: emailVerificationCodeController,
                decoration: InputDecoration(
                  labelText: 'Enter Code Sent',
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
                    final code = emailVerificationCodeController.text.trim();
                    if (code.isEmpty) return;

                    setState(() => isLoading = true);

                    final result = await verifySignupCode(code: code);

                    setState(() => isLoading = false);

                    if (result.message == null) {
                      /// Code verified successfully → go to next step
                      context.push('/setUpProfile');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result.message.toString()),
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
                    'Verify',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              Center(
                child: TextButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();

                    int? token = prefs.getInt('signup_token');
                    String? email = prefs.getString('signup_email');

                    if (token == null || email == null) {
                      debugPrint("❌ Missing signup data");
                      return;
                    }

                    _resendSignupCode(
                      email: email,
                      verificationToken: token,
                    );
                  },

                  child: const Text(
                    'Resend email code',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resendSignupCode({
    required String email,
    required int verificationToken,
  }) async {
    debugPrint("🔵 [ResendSignupCode] API call started");

    try {
      final url =
          "https://api.foxscope.com/foxscope/resend_signup_code/email/";
      debugPrint("🌍 API URL: $url");

      final requestBody = {
        "email": {
          "value": email,
          "token": verificationToken,
        }
      };

      debugPrint("📤 Request body: $requestBody");

      debugPrint("🚀 Sending POST request...");
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      debugPrint("📡 Response received");
      debugPrint("📡 Status code: ${response.statusCode}");
      debugPrint("📨 Raw response body: ${response.body}");

      if (response.statusCode == 200) {
        debugPrint("✅ Signup code resent successfully");

        if (!mounted) return;

        showDialog(
          context: context,
          barrierDismissible: true,
          barrierColor: Colors.black.withOpacity(0.3),
          builder: (_) => buildSuccessPopup("Code resent"),
        );
      } else {
        debugPrint("⚠️ Failed to resend code");

        try {
          final body = jsonDecode(response.body);
          debugPrint("⚠️ Parsed error body: $body");
           Widgets.instant.showError(context,body['message'] ?? "Failed to resend code");
        } catch (e) {
          debugPrint("❌ Failed to parse error JSON: $e");
           Widgets.instant.showError(context,"Unexpected server response");
        }
      }
    } catch (e, stackTrace) {
      debugPrint("🔥 Exception occurred: $e");
      debugPrint("🧵 Stack trace:\n$stackTrace");
       Widgets.instant.showError(context,"Something went wrong");
    } finally {
      debugPrint("🔵 [ResendSignupCode] API call finished");
    }
  }

  Future<Result<void>> verifySignupCode({
    required String code,
  }) async {
    final url = Uri.parse(
      "https://api.foxscope.com/foxscope/create_account_second_step/",
    );

    try {
      final prefs = await SharedPreferences.getInstance();

      final email = prefs.getString('signup_email');
      final signupToken = prefs.getInt('signup_token');

      if (email == null || signupToken == null) {
        return Result(
          null,
          message: StringSet("Signup session expired. Please start again."),
        );
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "email": {
            "value": email,
            "token": signupToken,
            "code": code.trim(),
          }
        }),
      );

      print("SIGNUP STEP 2 STATUS: ${response.statusCode}");
      print("SIGNUP STEP 2 BODY: ${response.body}");

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        return Result(
          null,
          message: StringSet(data["message"] ?? "Invalid verification code"),
        );
      }

      final data = jsonDecode(response.body);
      final jwtToken = data["token"];

      /// Save JWT for next signup steps
      await prefs.setString('signup_jwt', jwtToken);

      return Result(null);
    } catch (e, s) {
      print("SIGNUP STEP 2 ERROR: $e");
      print(s);
      return Result(null, message: StringSet("Error: $e"));
    }
  }


  Widget buildSuccessPopup(String message) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50), // green circle
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



}
