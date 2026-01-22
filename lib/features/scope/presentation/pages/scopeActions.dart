import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foxscope/features/home/presentation/pages/qr_code_page.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../chat/presentation/pages/forward_page.dart';

class ScopeActions {
  static void openMap(BuildContext context, Map scope) async {
    final lat = scope['latitude'];
    final lng = scope['longitude'];

    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location not available")),
      );
      return;
    }

    final url =
        Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");

    if (await canLaunchUrl(url)) {
      launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  static void forward(BuildContext context, int scopeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ForwardPage(),
      ),
    );
  }

  static Future<void> share(
      int scopeId,
      BuildContext context,
      ) async {
    if (!context.mounted) return;

    await Future.delayed(const Duration(milliseconds: 150));
    if (!context.mounted) return;

    final box = context.findRenderObject();

    if (box is! RenderBox) {
      debugPrint("❌ RenderBox not found for Share");
      return;
    }

    Share.share(
      "https://foxscope.com/scope/$scopeId",
      subject: "Share Scope",
      sharePositionOrigin:
      box.localToGlobal(Offset.zero) & box.size,
    );
  }





  static void showQR(BuildContext context, int scopeId) {
    //context.push('/qr/$scopeId');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QrCodePage(),
      ),
    );
  }

  static void copy(BuildContext context, int scopeId) {
    final link = "https://foxscope.com/scope/$scopeId";
    Clipboard.setData(ClipboardData(text: link));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Link copied to clipboard"),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class ScopeActionsRow extends StatelessWidget {
  final Map scope;
  final bool card;

  const ScopeActionsRow({super.key, required this.scope, required this.card});

  int get scopeId => scope['id'];

  @override
  Widget build(BuildContext context) {
    return card
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _icon2("assets/images/go.png", () {
                ScopeActions.openMap(context, scope);
              }),
              _icon2("assets/images/forward.png", () {
                ScopeActions.forward(context, scopeId);
              }),
              Builder(
                builder: (iconContext) {
                  return _icon2(
                    "assets/images/share.png",
                        () {
                      ScopeActions.share(scopeId, iconContext);
                    },
                  );
                },
              ),

              _icon2("assets/images/qrcode.png", () {
                ScopeActions.showQR(context, scopeId);
              }),
              _icon2("assets/images/copy.png", () {
                ScopeActions.copy(context, scopeId);
              }),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _icon("assets/images/go.png", "Go", () {
                ScopeActions.openMap(context, scope);
              }),
              _icon("assets/images/forward.png", "Forward", () {
                ScopeActions.forward(context, scopeId);
              }),
              Builder(
                builder: (iconContext) {
                  return _icon(
                    "assets/images/share.png",
                    "Share",
                        () {
                      ScopeActions.share(scopeId, iconContext);
                    },
                  );
                },
              ),

              _icon("assets/images/qrcode.png", "QR", () {
                ScopeActions.showQR(context, scopeId);
              }),
              _icon("assets/images/copy.png", "Copy", () {
                ScopeActions.copy(context, scopeId);
              }),
            ],
          );
  }

  Widget _icon(String imagePath, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary, width: 1.3),
              color: Colors.white,
            ),
            child: Center(
              child: Image.asset(
                imagePath,
                width: 20,
                height: 20,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }


  Widget _icon2(String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary, width: 1.3),
          color: Colors.white,
        ),
        child: Center(
          child: Image.asset(
            imagePath,
            width: 20,
            height: 20,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
