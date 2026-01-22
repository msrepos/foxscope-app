import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_footer.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  String? _termsHtml;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTerms();
  }

  Future<void> _fetchTerms() async {
    debugPrint("🔵 Fetching Terms & Conditions");

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        setState(() {
          _error = "Unauthorized";
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(
          "https://api.foxscope.com/foxscope/get_terms_and_conditions/",
        ),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      debugPrint("📡 Status: ${response.statusCode}");
      debugPrint("📨 Raw body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedHtml = jsonDecode(response.body); // ✅ IMPORTANT

        setState(() {
          _termsHtml = decodedHtml;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "Failed to load terms & conditions";
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("🔥 Error loading terms: $e");
      setState(() {
        _error = "Something went wrong";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: "Terms & Conditions"),
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
          data: _termsHtml!,
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
