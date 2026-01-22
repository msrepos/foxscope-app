import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_env.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_footer.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}


class _HelpPageState extends State<HelpPage> {
  //region variables
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String userName = "";
  bool _isLoading =false;
  Map<String, String> _socialLinks = {};
  bool _loadingSocials = true;
  bool _isSubmitting = false;
  //endregion


  @override
  void initState() {
    super.initState();
    _fetchSocialLinks();
  }
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitInquiry() async {
    // Validate fields
    if (_mobileController.text.trim().isEmpty) {
      _showErrorDialog('Please enter your mobile number');
      return;
    }

    if (_messageController.text.trim().isEmpty) {
      _showErrorDialog('Please enter your message');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('token');

      if (storedToken == null) {
        debugPrint('❌ No token found');
        _showErrorDialog('Authentication required');
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      final url = Uri.parse("${AppEnv.apiBaseUrl}/foxscope/help_inquiry/submit");

      debugPrint('📤 Submitting inquiry...');
      debugPrint('📞 Phone: ${_mobileController.text.trim()}');
      debugPrint('💬 Message: ${_messageController.text.trim()}');

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $storedToken",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "phone_number": _mobileController.text.trim(),
          "message": _messageController.text.trim(),
        }),
      );

      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📨 Response body: ${response.body}');

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Inquiry submitted successfully');
        _showSuccessDialog();
        // Clear form fields
        _mobileController.clear();
        _messageController.clear();
      } else {
        debugPrint('❌ Failed to submit inquiry: ${response.statusCode}');
        _showErrorDialog('Failed to submit inquiry. Please try again.');
      }
    } catch (e) {
      debugPrint('🔥 Error submitting inquiry: $e');
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        _showErrorDialog('An error occurred. Please try again.');
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          title: Column(
            children: [
              const SizedBox(height: 24),
              CircleAvatar(
                backgroundColor: Colors.green.shade100,
                radius: 30,
                child: const Icon(
                  Icons.check,
                  color: Colors.green,
                  size: 40,
                ),
              ),
            ],
          ),
          content: const Text(
            "Your inquiry has been submitted successfully! We'll get back to you soon.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text(
                  "OK",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Error",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text(
                  "OK",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const AppHeader(title: "Help Center", showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // White Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtitle
                  const Text(
                    "Stay in touch with us:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Email Row
                  Row(
                    children: const [
                      Icon(Icons.email, color: AppColors.primary),
                      SizedBox(width: 10),
                      Text(
                        "contactus@foxscope.com",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Send Inquiry Subtitle
                  const Text(
                    "Send Inquiry:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Name Field (kept but not used in API)
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Email Field (kept but not used in API)
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Mobile Field (required for API)
                  TextField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Mobile *",
                      hintText: "+1234567890",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Message Field (required for API)
                  TextField(
                    controller: _messageController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: "Message *",
                      hintText: "I need help with...",
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Send Button
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitInquiry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text(
                        "Send",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _socialIcon('twitter', 'assets/images/x.png'),
                      _socialIcon('facebook', 'assets/images/face.png'),
                      _socialIcon('instagram', 'assets/images/insta.png'),
                      _socialIcon('tiktok', 'assets/images/tiktok.png'),
                      _socialIcon('linkedin', 'assets/images/linkedin.png'),
                      _socialIcon('youtube', 'assets/images/youtube.png'),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppFooter(currentIndex: 3),
    );
  }

  Future<void> _fetchSocialLinks() async {
    debugPrint("🔵 Fetching social media links");

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        debugPrint("❌ No token found");
        return;
      }

      final response = await http.get(
        Uri.parse("https://api.foxscope.com/foxscope/get_app_media/"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      debugPrint("📡 Status: ${response.statusCode}");
      debugPrint("📨 Body: ${response.body}");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        final Map<String, String> links = {};
        for (final item in data) {
          final name = item['media_name'];
          final value = item['value'];

          if (value != null && value.toString().isNotEmpty) {
            links[name] = value;
          }
        }

        setState(() {
          _socialLinks = links;
          _loadingSocials = false;
        });
      }
    } catch (e) {
      debugPrint("🔥 Error fetching socials: $e");
      _loadingSocials = false;
    }
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("❌ Could not launch $url");
    }
  }

  Future<void> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? "User";
    });
  }

  Widget _socialIcon(String key, String asset) {
    final link = _socialLinks[key];

    return GestureDetector(
      onTap: link == null ? null : () => _openLink(link),
      child: Opacity(
        opacity: link == null ? 0.3 : 1,
        child: Image.asset(
          asset,
          width: 30,
          height: 30,
        ),
      ),
    );
  }

}