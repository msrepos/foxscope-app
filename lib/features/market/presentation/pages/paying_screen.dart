import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foxscope/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_env.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/app_header.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../chat/presentation/pages/forward_page.dart';
import '../../../scope/presentation/pages/scope_page.dart';
class AppEnv {
  // 🔧 UPDATE THIS TO YOUR ACTUAL SERVER URL

  // For local development on emulator:
  // static const String apiBaseUrl = "http://10.0.2.2:8000"; // Android emulator
  // static const String apiBaseUrl = "http://127.0.0.1:8000"; // iOS simulator

  // For local development on physical device:
  // static const String apiBaseUrl = "http://192.168.1.XXX:8000"; // Replace XXX with your IP

  // For production:
  static const String apiBaseUrl = "http://localhost:8000"; // Change this!

// ⚠️ IMPORTANT: No trailing slash!
}

class PaymentGateway extends StatefulWidget {
  final Map<String, dynamic> scopeData;
  final String subscriptionType; // 'monthly' or 'yearly'

  const PaymentGateway({
    required this.scopeData,
    required this.subscriptionType,
    super.key,
  });

  @override
  State<PaymentGateway> createState() => _PaymentGatewayState();
}

class _PaymentGatewayState extends State<PaymentGateway> {

  //region variables
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvcController = TextEditingController();
  final TextEditingController _cardholderController = TextEditingController();
  bool _saveInfo = false;
  bool _isProcessing = false;
  String _selectedCountry = "Qatar";
  //endregion

