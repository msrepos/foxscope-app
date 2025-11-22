import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/app_header.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const AppHeader(
        title: "Settings",
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1) PROFILE BOX
            Container(
              padding: const EdgeInsets.all(16),
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
                      const Text(
                        "Mahmoud Farag",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Logout",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2) FIRST LIST BOX
            _buildSettingsBox(
              items: [
                _buildSettingsItem(icon: Icons.person, title: "My Profile", isLast: false,
                  onTap: () => context.go('/profile'),
                  ),
                _buildSettingsItem(icon: Icons.language, title: "Language", isLast: false,
                  onTap: () => context.go('/language'),
                  ),     
                _buildSettingsItem(
                  icon: Icons.delete_forever,
                  title: "Delete My Account",
                  isLast: false,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        title: const Text(
                          "Disclaimer",
                          textAlign: TextAlign.center,
                        ),
                        content: const Text(
                          "Are you sure you want to delete your account?",
                          textAlign: TextAlign.center,
                        ),
                        actionsAlignment: MainAxisAlignment.center,
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                            onPressed: () {
                              // TODO: Add delete account logic here
                              Navigator.pop(context);
                            },
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                    );

                  },
                ),
                _buildSettingsItem(icon: Icons.credit_card, title: "Billing Info", isLast: true, onTap: () {}),
              ],
            ),

            const SizedBox(height: 16),

            // 3) SECOND LIST BOX
            _buildSettingsBox(
              items: [
                _buildSettingsItem(icon: Icons.privacy_tip, title: "Privacy Center", isLast: false,
                 onTap: () => context.go('/privacy'),
                ),
                _buildSettingsItem(
                  icon: Icons.lock,
                  title: "Privacy Policy",
                  isLast: false,
                  onTap: () => context.go('/policy'),
                ),
                _buildSettingsItem(icon: Icons.help_outline, title: "Help Center", isLast: false,
                  onTap: () => context.go('/help'),
                ),
                _buildSettingsItem(icon: Icons.article_outlined, title: "Terms & Conditions", isLast: true,
                  onTap: () => context.go('/terms'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 4) THIRD LIST BOX
            _buildSettingsBox(
              items: [
                _buildSettingsItem(icon: Icons.share, title: "Tell a Friend", isLast: true, onTap: () {}),
              ],
            ),

            const SizedBox(height: 20),

            // 5) SOCIAL MEDIA BAR
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Icon(Icons.facebook, size: 32),
                  Icon(Icons.camera_alt, size: 32),
                  Icon(Icons.telegram, size: 32),
                  Icon(Icons.share, size: 32),
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

  // Utility: Settings Box
  static Widget _buildSettingsBox({required List<Widget> items}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(children: items),
    );
  }

  // Utility: Settings Item
  static Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    bool isLast = false,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Row(
              children: [
                Icon(icon, color: Colors.black, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black54),
              ],
            ),
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 44, right: 20),
            child: Container(
              height: 1,
              color: Colors.grey.shade300,
            ),
          ),
      ],
    );
  }
}
