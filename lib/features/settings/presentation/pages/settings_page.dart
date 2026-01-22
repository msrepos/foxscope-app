import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foxscope/features/auth/presentation/pages/profile_page.dart';
import 'package:foxscope/features/scope/presentation/pages/edit_scope.dart';
import 'package:foxscope/features/settings/presentation/pages/help_page.dart';
import 'package:foxscope/features/settings/presentation/pages/language_page.dart';
import 'package:foxscope/features/settings/presentation/pages/policy_page.dart';
import 'package:foxscope/features/settings/presentation/pages/privacy_page.dart';
import 'package:foxscope/features/settings/presentation/pages/terms_page.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/app_header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/widgets/widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  //region variables
  String userName = "";
  bool _isLoading =false;
  Map<String, String> _socialLinks = {};
  bool _loadingSocials = true;
  //endregion

  @override
  void initState() {
    super.initState();
    loadUserName();
    _fetchSocialLinks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const AppHeader(
        title: "Settings",
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16,5,16,16),
        child: Column(
          children: [
            // PROFILE BOX
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage("assets/images/profile_sample.png"),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('token');
                        await prefs.remove('user_name');

                        if (context.mounted) {
                          context.go('/onboarding');
                        }
                      },
                      child: const Text("Logout"),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Widgets.instant.buildSettingsBox(
              items: [
                Widgets.instant.buildSettingsItem(
                  icon: Icons.person,
                  title: "My Profile",
                  isLast: false,
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfilePage(),
                      ),
                    );
                  },                ),
                Widgets.instant.buildSettingsItem(
                  icon: Icons.language,
                  title: "Language",
                  isLast: false,
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LanguagePage(),
                      ),
                    );
                  },                ),
                Widgets.instant.buildSettingsItem(
                  icon: Icons.delete_forever,
                  title: "Delete My Account",
                  isLast: false,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16), // Slightly larger radius for the screenshot look
                        ),
                        titlePadding: EdgeInsets.zero,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),

                        title: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 24),
                            const CircleAvatar(
                              radius: 24,
                              backgroundColor:AppColors.primary, // Sample Orange color
                              child: Icon(
                                Icons.info_outline,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Disclaimer",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        content: const Text(
                          "Deleting your account is permanent. All your data, including your profile, history, and settings, will be permanently erased.\nAre you sure you want to proceed?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87, // Match the dark text color
                            height: 1.2,
                          ),
                        ),

                        actionsAlignment: MainAxisAlignment.center,
                        actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),

                        actions: [
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary, // Sample Orange color
                                    minimumSize: const Size(double.infinity, 50), // Ensure height
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: _isLoading
                                      ? null
                                      : () {
                                    Navigator.pop(context);
                                    _deleteAccount();

                                  },
                                  child: const Text(
                                    "Delete",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12), // Spacing between buttons

                              // 2. Cancel Button (White with Black/Grey Border)
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 50), // Ensure height
                                    side: const BorderSide(
                                      color: Colors.grey, // Border color
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: Colors.black, // Text color
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Widgets.instant.buildSettingsItem(
                  icon: Icons.credit_card,
                  title: "Billing Info",
                  isLast: true,
                  onTap: () {
                    context.push(
                      '/scopes',
                      extra: 3,
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),

            // SECOND LIST BOX
            Widgets.instant.buildSettingsBox(
              items: [
                Widgets.instant.buildSettingsItem(
                  icon: Icons.lock,
                  title: "Privacy Center",
                  isLast: false,
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PrivacyPage(),
                      ),
                    );
                  },
                ),
                Widgets.instant.buildSettingsItem(
                  icon: Icons.help_outline,
                  title: "Help Center",
                  isLast: false,
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HelpPage(),
                      ),
                    );
                  },                ),
                Widgets.instant.buildSettingsItem(
                  icon: Icons.file_copy_rounded,
                  title: "Privacy Policy",
                  isLast: false,
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PolicyPage(),
                      ),
                    );
                  },                ),

                Widgets.instant.buildSettingsItem(
                  icon: Icons.article_outlined,
                  title: "Terms & Conditions",
                  isLast: true,
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TermsPage(),
                      ),
                    );
                  },                ),
              ],
            ),

            const SizedBox(height: 10),

            // THIRD LIST BOX
            Widgets.instant.buildSettingsBox(
              items: [
                Widgets.instant.buildSettingsItem(
                  icon: Icons.group,
                  title: "Tell a Friend",
                  isLast: true,
                  onTap: () async {
                    debugPrint('🔵 Share button tapped');

                    try {
                      final result = await Share.share(
                        'Lets use Foxscope app, a simple, fast and secure app to share and organise your addresses.\n\nDownload it now here: https://foxscope.com',
                        subject: 'Check out Foxscope!',
                      );

                      debugPrint('🟢 Share completed: ${result.status}');
                    } catch (e) {
                      debugPrint('🔴 Share error: $e');
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),

            // SOCIAL MEDIA BAR
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _loadingSocials
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
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
            ),

            const SizedBox(height: 80),
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

  Future<void> _deleteAccount() async {
    debugPrint("🔴 [DeleteAccount] API call started");

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
         Widgets.instant.showError(context,"Unauthorized");
        return;
      }

      final response = await http.get(
        Uri.parse("https://api.foxscope.com/foxscope/profile/delete_account"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      debugPrint("📡 Status code: ${response.statusCode}");
      debugPrint("📨 Body: ${response.body}");

      if (response.statusCode == 200) {
        debugPrint("✅ Account deleted");

        await prefs.clear();

        if (!mounted) return;

        // ✅ ONE navigation action ONLY
        context.go('/login');
      } else {
        final body = jsonDecode(response.body);
         Widgets.instant.showError(context,body['message'] ?? "Failed to delete account");
      }
    } catch (e, s) {
      debugPrint("🔥 Exception: $e");
      debugPrint("🧵 Stack: $s");
       Widgets.instant.showError(context,"Something went wrong");
    } finally {
      if (mounted) setState(() => _isLoading = false);
      debugPrint("🔴 [DeleteAccount] finished");
    }
  }


}
