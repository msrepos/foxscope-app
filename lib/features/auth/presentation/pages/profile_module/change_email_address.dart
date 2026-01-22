import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/widgets/app_header.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_header.dart';
import '../../../../../core/widgets/app_footer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:country_icons/country_icons.dart';

import '../../../../../core/widgets/widgets.dart';

class ChangeEmailScreen1 extends StatefulWidget {
  const ChangeEmailScreen1({super.key});

  @override
  State<ChangeEmailScreen1> createState() => _ChangeEmailScreen1State();
}

class _ChangeEmailScreen1State extends State<ChangeEmailScreen1> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const AppHeader(title: "Change Authentication Email", showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsetsGeometry.fromLTRB(15,10,15,10),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'New Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsGeometry.fromLTRB(15,5,15,10),
                child:TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Enter Password To Confirm',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsetsGeometry.fromLTRB(15,5,15,20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _changeEmailFirstStep,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Change Email',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
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

  Future<void> _changeEmailFirstStep() async {
    debugPrint("🔵 [ChangeEmailStep1] started");

    final newEmail = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (newEmail.isEmpty || password.isEmpty) {
      Widgets.instant.showError(context, "Please fill all fields");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
         Widgets.instant.showError(context,"Unauthorized");
        return;
      }

      final response = await http.post(
        Uri.parse(
          "https://api.foxscope.com/foxscope/profile/change_email_first_step",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "email": newEmail,
          "password": password,
        }),
      );

      debugPrint("📡 Status: ${response.statusCode}");
      debugPrint("📨 Body: ${response.body}");

      if (response.statusCode == 200) {
        // Save email for step 2
        await prefs.setString('pending_email', newEmail);

        if (!mounted) return;
        context.push('/changeEmailS2');
      } else {
         Widgets.instant.showError(context,"Failed to change email");
      }
    } catch (e) {
      debugPrint("🔥 Error: $e");
       Widgets.instant.showError(context,"Something went wrong");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

}
