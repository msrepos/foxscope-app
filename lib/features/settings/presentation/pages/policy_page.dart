import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_footer.dart';

class PolicyPage extends StatelessWidget {
  const PolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: "Privacy Policy"),
      backgroundColor: const Color(0xFFF2F2F2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              "Privacy Policy",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "This Privacy Policy describes how this application collects, uses, and protects your information. By using this app, you agree to the collection and use of information in accordance with this policy.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 20),
            _buildSectionTitle("1. Camera Usage"),
            const Text(
              "This application uses your device's camera solely for the purpose of scanning QR codes. No images or video footage are recorded, saved, or transmitted to any server.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 20),
            _buildSectionTitle("2. GPS & Location Services"),
            const Text(
              "The app collects your GPS location only when required to store the location linked to scanned QR codes. Location data is stored securely and is never shared with third parties, except when explicitly required for app functionality.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 20),
            _buildSectionTitle("3. Data Storage & Security"),
            const Text(
              "We ensure that all collected data (locations, scanned records) is securely stored. We do not sell, trade, or share your data with any external parties.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 20),
            _buildSectionTitle("4. Third-Party Services"),
            const Text(
              "This application does not integrate with external analytics, tracking systems, or advertising networks. Your data remains fully private.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 20),
            _buildSectionTitle("5. User Consent"),
            const Text(
              "By using this application, you consent to the use of your device's camera and location services strictly for the intended functionalities.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 20),
            _buildSectionTitle("6. Changes to This Policy"),
            const Text(
              "We may update this Privacy Policy from time to time. You are advised to review this page periodically for any changes.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 30),
            const Text(
              "If you have any questions regarding this Privacy Policy, please contact the support team.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
      bottomNavigationBar: const AppFooter(currentIndex: 3),
    );
  }

  static Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
