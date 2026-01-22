import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../auth/presentation/pages/profile_page.dart';

class SeenStatePage extends StatefulWidget {
  const SeenStatePage({super.key});

  @override
  State<SeenStatePage> createState() => _SeenStatePageState();



}

class _SeenStatePageState extends State<SeenStatePage> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: "Privacy Center"),
      backgroundColor: const Color(0xFFF2F2F2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("The \"seen\" status lets other users know when you've read their messages. When you disable this feature, others won't see when you've read their messages, and you also won't see when they've read yours."),

                SizedBox(height: 12,),
                _buildSettingsBox(
                  items: [
                    _buildSettingsItem(
                      title: "Show when i've seen messages",
                      value: notificationsEnabled,
                      onChanged: (val) {
                        setState(() {
                          notificationsEnabled = val;
                        });
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
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric( horizontal: 12),
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
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.black, // adjust to theme
            ),
          ],
        ),
      ),
    );
  }
}
