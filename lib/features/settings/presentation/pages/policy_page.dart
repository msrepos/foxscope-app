import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_footer.dart';

class PolicyPage extends StatefulWidget {
  const PolicyPage({super.key});

  @override
  State<PolicyPage> createState() => _PolicyPageState();
}

class _PolicyPageState extends State<PolicyPage> {
  String? _policyHtml;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPrivacyPolicy();
  }

  Future<void> _fetchPrivacyPolicy() async {
    debugPrint("🔵 Fetching privacy policy");

    try {
      final response = await http.get(
        Uri.parse("https://api.foxscope.com/foxscope/get_privacy_policy/"),
        headers: {
          "Accept": "application/json",
        },
      );

      debugPrint("📡 Status: ${response.statusCode}");
      debugPrint("📨 Raw body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedHtml = jsonDecode(response.body); // ✅ KEY LINE

        setState(() {
          _policyHtml = decodedHtml;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "Failed to load privacy policy";
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("🔥 Error loading policy: $e");
      setState(() {
        _error = "Something went wrong";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: "Privacy Center"),
      backgroundColor: const Color(0xFFF2F2F2),
      body: _buildBody(),
      bottomNavigationBar: const AppFooter(currentIndex: 3),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(fontSize: 16, color: Colors.red),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Html(
          data: _policyHtml!,
          style: {
            "h2": Style(
              color: AppColors.primary,
              fontSize: FontSize(22),
              fontWeight: FontWeight.bold,
            ),
            "h3": Style(
              fontSize: FontSize(18),
              fontWeight: FontWeight.bold,
            ),
            "p": Style(
              fontSize: FontSize(16),
              lineHeight: LineHeight(1.5),
            ),
            "li": Style(
              fontSize: FontSize(16),
              lineHeight: LineHeight(1.5),
            ),
          },
        ),
      ),
    );
  }
}