  @override
  void dispose() {
    _emailController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _cardholderController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.subscriptionType == 'monthly' ? '\$4.99' : '\$50.00';
    final primeName = widget.scopeData['prime_name'] ?? 'Unknown';

    return Scaffold(
      appBar: const AppHeader(title: "Payment"),
      backgroundColor: const Color(0xFFF2F2F2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: const Icon(Icons.storefront_outlined, size: 18),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "FoxScope",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF2BF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "SECURE",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Text(
                    "Prime scope: $primeName",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 2),

                  Text(
                    price,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Apple Pay Button
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      //onPressed: _isProcessing ? null : _handlePayment,
                      onPressed:(){
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ScopePage(
                              showScopeAddedPopup: true,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.apple, size: 22, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            "Pay",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Email
                  const Text("Email", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration("your@email.com"),
                  ),
                  const SizedBox(height: 16),

                  // Card Information
                  const Text("Card information", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _cardNumberController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration("1234 1234 1234 1234").copyWith(
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text("VISA", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            SizedBox(width: 4),
                            Text("MC", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _expiryController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration("MM / YY"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _cvcController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration("CVC"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Cardholder Name
                  const Text("Cardholder name", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _cardholderController,
                    decoration: _inputDecoration("Full name on card"),
                  ),
                  const SizedBox(height: 16),

                  // Country
                  const Text("Country or region", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedCountry,
                    items: const [
                      DropdownMenuItem(value: "Qatar", child: Text("Qatar")),
                      DropdownMenuItem(value: "Egypt", child: Text("Egypt")),
                      DropdownMenuItem(value: "UAE", child: Text("UAE")),
                    ],
                    onChanged: (value) => setState(() => _selectedCountry = value!),
                    decoration: _inputDecoration(""),
                  ),
                  const SizedBox(height: 10),

                  // Save Info Checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _saveInfo,
                        onChanged: (v) => setState(() => _saveInfo = v!),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Text(
                          "Securely save my information for 1-click checkout",
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Pay Button
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      //onPressed: _isProcessing ? null : _handlePayment,
                        onPressed:(){
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ScopePage(
                                showScopeAddedPopup: true,
                              ),
                            ),
                          );
                        },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        "Pay",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Debug Info (Remove in production)
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🔍 Debug Info',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'API URL: ${AppEnv.apiBaseUrl}',
                          style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                        ),
                        Text(
                          'Endpoint: /foxscope/pay_scope_first_step',
                          style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppFooter(currentIndex: 0),
    );
  }

  Future<void> _handlePayment() async {
    // Validation
    if (_emailController.text.trim().isEmpty) {
       Widgets.instant.showError(context,"Please enter your email");
      return;
    }
    if (_cardNumberController.text.trim().isEmpty) {
       Widgets.instant.showError(context,"Please enter card number");
      return;
    }
    if (_cardholderController.text.trim().isEmpty) {
       Widgets.instant.showError(context,"Please enter cardholder name");
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
         Widgets.instant.showError(context,"Not logged in");
        if (mounted) setState(() => _isProcessing = false);
        return;
      }

      // ========== EXACT API CALL FROM POSTMAN ==========
      final String baseUrl = AppEnv.apiBaseUrl;

      // Build URL exactly like Postman
      final redirectPrefix = 'https://foxscope.com/payment-callback';
      final fullUrl = '$baseUrl/foxscope/pay_scope_first_step?redirect_prefix=$redirectPrefix';

      print('═══════════════════════════════════════');
      print('📤 PAYMENT REQUEST');
      print('═══════════════════════════════════════');
      print('URL: $fullUrl');
      print('Method: POST');
      print('Token: ${token.substring(0, min(30, token.length))}...');
      print('═══════════════════════════════════════');

      final url = Uri.parse(fullUrl);
      final request = http.MultipartRequest("POST", url);

      // Headers exactly like Postman
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['X-App-Type'] = 'web'; // Postman uses 'web'

      // Data field exactly like Postman
      final dataJson = jsonEncode({
        'prime_mode': true,
        'prime_name': widget.scopeData['prime_name'],
        'latitude': widget.scopeData['latitude'],
        'longitude': widget.scopeData['longitude'],
        'friendly_name': widget.scopeData['friendly_name'],
        'category': widget.scopeData['category'],
      });

      print('Data: $dataJson');

      request.fields['data'] = dataJson;

      // Image exactly like Postman
      final File imageFile = widget.scopeData['image'] as File;
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      print('Image: ${imageFile.path}');
      print('───────────────────────────────────────');
      print('Sending request...');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('═══════════════════════════════════════');
      print('📥 PAYMENT RESPONSE');
      print('═══════════════════════════════════════');
      print('Status: ${response.statusCode}');
      print('Body: $responseBody');
      print('═══════════════════════════════════════\n');

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(responseBody);

        // The API should return a checkout_url for Stripe
        // In a real app, you would open this URL in a WebView
        final checkoutUrl = jsonResponse['checkout_url'] ?? jsonResponse['url'];

        if (checkoutUrl != null) {
          print('✅ Checkout URL received: $checkoutUrl');
          // TODO: Open checkoutUrl in WebView
          // For now, simulate success
        }

        await _showSuccessAndNavigate();
      } else {
        // Detailed error message
        String errorMsg = 'Payment failed (${response.statusCode})';

        if (response.statusCode == 404) {
          errorMsg += '\n\n❌ Endpoint not found!\n\nPlease check:\n'
              '1. Server is running at: $baseUrl\n'
              '2. Endpoint exists: /foxscope/pay_scope_first_step\n'
              '3. Try accessing: $fullUrl in browser';
        } else if (response.statusCode == 401) {
          errorMsg += '\n\n❌ Authentication failed!\n'
              'Your token may have expired. Please log in again.';
        } else {
          errorMsg += '\n\nResponse: ${responseBody.substring(0, min(200, responseBody.length))}';
        }

         Widgets.instant.showError(context,errorMsg);
      }
    } catch (e) {
      print('❌ EXCEPTION: $e');
      if (!mounted) return;

      String errorMsg = 'Error: $e';
      if (e.toString().contains('SocketException') || e.toString().contains('Connection refused')) {
        errorMsg = '❌ Cannot connect to server!\n\n'
            'Server URL: ${AppEnv.apiBaseUrl}\n\n'
            'Please check:\n'
            '1. Server is running\n'
            '2. URL is correct\n'
            '3. Phone/emulator can reach server';
      }

       Widgets.instant.showError(context,errorMsg);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }



  Future<void> _showSuccessAndNavigate() async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _buildScopeAddedPopup(
        context: context,
        onShare: () {
          if (!mounted) return;
          Navigator.of(context).pop();
          Share.share("Check out my Prime scope on FoxScope!");
        },
        onForward: () {
          if (!mounted) return;
          Navigator.of(context).pop();
        },
        onContinue: () {
          if (!mounted) return;
          Navigator.of(context).pop();
        },
      ),
    );

    if (!mounted) return;

    Navigator.of(context).pop(true);
    Navigator.of(context).pop(true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const ScopePage(
          showScopeAddedPopup: true,
        ),
      ),
    );  }

  Widget _buildScopeAddedPopup({
    VoidCallback? onShare,
    VoidCallback? onForward,
    VoidCallback? onContinue,
    required BuildContext context,
  }) {
    return Center(
      child: Material(
        color: Colors.black.withOpacity(0.2),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 32, color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Prime Scope Created!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Your Prime scope has been created successfully! You can now enjoy premium features and visibility.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onShare ?? () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Share",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onForward ?? () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Forward",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onContinue ?? () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.primary, width: 1.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}