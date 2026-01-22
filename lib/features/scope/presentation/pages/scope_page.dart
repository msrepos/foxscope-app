import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foxscope/features/chat/presentation/pages/forward_page.dart';
import 'package:foxscope/features/market/presentation/pages/paying_screen.dart'
    hide AppEnv;
import 'package:foxscope/features/scope/presentation/pages/add_to_group.dart';
import 'package:foxscope/features/scope/presentation/pages/renew_screen.dart';
import 'package:foxscope/features/scope/presentation/pages/scopeActions.dart';
import 'package:foxscope/features/scope/presentation/pages/select_scope_page.dart';
import 'package:foxscope/features/scope/presentation/pages/subscription.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/constants/app_env.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../notifications/presentation/pages/notification_detials_page.dart';
import 'edit_scope.dart';
import 'package:share_plus/share_plus.dart';

import 'group_scopes.dart';

class ScopePage extends StatefulWidget {
  final int initialTabIndex;
  final bool showScopeAddedPopup;

  const ScopePage({
    Key? key,
    this.initialTabIndex = 0,
    this.showScopeAddedPopup = false,
  }) : super(key: key);


  @override
  State<ScopePage> createState() => _ScopePageState();
}

class _ScopePageState extends State<ScopePage> {

  //region varibales
  List scopes = [];
  bool isLoading = true;
  late String loggedName ;
  int? userId;
  late int _activeTabIndex;
  String _groupName = "Egypt Restaurants";
  bool _showPopup = false;
  int _currentPage = 1;
  final int _limit = 40;
  final Set<int> _loadedScopeIds = {};
  bool _isFetchingMore = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();
  // Saved scopes state
  List savedScopes = [];
  int _savedCurrentPage = 1;
  final Set<int> _loadedSavedScopeIds = {};
  bool _isFetchingSaved = false;
  bool _hasMoreSaved = true;
  List<dynamic> groups = [];
  bool isLoadingGroups = false;
  //endregion

