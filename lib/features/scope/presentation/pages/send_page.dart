import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foxscope/features/scope/presentation/pages/scopeActions.dart';
import 'package:foxscope/features/scope/presentation/pages/select_scope_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_env.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../chat/presentation/pages/forward_page.dart';
import 'package:share_plus/share_plus.dart';
import 'group_scopes.dart';

class SendPage extends StatefulWidget {
  const SendPage({super.key});

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  //region variables
  String _groupName = "Egypt Restaurants";
  String loggedName = "Ahmed Mohamed";
  List scopes = [];
  bool isLoadingSaved = true;
  List<dynamic> groups = [];
  int? userId;
  bool _isFetchingMore = false;
  int _currentPage = 1;
  bool _hasMore = true;
  final int _limit = 40;
  final Set<int> _loadedScopeIds = {};
  bool isLoading = true;
  final Set<String> selectedScopeIds = {};
  final Set<String> selectedGroupNames = {};
  bool get hasGroupSelected => selectedGroupNames.isNotEmpty;
  bool get hasMultipleScopes => selectedScopeIds.length > 1;
  bool get canShare => selectedScopeIds.length == 1 && !hasGroupSelected;
  bool get hasSelection =>
      selectedScopeIds.isNotEmpty || selectedGroupNames.isNotEmpty;
  bool isLoadingGroups = false;
  List savedScopes = [];
  int _savedCurrentPage = 1;
  final Set<int> _loadedSavedScopeIds = {};
  bool _isFetchingSaved = false;
  bool _hasMoreSaved = true;
  //endregion


  //region API==========================
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

  Future<void> fetchSavedScopes({bool loadMore = false}) async {
    if (!loadMore) {
      isLoadingSaved = true;
    }

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
            isLoadingSaved = false;
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
  //endregion

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

            // 🔹 Search Bar=====================
            _buildSearchBar(),
            const SizedBox(height: 20),

            // 🔹 My Scope Section===================
            const Text(
              "My Scope",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            if (isLoading && scopes.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (scopes.isEmpty)
              const Text("No scopes available")
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: scopes.length,
                itemBuilder: (context, index) {
                  return _buildScopeItem(scopes[index]);
                },
              ),

            const SizedBox(height: 25),


            // 🔹 Saved Scope Section================
            const Text(
              "Saved Scope",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            if (isLoading && savedScopes.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (savedScopes.isEmpty)
              const Text("No saved scopes")
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: savedScopes.length,
                itemBuilder: (context, index) {
                  return _buildSavedScopeCard(savedScopes[index]);
                },
              ),

            const SizedBox(height: 30),


            // 🔹 My Groups===========================
            const Text(
              "My Groups",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            if (isLoadingGroups)
              const Center(child: CircularProgressIndicator())
            else if (groups.isEmpty)
              const Text(
                "No groups found",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              )
            else
              RefreshIndicator(
                onRefresh: fetchGroups,
                child: ListView.builder(
                  shrinkWrap: true,
                  // ✅ IMPORTANT
                  physics: const NeverScrollableScrollPhysics(),
                  // ✅ IMPORTANT
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    return _buildGroupCard(
                      group['name'] ?? 'Unnamed Group',
                      "${group['scope_count'] ?? 0} scopes",
                      groupId: group['id'],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GroupScopes(groupId: group['id']),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: hasSelection
          ? Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (canShare)
                    IconButton(
                      icon: const Icon(
                          size: 30, Icons.share, color: AppColors.primary),
                      onPressed: () {
                        debugPrint("🔗 SHARE ${selectedScopeIds.first}");
                        Share.share(
                            "https://foxscope.com/scope/${selectedScopeIds.first}");
                      },
                    ),
                  const Spacer(),
                  Text(
                    "${selectedScopeIds.length + selectedGroupNames.length} Selected",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      debugPrint("➡️ FORWARD");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ForwardPage(),
                        ),
                      );
                    },
                    icon: Image.asset(
                      'assets/images/forward.png', // 🔁 replace with your image path
                      width: 30,
                      height: 30,
                      color: AppColors
                          .primary, // optional (works only if image is monochrome)
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  @override
  void initState() {
    super.initState();
    fetchScopes();
    fetchGroups();
    fetchSavedScopes();
  }

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

  Widget _buildScopeItem(Map<String, dynamic> scope) {
    final scopeId = scope['id'].toString();
    final isSelected = selectedScopeIds.contains(scopeId);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedScopeIds.remove(scopeId);
          } else {
            selectedScopeIds.add(scopeId);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade700 : Colors.grey.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: _scopeCardContent(
          scope,
          isSaved: false, // ✅ normal scope
        ),
      ),
    );
  }

  Widget _scopeCardContent(
    dynamic scope, {
    required bool isSaved,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _scopeImage(scope),
            ),

            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          scope['friendly_name'] ?? "",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isSaved
                                ? AppColors.primary // 🟠 saved = orange
                                : Colors.black, // ⚫ normal = black
                          ),
                        ),
                      ),

                      // 🔖 Bookmark ONLY for saved scopes
                      if (isSaved)
                        const Icon(
                          Icons.bookmark,
                          color: AppColors.primary,
                          size: 24,
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  _ownerChip(),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 2),
          child: Divider(color: isSaved ? Colors.grey : Colors.white),
        ),
        ScopeActionsRow(scope: scope, card: true),
      ],
    );
  }

  Widget _scopeImage(dynamic scope) {
    final img = scope['image'];

    if (img == null || img.toString().isEmpty) {
      // ✅ fallback image
      return Image.asset(
        'assets/images/user.png',
        height: 55,
        width: 55,
        fit: BoxFit.cover,
      );
    }

    // ✅ Network image
    return Image.network(
      img,
      height: 55,
      width: 55,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Image.asset(
          'assets/images/user.png',
          height: 55,
          width: 55,
          fit: BoxFit.cover,
        );
      },
    );
  }

  Widget _ownerChip() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF000080),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          loggedName,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildSavedScopeCard(dynamic scope) {
    final scopeId = scope['id'].toString();
    final isSelected = selectedScopeIds.contains(scopeId);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedScopeIds.remove(scopeId);
          } else {
            selectedScopeIds.add(scopeId);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade700 : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: _scopeCardContent(
          scope,
          isSaved: true, // ✅ saved scope
        ),
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
                      final index =
                          groups.indexWhere((g) => g['id'] == groupId);
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
                  Navigator.of(context).pop(); // close options menu

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
                                  final success =
                                      await deleteGroup(groupId: groupId);

                                  if (!dialogContext.mounted) return;
                                  Navigator.of(dialogContext)
                                      .pop(); // close dialog

                                  if (!mounted) return;

                                  if (success) {
                                    setState(() {
                                      groups.removeWhere(
                                          (g) => g['id'] == groupId);
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Group deleted successfully'),
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
                                  side: const BorderSide(
                                      color: Colors.grey, width: 1.5),
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
