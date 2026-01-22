import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_header.dart';
import '../../../../../core/widgets/app_footer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:country_icons/country_icons.dart';

import '../../../../../core/widgets/widgets.dart';

class ChangeEmailScreen2 extends StatefulWidget {
  const ChangeEmailScreen2({super.key});

  @override
  State<ChangeEmailScreen2> createState() => _ChangeEmailScreen2State();
}

class _ChangeEmailScreen2State extends State<ChangeEmailScreen2> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;


  Future<void> _changeEmailSecondStep() async {
    debugPrint("🔵 [ChangeEmailStep2] started");

    final code = _otpController.text.trim();
    if (code.isEmpty) {
      Widgets.instant.showError(context,"Enter OTP");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final email = prefs.getString('pending_email');

      if (token == null || email == null) {
        Widgets.instant.showError(context,"Session expired");
        return;
      }

      final response = await http.post(
        Uri.parse(
          "https://api.foxscope.com/foxscope/profile/change_email_second_step",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "email": email,
          "code": code,
        }),
      );

      debugPrint("📡 Status: ${response.statusCode}");
      debugPrint("📨 Body: ${response.body}");

      if (response.statusCode == 200) {
        if (!mounted) return;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => Widgets.instant.buildSuccessPopup(
            'Email changed successfully',
          ),
        );

        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          Navigator.pop(context); // popup
          Navigator.pop(context); // screen
          Navigator.pop(context); // profile
        }
      } else {
        Widgets.instant.showError(context,"Invalid code");
      }
    } catch (e) {
      debugPrint("🔥 Error: $e");
      Widgets.instant.showError(context,"Something went wrong");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


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
                padding: EdgeInsetsGeometry.fromLTRB(15, 10, 15, 10),
                child:TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Enter OTP',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),

              ),
              Padding(
                padding: EdgeInsetsGeometry.fromLTRB(15, 5, 15, 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _changeEmailSecondStep,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Confirm Email Change',
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

              //todo there is no api for it
              // Padding(
              //   padding: EdgeInsetsGeometry.fromLTRB(15, 0, 15, 10),
              //   child: SizedBox(
              //     width: double.infinity,
              //     child: Center(
              //       child: TextButton(
              //         onPressed: () {
              //           // handle email code
              //         },
              //         child: const Text(
              //           'Resend Email Code',
              //           style: TextStyle(color: Colors.grey),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppFooter(currentIndex: 3),
    );
  }

}
