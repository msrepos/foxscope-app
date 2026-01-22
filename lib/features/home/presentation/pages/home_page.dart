import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foxscope/features/scope/presentation/pages/edit_scope.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/constants/app_env.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/widgets/map.dart';
import '../../../../main.dart';
import '../../../chat/presentation/pages/chat_details.dart';
import '../../../chat/presentation/pages/forward_page.dart';
import '../../../scope/presentation/pages/map_page.dart';
import '../../../scope/presentation/pages/scopeActions.dart';
import 'current_location.dart';

class HomeScreen extends StatefulWidget {
  final String? userId; // Can be null when returning back to home

  const HomeScreen({super.key, this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, RouteAware {
  //region varibales
  bool isLoading = true;
  String? userId;
  Map<String, dynamic>? scopeDetails;
  String userName = "User";
  String userImage = 'assets/images/profile_sample.png';
  Map<String, dynamic>? pinnedScope;
  static const double headerWithoutPin = 160;
  static const double headerWithPin = 250;
  bool isPinnedScopeLoading = false;

  //endregion

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetch();
    _loadProfileMinDetails();
    _loadPinnedScope();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    debugPrint('🔄 HomeScreen resumed → refreshing pinned scope');
    _refreshPinnedScope();
  }

  Future<void> _refreshPinnedScope() async {
    setState(() {
      isPinnedScopeLoading = true;
    });

    await _loadPinnedScope();

    if (mounted) {
      setState(() {
        isPinnedScopeLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          width: double.infinity,
                          // height: pin ? 250 : 150,
                          height: pinnedScope != null
                              ? headerWithPin
                              : headerWithoutPin,
                          // 250 when pinned, 180 when not
                          color: Colors.black87,
                          alignment: Alignment.topCenter,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),

                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  context.go('/profile');
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 45,
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage: userImage.startsWith('http')
                                        ? NetworkImage(userImage)
                                        : const AssetImage('assets/images/profile_sample.png')
                                    as ImageProvider,
                                  ),

                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(  // ✅ CORRECT - Expanded directly under Row
                                child: GestureDetector(  // ✅ GestureDetector inside Expanded
                                  onTap: () {
                                    context.go('/profile');
                                  },
                                  child: Text(
                                    isLoading ? "Loading..." : userName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed:() {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ChatDetailsPage(),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.ios_share_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: -15,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child:
                                (pinnedScope != null && scopeDetails != null)
                                    ? _buildPinnedScopeCard(context)
                                    : const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: SizedBox(height: pinnedScope != null ? 40 : 10),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MapScopePage(
                            returnLocationOnly: false, // default
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'CREATE NEW SCOPE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // GRID MENU
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.3,
                  children: [
                    Widgets.instant.buildGridItem(
                      "assets/images/send_scope.png",
                      false,
                      'Send Scope',
                      onTap: () => context.go('/send'),
                    ),
                    Widgets.instant.buildGridItem(
                        "assets/images/my_scopes.png", false, 'My Scope',
                        onTap: () => context.push(
                              '/scopes',
                              extra: 0,
                            )),
                    Widgets.instant.buildGridItem(
                        "assets/images/scan_scope.png", false, 'Scan Scope',
                        onTap: () => context.go('/scan')),
                    Widgets.instant.buildGridItem(
                        "assets/images/my_groups.png", false, 'My Groups',
                        onTap: () => context.push(
                              '/scopes',
                              extra: 2,
                            )),
                    Widgets.instant.buildGridItem(
                        "assets/images/favourit.png", false, 'Favourites',
                        onTap: () => context.push('/chat', extra: 1)),
                    Widgets.instant.buildGridItem(
                        "assets/images/market.png", false, 'Marketplace',
                        onTap: () => context.go('/market')),
                    Widgets.instant.buildGridItem(
                        "assets/images/chat.png", true, 'Chat',
                        onTap: () => context.push('/chat', extra: 0)),
                    Widgets.instant.buildGridItem(
                        "assets/images/notification.png", true, 'Notifications',
                        onTap: () => context.go('/notifications'),
                        hasBadge: true),
                    Widgets.instant.buildGridItem(
                        "assets/images/status.png", true, 'Status',
                        onTap: () => context.push(
                              '/scopes',
                              extra: 3,
                            ),
                        hasBadge: true),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Current location button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: replace with your real current location
                    final currentLocation = GeoLocation(
                      lat: 30.0444,
                      lng: 31.2357,
                      name: 'Qatar',
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CurrentLoctionPage(
                          selectedLocation: currentLocation,
                        ),
                      ),
                    );

                    // If you prefer GoRouter instead of Navigator:
                    // context.push(
                    //   '/current-location',
                    //   extra: currentLocation,
                    // );
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.my_location_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Current Location',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 34),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
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

  //region API===================================
  Future<void> _loadPinnedScope() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return;

      final url = Uri.parse(
        '${AppEnv.apiBaseUrl}/foxscope/scope/get_pinned_scope',
      );

      debugPrint('📌 Fetching pinned scope: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint('📥 Pinned status: ${response.statusCode}');
      debugPrint('📥 Pinned body: ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);

        setState(() {
          pinnedScope = decoded;
          scopeDetails = decoded; // reuse existing UI logic
        });
      } else {
        setState(() {
          pinnedScope = null;
          scopeDetails = null;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading pinned scope: $e');
      setState(() {
        pinnedScope = null;
        scopeDetails = null;
      });
    }
  }

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

          userImage = decoded['image'] ??
              'assets/images/profile_sample.png';

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

  Future<void> fetchScopeDetails(int scopeId) async {
    try {
      debugPrint('🌐 Fetching scope from: ${AppEnv.apiBaseUrl}/scope/$scopeId');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = Uri.parse('${AppEnv.apiBaseUrl}/scope/$scopeId');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        debugPrint('📦 Scope API response: $decoded');

        setState(() {
          scopeDetails = decoded;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load scope');
      }
    } catch (e) {
      debugPrint('❌ Error loading scope: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadUserIdAndFetch() async {
    final prefs = await SharedPreferences.getInstance();

    // Save the passed userId if coming from login
    if (widget.userId != null) {
      await prefs.setString('userId', widget.userId! );
      userId = widget.userId;
    } else {
      // Load cached userId when navigating back
      userId = prefs.getString('userId');
    }

    // If found, fetch user info
    if (userId != null) {
      await fetchUserInfo(userId!);
    } else {
      // Should never happen unless token removed
      setState(() {
        userName = userName;
        isLoading = false;
      });
    }
  }

  Future<void> fetchUserInfo(String id) async {
    try {
      final response = await http.get(
        Uri.parse("${AppEnv.apiBaseUrl}/users/$id"),
        headers: {
          "Accept": "application/json",
          // "Authorization": "Bearer $token", // add if required
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          userName = data["name"] ?? userName;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  //endregion

  Widget _buildPinnedScopeCard(BuildContext context) {
    if (isLoading || scopeDetails == null || pinnedScope == null) {
      return const SizedBox.shrink();
    }

    final scope = scopeDetails!;

    return GestureDetector(
      onTap: () {
        debugPrint('➡️ Navigating to pinned scopeId: $pinnedScope');
        final identifier = pinnedScope!['identifier'];
        final id = pinnedScope!['id'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditScope(identifier: identifier, id: id.toString()),
          ),
        );
        //context.push('/scope/$identifier');
      },
      child: Container(
        key: const ValueKey('pinnedScope'),
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: (scope['image'] != null &&
                      scope['image'] is String &&
                      (scope['image'] as String).isNotEmpty)
                      ? Image.network(
                    scope['image'], // ✅ USE DIRECT URL
                    height: 55,
                    width: 55,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/profile_sample.png',
                      height: 55,
                      width: 55,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Image.asset(
                    'assets/images/profile_sample.png',
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
                            scope['friendly_name'] ?? "",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          const Icon(FontAwesomeIcons.thumbtack, size: 20),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 50),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF000080),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              userName,
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
