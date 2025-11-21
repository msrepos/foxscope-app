import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/app_header.dart';

class SendPage extends StatelessWidget {
  const SendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: "Send Scope"),
      backgroundColor: const Color(0xFFF2F2F2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // 🔹 Search Bar
            _buildSearchBar(),
            const SizedBox(height: 20),

            // 🔹 My Scope Section
            const Text(
              "My Scope",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildScopeItem(
              background: const Color(0xFFE8E8E8), // light grey
              usernameColor: AppColors.primary,
            ),

            const SizedBox(height: 25),

            // 🔹 Saved Scope Section
            const Text(
              "Saved Scope",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildScopeItem(
              background: Colors.white, // normal white
              usernameColor: AppColors.primary,
            ),

            const SizedBox(height: 30),

            // 🔹 My Groups
            const Text(
              "My Groups",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            _buildGroupCard(
              title: "Egypt Resturant",
              scopesCount: 2,
            ),
            const SizedBox(height: 14),
            _buildGroupCard(
              title: "Qatar Public",
              scopesCount: 5,
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
      bottomNavigationBar: const AppFooter(currentIndex: 0),
    );
  }

  // 🔹 Search bar
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: Colors.grey),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search scopes...",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Scope card (reusable)
  Widget _buildScopeItem({
    required Color background,
    required Color usernameColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/saved.png',
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
                    const Text(
                      "685-214-751.foxscope",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: usernameColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "bigmomo",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.push_pin, size: 26),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Icon(Icons.map, size: 26),
              Icon(Icons.arrow_forward, size: 26),
              Icon(Icons.share, size: 26),
              Icon(Icons.qr_code, size: 26),
              Icon(Icons.copy, size: 26),
            ],
          ),
        ],
      ),
    );
  }

  // 🔹 Group Card
  Widget _buildGroupCard({
    required String title,
    required int scopesCount,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, height: 1.3),
          ),
          const SizedBox(height: 6),
          Text(
            "$scopesCount scopes",
            style: const TextStyle(
                fontSize: 14, color: Colors.grey, height: 1.2),
          ),
        ],
      ),
    );
  }
}
