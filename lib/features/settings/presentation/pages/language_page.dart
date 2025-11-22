import 'package:flutter/material.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_footer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:country_icons/country_icons.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String _selectedLanguage = "en";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const AppHeader(title: "Language", showBack: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildLanguageItem(
                flagAsset: 'icons/flags/svg/gb.svg',
                title: "English",
                code: "en",
                isLast: false,
              ),
              _buildLanguageItem(
                flagAsset: 'icons/flags/svg/sa.svg',
                title: "العربية",
                code: "ar",
                isLast: false,
              ),
              _buildLanguageItem(
                flagAsset: 'icons/flags/svg/fr.svg',
                title: "Français",
                code: "fr",
                isLast: true,
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const AppFooter(currentIndex: 3),
    );
  }

  Widget _buildLanguageItem({
    required String flagAsset,
    required String title,
    required String code,
    required bool isLast,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _selectedLanguage = code;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            child: Row(
              children: [
                SvgPicture.asset(
                  flagAsset,
                  package: 'country_icons',
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                Radio<String>(
                  value: code,
                  groupValue: _selectedLanguage,
                  onChanged: (value) {
                    setState(() {
                      _selectedLanguage = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Container(height: 1, color: Colors.grey.shade300),
          ),
      ],
    );
  }
}
