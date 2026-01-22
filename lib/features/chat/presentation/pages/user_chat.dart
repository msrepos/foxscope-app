import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../scope/presentation/pages/scopeActions.dart';

class UserChatPage extends StatefulWidget {
  const UserChatPage({super.key});

  @override
  State<UserChatPage> createState() => _UserChatPageState();
}

class _UserChatPageState extends State<UserChatPage> {
  int _activeTab = 0;
  final Map<String, dynamic> _mockScope = {
    'id': 111,
    'name': '111-111-111.foxScope',
    'img': null,
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Chat",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 16),

          /// Avatar
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.primary,
            child: const CircleAvatar(
              radius: 45,
              backgroundImage: AssetImage('assets/images/mahmoud.png'),
            ),
          ),

          const SizedBox(height: 12),

          /// Name
          const Text(
            "Ahmed Temraz",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          /// Username
          const Text(
            "A.Temraz",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 16),

          /// Tabs
          _buildTabs(),

          const SizedBox(height: 16),

          /// Tab Content
          Expanded(
            child: _activeTab == 0
                ? _buildSavedScopes()
                : _buildSharedLocations(),
          ),
        ],
      ),

      bottomNavigationBar: const AppFooter(currentIndex: 0),
    );
  }

  // ================= Tabs =================

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        children: [
          _tabButton("Saved Scopes", 0),
          _tabButton("Shared Locations", 1),
        ],
      ),
    );
  }

  Widget _tabButton(String text, int index) {
    final bool isActive = _activeTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ================= Saved Scopes =================

  Widget _buildSavedScopes() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        ScopeCard(scope: _mockScope, loggedName: "Ahmed Mohamed",),
        ScopeCard(scope: _mockScope, loggedName: "Ahmed Mohamed",),
      ],
    );
  }

  // ================= Shared Locations =================

  Widget _buildSharedLocations() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _sharedLocationCard(
          "https://www.figma.com/design/WdDyJQwPSStcDpi3Q0656j/Fox-Scope-Mobile-App--Copy-?node-id=5260-7340&t=VP0nbHEaHlE9BkX0-0",
          "1:10 PM",
          true,
        ),
        _sharedLocationCard(
          "https://www.figma.com/design/WdDyJQwPSStcDpi3Q0656j/Fox-Scope-Mobile-App--Copy-?node-id=5260-7340&t=VP0nbHEaHlE9BkX0-0",
          "1:10 PM",
          false,
        ),
      ],
    );
  }

  Widget _sharedLocationCard(String text, String time, bool showButton) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          if (showButton)
            const Text(
              "View Message",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (!showButton)
            const Text(
              "Hey Check this place out, it's amazing.",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              time,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= Small Action Icon =================


class ScopeCard extends StatelessWidget {
  final Map<String, dynamic> scope;
  final String loggedName;
  final bool enableNavigation;

  const ScopeCard({
    super.key,
    required this.scope,
    required this.loggedName,
    this.enableNavigation = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: enableNavigation
          ? () {
        final scopeId = scope['id'];
        debugPrint('➡️ Navigating to scopeId: $scopeId');
        context.push('/scope/$scopeId');
      }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: scope['img'] != null &&
                      scope['img'].toString().isNotEmpty
                      ? Image.network(
                    "http://sit.foxscope.com/imgs/${scope['img']}",
                    height: 55,
                    width: 55,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Image.asset(
                        'assets/images/profile_sample.png',
                        height: 55,
                        width: 55,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                      : Image.asset(
                    'assets/images/user.png',
                    height: 55,
                    width: 55,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            scope['name'] ?? "",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            FontAwesomeIcons.solidBookmark,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 50),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF000080),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              loggedName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(
                height: 1,
                color: Colors.white,
              ),
            ),
            ScopeActionsRow(scope: scope, card: true),
          ],
        ),
      ),
    );
  }
}


