import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/constants/app_env.dart';
import 'package:share_plus/share_plus.dart';

class QrCodePage extends StatefulWidget {
  const QrCodePage({super.key});

  @override
  State<QrCodePage> createState() => _QrCodePageState();
}

class _QrCodePageState extends State<QrCodePage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: "Scopes"),
      backgroundColor: const Color(0xFFF2F2F2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 6,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Divider(height: 1), // top line

                      const SizedBox(height: 16),

                      // QR + logo in the middle
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 250,
                            height: 250,
                            child: Image.asset(
                              'assets/images/qr.png', // <-- your QR image
                              fit: BoxFit.contain,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            color: Colors.white,
                            child: Image.asset(
                              'assets/images/fox-scope-logo.png', // <-- small logo
                              height: 40,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      const Divider(height: 1), // bottom line

                      const SizedBox(height: 16),

                      // Buttons row
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: handle download
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF26722), // orange
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Download',style: TextStyle(color: Colors.white),),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _safeShare(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF333333), // dark
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Share',style: TextStyle(color: Colors.white),),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ]
        ),
      ),
      bottomNavigationBar: const AppFooter(currentIndex: 0),
    );
  }



  Future<void> _safeShare(BuildContext context) async {
    if (!context.mounted) return;

    // Let UI settle (VERY important on real devices)
    await Future.delayed(const Duration(milliseconds: 150));

    if (!context.mounted) return;

    Share.share(
      "https://foxscope.com/scope/685-214-751",
      subject: "Share Scope",
    );
  }
}
