import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/app_header.dart';


class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: "Camera"),
      backgroundColor: Colors.black,
      bottomNavigationBar: const AppFooter(currentIndex: 0),
      body: Center(
        child: Image.asset(
          'assets/images/scan.png',
          width: 180,
          height: 180,
        ),
      ),
    );
  }
}
