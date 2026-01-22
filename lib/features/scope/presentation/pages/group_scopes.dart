import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/constants/app_env.dart';
import '../../../../core/widgets/widgets.dart';
import 'edit_scope.dart';
import 'scopeActions.dart';

class GroupScopes extends StatefulWidget {
  final int groupId;

  const GroupScopes({
    super.key,
    required this.groupId,
  });

  @override
  State<GroupScopes> createState() => _GroupScopesState();
}

class _GroupScopesState extends State<GroupScopes> {

  //region Var============================
  List<dynamic> scopes = [];
  Map<String, dynamic>? group; // group info
  bool isLoading = true;

  int page = 1;
  final int limit = 20;
  bool isLoadingMore = false;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();

  String loggedName = "Ahmed Mohamed";
  int? userId;
  //endregion

  @override
  void initState() {
    super.initState();
    loadLoggedUserName();
    fetchScopes();
    loadLoggedUserName();
  }


  Future<void> loadLoggedUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final userIdString = prefs.getString("userId");

    setState(() {
      loggedName = prefs.getString("user_name") ?? "Ahmed Mohamed";
      userId = userIdString != null ? int.tryParse(userIdString) : null;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        hasMore &&
        !isLoadingMore &&
        !isLoading) {
      fetchScopes();
    }
  }

  Future<void> fetchScopes({bool loadMore = false}) async {
    if (loadMore && (!hasMore || isLoadingMore)) return;

    setState(() {
      loadMore ? isLoadingMore = true : isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        setState(() {
          scopes = [];
          isLoading = false;
        });
        return;
      }

      final options = jsonEncode({
        "page": page,
        "limit": limit,
      });

      final url = Uri.parse(
        '${AppEnv.apiBaseUrl}/foxscope/groups/${widget.groupId}/scopes'
        '?options=$options',
      );

      debugPrint('📡 Fetching scopes page $page: $url');

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final List newScopes = decoded['scopes'] ?? [];
        final Map<String, dynamic>? groupInfo = decoded['group'];

        setState(() {
          group = groupInfo;

          if (loadMore) {
            scopes.addAll(newScopes);
          } else {
            scopes = newScopes;
          }

          hasMore = newScopes.length == limit;
          if (hasMore) page++;

          isLoading = false;
          isLoadingMore = false;
        });
      } else {
        setState(() {
          isLoading = false;
          isLoadingMore = false;
        });
      }
    } catch (e) {
      debugPrint('🔥 Error fetching scopes: $e');
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: "Scopes"),
      backgroundColor: const Color(0xFFF2F2F2),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔍 Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Widgets.instant.buildSearchBar(),
              ),
              Expanded(
                child: _buildMainContent(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (scopes.isEmpty) {
      return const Center(child: Text("No scopes found"));
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scroll) {
        if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200 &&
            !isLoadingMore &&
            hasMore) {
          fetchScopes(loadMore: true);
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        itemCount: scopes.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (_, index) {
          if (index >= scopes.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _buildScopeItem(context, scopes[index]);
        },
      ),
    );
  }

  Widget _buildScopeItem(BuildContext context, dynamic scope) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        final scopeIdent = scope['identifier'];
        final scopeId = scope['identifier'];

        debugPrint('➡️ Navigating to scopeId: $scopeId');
        debugPrint('➡️ Full route: /scope/$scopeId');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditScope(identifier: scopeIdent, id: scopeId.toString()),
          ),
        );

        //context.push('/scope/$scopeId');
      },

      // onTap: () {
      //   final scopeId = scope['id'];
      //
      //   context.push(
      //     '/edit-scope/$scopeId',
      //   );
      // },

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
                  child:
                      scope['image'] != null && scope['image'].toString().isNotEmpty
                          ? Image.network(
                              "${scope['image']}",
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
