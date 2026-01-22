import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_env.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_header.dart';
import '../../../../../core/widgets/app_footer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:country_icons/country_icons.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../../../core/widgets/widgets.dart';


class ChangePasswordScreen1 extends StatefulWidget {
  const ChangePasswordScreen1({super.key});

  @override
  State<ChangePasswordScreen1> createState() => _ChangePasswordScreen1State();
}

class _ChangePasswordScreen1State extends State<ChangePasswordScreen1> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _changePassword() async {
    debugPrint("🔵 [ChangePassword] API call started");

    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    debugPrint("📝 Old password length: ${oldPassword.length}");
    debugPrint("📝 New password length: ${newPassword.length}");

    // Validation
    if (oldPassword.isEmpty || newPassword.isEmpty) {
      debugPrint("❌ Validation failed: Empty fields");
       Widgets.instant.showError(context,"Please fill all fields");
      return;
    }

    setState(() => _isLoading = true);
    debugPrint("⏳ Loading state set to TRUE");

    try {
      debugPrint("📦 Fetching SharedPreferences...");
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('token');
      debugPrint("🔐 Token found: ${token != null}");
      if (token != null) {
        debugPrint("🔐 Token preview: ${token.substring(0, 15)}...");
      }

      if (token == null) {
        debugPrint("🚫 Unauthorized: Token is null");
         Widgets.instant.showError(context,"Unauthorized");
        return;
      }

      final url =
          "https://api.foxscope.com/foxscope/profile/change_passowrd";
      debugPrint("🌍 API URL: $url");

      final requestBody = {
        "password": oldPassword,
        "new_password": newPassword,
      };
      debugPrint("📤 Request body: $requestBody");

      debugPrint("🚀 Sending POST request...");
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(requestBody),
      );

      debugPrint("📡 Response received");
      debugPrint("📡 Status code: ${response.statusCode}");
      debugPrint("📨 Raw response body: ${response.body}");

      if (response.statusCode == 200) {
        debugPrint("✅ Password changed successfully");
        _showSuccess("Password changed successfully");
      } else {
        debugPrint("⚠️ Non-200 response received");

        try {
          final body = jsonDecode(response.body);
          debugPrint("⚠️ Parsed error body: $body");
           Widgets.instant.showError(context,body['message'] ?? "Failed to change password");
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
      if (mounted) {
        debugPrint("🔁 Resetting loading state to FALSE");
        setState(() => _isLoading = false);
      }
      debugPrint("🔵 [ChangePassword] API call finished");
    }
  }

  void _showSuccess(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Widgets.instant.buildSuccessPopup(message),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      Navigator.pop(context);
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const AppHeader(title: "Change Password", showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              TextField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor:
                    AppColors.primary.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Change Password',
                    style:
                    TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppFooter(currentIndex: 3),
    );
  }

}
