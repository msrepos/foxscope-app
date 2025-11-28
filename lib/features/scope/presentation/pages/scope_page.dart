import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/constants/app_env.dart';


class ScopePage extends StatefulWidget {
  const ScopePage({super.key});

  @override
  State<ScopePage> createState() => _ScopePageState();
}

class _ScopePageState extends State<ScopePage> {
  List scopes = [];
  bool isLoading = true;

  String loggedName = "User"; // ✅ FIXED: define loggedName
  int? userId;

  @override
  void initState() {
    super.initState();
    loadLoggedUserName();
    fetchScopes();
  }

  Future<void> loadLoggedUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      loggedName = prefs.getString("userName") ?? "User"; // FIXED
      userId = prefs.getInt("userId"); // also load userID here
    });
  }

  Future<void> fetchScopes() async {
    try {
      final prefs = await SharedPreferences.getInstance(); // ✅ FIXED
      userId = prefs.getInt('userId');

      if (userId == null) {
        setState(() {
          scopes = [];
          isLoading = false;
        });
        return;
      }

      final url = "${AppEnv.apiBaseUrl}/user-scope/$userId";
      final response = await http.get(Uri.parse(url));

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          scopes = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          scopes = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        scopes = [];
        isLoading = false;
      });
    }
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
            _buildTopMenu(context),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),

            isLoading
                ? const Center(child: CircularProgressIndicator())
                : scopes.isEmpty
                    ? const Center(child: Text("No scopes found"))
                    : Column(
                        children: scopes.map((scope) => _buildScopeItem(scope)).toList(),
                      ),
          ],
        ),
      ),
      bottomNavigationBar: const AppFooter(currentIndex: 0),
    );
  }

  // 🔹 Horizontal menu
  Widget _buildTopMenu(BuildContext context) {
    final items = ["My Scope", "Saved", "Groups", "Status"];
    final menuRoutes = ['/scope', '/saved', '/groups', '/status'];
    const int activeIndex = 0;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final bool isActive = index == activeIndex;

          return GestureDetector(
            onTap: () => context.go(menuRoutes[index]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  items[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          );
        },
      ),
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

  // 🔹 Build dynamic scope card
  Widget _buildScopeItem(dynamic scope) {
    return Container(
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
                child: Image.network(
                  "http://sit.foxscope.com/imgs/${scope['img']}",
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
                    Text(
                      scope['code'] ?? "",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        loggedName, // 🟢 FIXED
                        style: const TextStyle(color: Colors.white, fontSize: 12),
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
}
