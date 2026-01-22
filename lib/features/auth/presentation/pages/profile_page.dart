import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_env.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../chat/presentation/pages/chat_details.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //region Variables
  String userName = "User";
  bool _isStatsLoading = true;
  int scopes = 0;
  int savedScopes = 0;
  int groups = 0;
  int primeScopes = 0;
  int freeScopes = 0;
  bool isLoading = true;
  String? userId;
  Map<String, dynamic>? scopeDetails;
  String? userImage;
  Map<String, dynamic>? pinnedScope;

  //endregion

  @override
  void initState() {
    super.initState();
    _loadProfileMinDetails();
    _fetchInformationCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: "Profile"),
      backgroundColor: const Color(0xFFF2F2F2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileBox(),
            const SizedBox(height: 16),
            _buildLinksBox(context),
            const SizedBox(height: 16),
            _buildStatsBox(),
          ],
        ),
      ),
      bottomNavigationBar: const AppFooter(currentIndex: 2),
    );
  }

  Widget _buildProfileBox() {
    // Add a loading state check
    if (isLoading || userImage == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(0, 10, 24, 10),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 2, 2),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.orange,
                        width: 3.0,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      child: ClipOval(
                        child: userImage!.startsWith(
                                'http') // ✅ Safe now because we checked above
                            ? Image.network(
                                userImage!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  'assets/images/profile_sample.png',
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.asset(
                                'assets/images/profile_sample.png',
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  userName,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.ios_share, color: Colors.black),
              iconSize: 20,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChatDetailsPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinksBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildLinkItem(Icons.edit, "Edit Profile", () {
            context.push('/editProfile'); // ✅ keep history
          }),
          _buildDivider(),
          _buildLinkItem(Icons.lock_reset, "Change Password", () {
            context.push('/changePasswordS1'); // ✅ keep history
          }),
          _buildDivider(),
          _buildLinkItem(Icons.email, "Change Email Address", () {
            context.push('/changeEmailS1'); // ✅ keep history
          }),
        ],
      ),
    );
  }

  Widget _buildLinkItem(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1),
    );
  }

  //region Stats section==========================

  Future<void> _loadProfileMinDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        debugPrint('❌ No token found');
        setState(() => isLoading = false);
        return;
      }

      final url = Uri.parse(
        '${AppEnv.apiBaseUrl}/foxscope/profile/min_details',
      );

      debugPrint('👤 Fetching profile min details');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        debugPrint('✅ Profile loaded: $decoded');

        setState(() {
          userName =
              '${decoded['first_name'] ?? ''} ${decoded['last_name'] ?? ''}'
                  .trim();

          userImage = decoded['image'] ?? 'assets/images/profile_sample.png';

          isLoading = false;
        });
      } else {
        debugPrint('❌ Profile load failed: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('❌ Profile error: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _fetchInformationCount() async {
    debugPrint("🔵 [InformationCount] API call started");

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token'); // 🔑 use your real auth key

      if (token == null) {
        debugPrint("❌ No auth token found");
        return;
      }

      final response = await http.get(
        Uri.parse(
          "https://api.foxscope.com/foxscope/profile/information_count",
        ),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      debugPrint("📡 Status: ${response.statusCode}");
      debugPrint("📨 Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          scopes = data["scopes"] ?? 0;
          savedScopes = data["saved_scopes"] ?? 0;
          groups = data["groups"] ?? 0;
          primeScopes = data["prime_scopes"] ?? 0;
          freeScopes = data["free_scopes"] ?? 0;
          _isStatsLoading = false;
        });
      } else {
        debugPrint("⚠️ Failed to fetch counts");
        _isStatsLoading = false;
      }
    } catch (e) {
      debugPrint("🔥 Error fetching stats: $e");
      _isStatsLoading = false;
    }
  }

  Widget _buildStatsBox() {
    if (_isStatsLoading) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Widgets.instant
                      .buildStatCard("My Scope", scopes.toString())),
              const SizedBox(width: 12),
              Expanded(
                  child: Widgets.instant
                      .buildStatCard("Free", freeScopes.toString())),
              const SizedBox(width: 12),
              Expanded(
                  child: Widgets.instant
                      .buildStatCard("Prime", primeScopes.toString())),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Widgets.instant.buildStatCard(
                  "Groups",
                  groups.toString(),
                  big: true,
                  primary: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Widgets.instant.buildStatCard(
                  "Saved",
                  savedScopes.toString(),
                  big: true,
                  primary: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