  @override
  void initState() {
    super.initState();
    _activeTabIndex = widget.initialTabIndex;
    loadLoggedUserName();
    fetchScopes();
    loadUserName();
    fetchGroups();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (_activeTabIndex == 0 && !_isFetchingMore && _hasMore) {
          fetchScopes(loadMore: true);
        }

        if (_activeTabIndex == 1 && !_isFetchingSaved && _hasMoreSaved) {
          fetchSavedScopes(loadMore: true);
        }
      }
    });

    if (widget.showScopeAddedPopup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _showPopup = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // ❌ block default pop behavior
      onPopInvoked: (didPop) {
        if (didPop) return;

        // ✅ ALWAYS go to Home
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
        );
      },
      child: Scaffold(
        appBar: const AppHeader(title: "Scopes"),
        backgroundColor: const Color(0xFFF2F2F2),
        body: Stack(
          children: [
            _buildMainContent(context),
            if (_showPopup)
              Widgets.instant.buildScopeAddedPopup(
                context: context,
                onContinue: () {
                  setState(() => _showPopup = false);
                },
                onShare: () {
                  Share.share("https://foxscope.com/scope/685-214-751");
                },
                onForward: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ForwardPage()),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  //region api
  Future<void> fetchScopes({bool loadMore = false}) async {
    if (_isFetchingMore) return;

    debugPrint("🟡 FETCH SCOPES | loadMore=$loadMore");

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        debugPrint("❌ Missing token");
        return;
      }

      if (loadMore) {
        _isFetchingMore = true;
        _currentPage++;
      } else {
        _currentPage = 1;
        _hasMore = true;
        scopes.clear();
        isLoading = true;
      }

      final options = jsonEncode({
        "page": _currentPage,
        "limit": _limit,
      });

      final url = Uri.parse(
        "${AppEnv.apiBaseUrl}/foxscope/my_scopes/all",
      ).replace(queryParameters: {
        "options": options,
      });

      debugPrint("🔗 REQUEST URL: $url");

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      debugPrint("📥 STATUS: ${response.statusCode}");
      debugPrint("📥 BODY: ${response.body}");

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          setState(() {
            final List newScopes = decoded.where((scope) {
              final id = scope['id'];
              if (id == null || _loadedScopeIds.contains(id)) {
                return false;
              }
              _loadedScopeIds.add(id);
              return true;
            }).toList();

            setState(() {
              scopes.addAll(newScopes);
              isLoading = false;
              _isFetchingMore = false;

              if (newScopes.length < _limit) {
                _hasMore = false;
              }
            });
            isLoading = false;
            _isFetchingMore = false;

            // 🔥 STOP PAGINATION WHEN NO MORE DATA
            if (decoded.length < _limit) {
              _hasMore = false;
            }
          });

          debugPrint(
            "✅ Page $_currentPage loaded | total scopes: ${scopes.length}",
          );
        } else {
          _hasMore = false;
        }
      } else {
        debugPrint("❌ FETCH FAILED");
        _isFetchingMore = false;
        isLoading = false;
      }
    } catch (e, stack) {
      debugPrint("🔥 EXCEPTION: $e");
      debugPrint("📛 STACK TRACE: $stack");

      _isFetchingMore = false;
      isLoading = false;
    }
  }

  Future<void> fetchSavedScopes({bool loadMore = false}) async {
    if (_isFetchingSaved || (!_hasMoreSaved && loadMore)) return;

    debugPrint("🟢 FETCH SAVED SCOPES | loadMore=$loadMore");

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        debugPrint("❌ Missing token");
        return;
      }

      if (loadMore) {
        _isFetchingSaved = true;
        _savedCurrentPage++;
      } else {
        _savedCurrentPage = 1;
        _hasMoreSaved = true;
        savedScopes.clear();
        _loadedSavedScopeIds.clear();
        isLoading = true;
      }

      final options = jsonEncode({
        "page": _savedCurrentPage,
        "limit": _limit,
      });

      final url = Uri.parse(
        "${AppEnv.apiBaseUrl}/foxscope/saved_scopes/all",
      ).replace(queryParameters: {
        "options": options,
      });

      debugPrint("🔗 SAVED REQUEST URL: $url");

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      debugPrint("📥 SAVED STATUS: ${response.statusCode}");
      debugPrint("📥 SAVED BODY: ${response.body}");

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          final List newSavedScopes = decoded.where((scope) {
            final id = scope['id'];
            if (id == null || _loadedSavedScopeIds.contains(id)) {
              return false;
            }
            _loadedSavedScopeIds.add(id);
            return true;
          }).toList();

          setState(() {
            savedScopes.addAll(newSavedScopes);
            isLoading = false;
            _isFetchingSaved = false;

            if (newSavedScopes.length < _limit) {
              _hasMoreSaved = false;
            }
          });

          debugPrint(
            "✅ Saved Page $_savedCurrentPage loaded | total saved: ${savedScopes.length}",
          );
        } else {
          _hasMoreSaved = false;
        }
      } else {
        debugPrint("❌ SAVED FETCH FAILED");
        _isFetchingSaved = false;
        isLoading = false;
      }
    } catch (e, stack) {
      debugPrint("🔥 SAVED EXCEPTION: $e");
      debugPrint("📛 SAVED STACK: $stack");

      _isFetchingSaved = false;
      isLoading = false;
    }
  }

  Future<void> loadLoggedUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      loggedName = prefs.getString("userName") ?? "Ahmed Mohamed"; // FIXED
      userId = Widgets.instant.getIntSafe(prefs, "userId");
    });
  }

  Future<void> fetchGroups() async {
    setState(() {
      isLoadingGroups = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('token');

      if (storedToken == null) {
        debugPrint('❌ No token found');
        setState(() {
          groups = [];
          isLoadingGroups = false;
        });
        return;
      }

      final url = Uri.parse("${AppEnv.apiBaseUrl}/foxscope/groups/list");

      debugPrint('📡 Fetching groups from: $url');

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $storedToken",
          "Accept": "application/json",
        },
      );

      debugPrint('📊 Response status: ${response.statusCode}');
      debugPrint('📨 Response body: ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        setState(() {
          groups = responseData is List ? responseData : [];
          isLoadingGroups = false;
        });

        debugPrint('✅ Loaded ${groups.length} groups');
      } else {
        debugPrint('⚠️ Failed to fetch groups: ${response.statusCode}');
        setState(() {
          groups = [];
          isLoadingGroups = false;
        });
      }
    } catch (e) {
      debugPrint('🔥 Error fetching groups: $e');
      setState(() {
        groups = [];
        isLoadingGroups = false;
      });
    }
  }

  Future<void> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      loggedName = prefs.getString('user_name') ?? "User";
    });
  }

  Future<bool> deleteGroup({
    required int groupId,
  }) async {
    debugPrint('🧨 DELETE GROUP FLOW STARTED | groupId=$groupId');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        debugPrint('🚨 TOKEN MISSING');
        return false;
      }

      final url = Uri.parse(
        '${AppEnv.apiBaseUrl}/foxscope/groups/$groupId/delete',
      );

      debugPrint('🌐 DELETE GROUP URL = $url');

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint('📡 STATUS = ${response.statusCode}');
      debugPrint('📦 BODY = ${response.body}');

      // ✅ ACCEPT ALL SUCCESS CODES
      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('✅ GROUP DELETED SUCCESSFULLY');
        return true;
      }

      debugPrint('❌ DELETE GROUP FAILED');
      return false;
    } catch (e, stack) {
      debugPrint('🔥 DELETE GROUP ERROR: $e');
      debugPrint('📛 STACK TRACE: $stack');
      return false;
    } finally {
      debugPrint('🏁 DELETE GROUP FLOW ENDED');
    }
  }

  Future<List<int>> fetchGroupScopeIds(int groupId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse(
      '${AppEnv.apiBaseUrl}/foxscope/groups/$groupId',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch group scopes');
    }

    final decoded = jsonDecode(response.body);

    return List<int>.from(
      decoded['scopes'].map((s) => s['id']),
    );
  }


  //todo the api must take only the name and the code will be edited later on
  Future<bool> editGroupName({
    required int groupId,
    required String name,
  }) async {
    debugPrint('✏️ EDIT GROUP NAME | groupId=$groupId | name=$name');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        debugPrint('🚨 TOKEN MISSING');
        return false;
      }

      final url = Uri.parse(
        '${AppEnv.apiBaseUrl}/foxscope/groups/$groupId/edit',
      );

      final request = http.MultipartRequest('POST', url)
        ..headers.addAll({
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        })
        ..fields['data'] = jsonEncode({
          "name": name, // ✅ ONLY name, no scopes
        });

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint('📡 STATUS = ${response.statusCode}');
      debugPrint('📦 BODY = $responseBody');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('✅ GROUP NAME UPDATED');
        return true;
      }

      debugPrint('❌ EDIT GROUP FAILED');
      return false;
    } catch (e, stack) {
      debugPrint('🔥 EDIT GROUP ERROR: $e');
      debugPrint('📛 STACK TRACE: $stack');
      return false;
    }
  }

  //endregion

  Widget _buildMainContent(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopMenu(context),
              const SizedBox(height: 16),
              Widgets.instant.buildSearchBar(),
              const SizedBox(height: 16),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildTabContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildScopeItem(BuildContext context, dynamic scope) {
    final String name = scope['friendly_name'] ?? '';
    final String? imageUrl = scope['image'];

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        final identifier = scope['identifier'];
        final id = scope['id'];
        debugPrint('➡️ Navigating to identifier: $identifier');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditScope(identifier: identifier, id: id.toString()),
          ),
        );
        // context.push('/scope/$identifier/$id');
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl,
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
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF000080),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            loggedName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
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
              child: Divider(height: 1),
            ),
            ScopeActionsRow(scope: scope, card: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedScopeCard(BuildContext context, dynamic scope) {
    return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final scopeId = scope['id'];

          debugPrint('➡️ Navigating to scopeId: $scopeId');
          debugPrint('➡️ Full route: /scope/$scopeId');

          context.push('/savedScope/$scopeId');
        },
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
                      // Remove InkWell, add GestureDetector around specific parts
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            final scopeId = scope['id'];
                            debugPrint('➡️ Navigating to scopeId: $scopeId');
                            debugPrint('➡️ Full route: /scope/$scopeId');
                            context.push('/savedScope/$scopeId');
                          },
                          child: Row(
                            children: [
                              Text(
                                scope['name'] ?? "",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.bookmark,
                                size: 26,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
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
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(
                  height: 1,
                  color: Colors.grey,
                ),
              ),
              ScopeActionsRow(scope: scope, card: true),
            ],
          ),
        ));
  }

  Widget _buildTabContent() {
    switch (_activeTabIndex) {
      case 0:
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (scopes.isEmpty) {
          return const Center(child: Text("No scopes found"));
        }
        return ListView.builder(
          controller: _scrollController,
          itemCount: scopes.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < scopes.length) {
              return _buildScopeItem(context, scopes[index]);
            }

            // 🔄 Bottom loader
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        );


      case 1: // Saved
        if (isLoading && savedScopes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (savedScopes.isEmpty) {
          return const Center(child: Text("No saved scopes found"));
        }

        return ListView.builder(
          controller: _scrollController,
          itemCount: savedScopes.length + (_hasMoreSaved ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < savedScopes.length) {
              return _buildSavedScopeCard(context, savedScopes[index]);
            }

            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            );
          },
        );

      case 2: // Groups (button pinned at bottom)
        return Column(
          children: [
            Expanded(
              child: isLoadingGroups
                  ? const Center(child: CircularProgressIndicator())
                  : groups.isEmpty
                  ? const Center(
                child: Text(
                  "No groups found",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : RefreshIndicator(
                onRefresh: fetchGroups,
                child: ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    return _buildGroupCard(
                      group['name'] ?? 'Unnamed Group',
                      "${group['scope_count'] ?? 0} scopes",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GroupScopes(
                              groupId: group['id'],
                            ),
                          ),
                        );
                      }, groupId:  group['id'],
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0,16,16,40),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    // Navigate and wait for result
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SelectScopePage(
                          source: SelectScopeSource.createGroup,
                        ),
                      ),
                    );

                    // Refresh groups list after creating a new group
                    if (result != null && mounted) {
                      fetchGroups();
                    }
                  },
                  child: const Text(
                    'Create New Group',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );

      case 3: // Status
        return ListView(
          children: [
            Widgets.instant.buildStatusItem(context),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTopMenu(BuildContext context) {
    final items = ["My Scope", "Saved", "Groups", "Status"];
    final icons = [
      Icons.send,
      Icons.bookmark,
      Icons.layers,
      Icons.circle_rounded
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final bool isActive = index == _activeTabIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _activeTabIndex = index; // 🔹 switch tab instead of navigation
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icons[index],
                      size: 20,
                      color: isActive ? Colors.white : AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      items[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGroupCard(
      String title,
      String description, {
        required int groupId,
        required VoidCallback onTap,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap, // 👈 whole card tap
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.more_horiz,
                  color: AppColors.primary,
                ),
                onPressed: () {
                  _showOptionsDialog(groupId: groupId);
                },
              ),

            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsDialog({
    required int groupId,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Widgets.instant.option(
                text: 'Edit Group Name',
                onTap: () async {
                  Navigator.of(context).pop(); // close options menu first

                  final result = await showEditFieldDialog(
                    context: context,
                    title: "Edit Group Name",
                    fieldType: EditFieldType.text,
                    initialText: _groupName,
                  );

                  if (result is! String || result.trim().isEmpty) return;

                  final newName = result.trim();

                  final success = await editGroupName(
                    groupId: groupId,
                    name: newName,
                  );

                  if (!mounted) return;

                  if (success) {
                    // ✅ update local UI immediately
                    setState(() {
                      _groupName = newName;
                      final index = groups.indexWhere((g) => g['id'] == groupId);
                      if (index != -1) {
                        groups[index]['name'] = newName;
                      }
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Group name updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to update group name'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),

              const Divider(height: 0),
              Widgets.instant.option(
                text: 'Add to Group',
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SelectScopePage(
                        source: SelectScopeSource.addToGroup,
                      ),
                    ),
                  );
                },
              ),
              const Divider(height: 0),
              Widgets.instant.option(
                text: 'Delete Group',
                onTap: () {
                  final parentContext = context; // ✅ save page context
                  Navigator.of(context).pop();   // close options menu

                  showDialog(
                    context: parentContext,
                    barrierDismissible: false,
                    builder: (dialogContext) => AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      titlePadding: EdgeInsets.zero,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      title: Column(
                        children: const [
                          SizedBox(height: 24),
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.primary,
                            child: Icon(
                              Icons.info_outline,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Disclaimer",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      content: const Text(
                        "Are you sure you want to delete this Group?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      actions: [
                        Row(
                          children: [
                            // DELETE
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  final success = await deleteGroup(groupId: groupId);

                                  if (!dialogContext.mounted) return;
                                  Navigator.of(dialogContext).pop(); // close dialog

                                  if (!mounted) return;

                                  if (success) {
                                    setState(() {
                                      groups.removeWhere((g) => g['id'] == groupId);
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Group deleted successfully'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Failed to delete group'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // CANCEL
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                  side: const BorderSide(color: Colors.grey, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                },
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<dynamic> showEditFieldDialog({
    required BuildContext context,
    required String title,
    required EditFieldType fieldType,
    String? initialText,
    List<String>? options,
    String? initialDropdownValue,
    List<String>? initialSelectedValues,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        return _EditFieldDialog(
          title: title,
          fieldType: fieldType,
          initialText: initialText,
          options: options,
          initialDropdownValue: initialDropdownValue,
          initialSelectedValues: initialSelectedValues,
        );
      },
    );
  }
}

//=============================================================

enum EditFieldType {
  text,
  dropdown,
  multiSelect,
}

class _EditFieldDialog extends StatefulWidget {
  final String title;
  final EditFieldType fieldType;
  final String? initialText;
  final List<String>? options;
  final String? initialDropdownValue;
  final List<String>? initialSelectedValues;

  const _EditFieldDialog({
    super.key,
    required this.title,
    required this.fieldType,
    this.initialText,
    this.options,
    this.initialDropdownValue,
    this.initialSelectedValues,
  });

  @override
  State<_EditFieldDialog> createState() => _EditFieldDialogState();
}

class _EditFieldDialogState extends State<_EditFieldDialog> {
  late TextEditingController _textController;
  String? _selectedDropdown;
  late Set<String> _selectedMulti;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText ?? "");
    _selectedDropdown = widget.initialDropdownValue;
    _selectedMulti = {...?widget.initialSelectedValues};
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            // Body based on type
            _buildField(),

            const SizedBox(height: 20),

            // Buttons
            Row(
              children: [
                // Save
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      dynamic result;

                      switch (widget.fieldType) {
                        case EditFieldType.text:
                          result = _textController.text;
                          break;
                        case EditFieldType.dropdown:
                          result = _selectedDropdown;
                          break;
                        case EditFieldType.multiSelect:
                          result = _selectedMulti.toList();
                          break;
                      }

                      Navigator.pop(context, result);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Save",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Cancel
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, null),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.black87),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField() {
    switch (widget.fieldType) {
      case EditFieldType.text:
        return TextField(
          controller: _textController,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        );

      case EditFieldType.dropdown:
        final items = widget.options ?? [];
        return DropdownButtonFormField<String>(
          value: _selectedDropdown ?? (items.isNotEmpty ? items.first : null),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ))
              .toList(),
          onChanged: (val) {
            setState(() {
              _selectedDropdown = val;
            });
          },
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        );

      case EditFieldType.multiSelect:
        final options = widget.options ?? [];
        return SizedBox(
          height: 200, // in case there are many options
          child: ListView(
            children: options.map((opt) {
              final selected = _selectedMulti.contains(opt);
              return CheckboxListTile(
                value: selected,
                title: Text(opt),
                dense: true,
                onChanged: (v) {
                  setState(() {
                    if (v == true) {
                      _selectedMulti.add(opt);
                    } else {
                      _selectedMulti.remove(opt);
                    }
                  });
                },
              );
            }).toList(),
          ),
        );
    }
  }
}
