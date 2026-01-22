import 'package:flutter/material.dart';
import 'package:foxscope/features/settings/presentation/pages/how_people_page.dart';
import 'package:foxscope/features/settings/presentation/pages/seen_state_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../auth/presentation/pages/profile_page.dart';

class ProfilePrivacyPage extends StatelessWidget {
  const ProfilePrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: "Privacy Center"),
      backgroundColor: const Color(0xFFF2F2F2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          //color: Colors.white,
          padding: const EdgeInsets.all(0),
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildSettingsBox(
              items: [
                _buildSettingsItem(
                  title: "How people can find your profile",
                  isLast: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HowPeoplePage(),
                      ),
                    );
                  },
                ),
                Divider(height: 5,endIndent: 20,indent: 20,),
                _buildSettingsItem(
                  title: "Seen Status",
                  isLast: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SeenStatePage(),
                      ),
                    );
                  },
                ),
              ],
            ),

          ]),
        ),
      ),
    );
  }

  static Widget _buildSettingsBox({required List<Widget> items}) {
    return Container(

      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(children: items),
    );
  }

  static Widget _buildSettingsItem({
    required String title,
    bool isLast = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent, // 👈 required for InkWell
      child: InkWell(
        borderRadius: BorderRadius.circular(14), // 👈 rounded ripple
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            children: [
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
              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }

}
