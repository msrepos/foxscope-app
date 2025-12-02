import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;

  const AppHeader({
    super.key,
    required this.title,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,   // 🔘 white background
      elevation: 0,
      automaticallyImplyLeading: false, // We control leading manually
      titleSpacing: 0, // Ensures title starts right after leading widget


      //Done By Hagar
      leading: showBack
          ? IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        },
      )
          : null,


      title: Text(
        title,
        textAlign: TextAlign.left,
        style: const TextStyle(
          color: Colors.black, // 🔘 Title in black
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      centerTitle: false, // 🔘 Aligned LEFT

      actions: [
        IconButton(
          onPressed: () => context.go('/notifications'),
          icon: const Icon(Icons.notifications_none, color: Colors.black), // 🔘 Black icon
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
