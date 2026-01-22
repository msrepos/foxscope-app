import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/constants/app_env.dart';
import '../../../../core/widgets/widgets.dart';
import 'scopeActions.dart';


enum SelectScopeSource {
  createGroup,
  addToGroup,
}


class SelectScopePage extends StatefulWidget {
  final SelectScopeSource source;

  const SelectScopePage({
    super.key,
    required this.source,
  });

  @override
  State<SelectScopePage> createState() => _SelectScopePageState();
}


class _SelectScopePageState extends State<SelectScopePage> {

  List scopes = [];
  bool isLoading = true;
  String loggedName = "Ahmed Mohamed";
  int? userId;
  final Set<int> _selectedScopeIds = {};

  @override
  void initState() {
    super.initState();
    loadLoggedUserName();
    fetchScopes();
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

              // 📌 Section title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "My Scopes",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // 📜 Main content (scrollable)
              Expanded(
                child: _buildMainContent(),
              ),
            ],
          ),

          // 💾 Floating save button
          if (_selectedScopeIds.isNotEmpty) _buildSaveButton(),
        ],
      ),
    );
  }


  Future<void> loadLoggedUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      loggedName = prefs.getString("user_name") ?? "Ahmed Mohamed"; // FIXED
      userId = _getIntSafe(prefs, "userId");
    });
  }

  int? _getIntSafe(SharedPreferences prefs, String key) {
    final value = prefs.get(key);

    if (value is int) return value;
    if (value is String) return int.tryParse(value);

    return null;
  }

  void _toggleScopeSelection(dynamic scope) {
    final int id = scope['id'];
    setState(() {
      _selectedScopeIds.contains(id)
          ? _selectedScopeIds.remove(id)
          : _selectedScopeIds.add(id);
    });
  }

  Future<void> _showCreateGroupDialog() async {
    final TextEditingController controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;

        return AlertDialog(
          backgroundColor: Colors.white,

          // 🔹 makes dialog wider
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          titlePadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
          actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),

          title: const Text(
            "Create Group",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),

          content: SizedBox(
            width: screenWidth, // 🔹 forces wider dialog
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Enter group name",
                isDense: true, // 🔹 reduces height
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44), // 🔹 less height
                      side: const BorderSide(color: Colors.grey, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 44), // 🔹 less height
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (controller.text.trim().isEmpty) return;
                      Navigator.pop(context, controller.text.trim());
                    },
                    child: const Text(
                      "Create",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (result != null) {
      _onGroupCreated(result);
    }
  }

  Widget _buildMainContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (scopes.isEmpty) {
      return const Center(child: Text("No scopes found"));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80), // bottom space for Save button
      itemCount: scopes.length,
      itemBuilder: (_, index) {
        return _buildSelectableScopeCard(scopes[index]);
      },
    );
  }

  Widget _buildSelectableScopeCard(dynamic scope) {
    final bool isSelected = _selectedScopeIds.contains(scope['id']);

    return GestureDetector(
      onTap: () => _toggleScopeSelection(scope),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[700] : Colors.grey[400],
          borderRadius: isSelected ? BorderRadius.circular(0) : BorderRadius
              .circular(12),
          border: isSelected
              ? Border.all(color: Colors.grey.shade600, width: 2)
              : Border.all(color: AppColors.primary, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ===== HEADER =====
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: scope['image'] != null && scope['image']
                      .toString()
                      .isNotEmpty
                      ? Image.network(
                    "${scope['image']}",
                    height: 55,
                    width: 55,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Image.asset('assets/images/profile_sample.png',
                            height: 55, width: 55, fit: BoxFit.cover),
                  )
                      : Image.asset('assets/images/user.png',
                      height: 55, width: 55, fit: BoxFit.cover),
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
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            FontAwesomeIcons.thumbtack,
                            size: 20,
                            color: isSelected
                                ? AppColors.primary
                                : Colors.white70,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 50),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : const Color(
                                0xFF000080),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            loggedName,
                            style: TextStyle(
                              color: isSelected ? Color(0xFF000080) : Colors
                                  .white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ===== DIVIDER =====
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(
                height: 1,
                color: isSelected ? Colors.white70 : Colors.white,
              ),
            ),

            // ===== ACTIONS (DISPLAY ONLY) =====
            ScopeActionsRow(scope: scope, card: true),
          ],
        ),
      ),
    );
  }


  Widget _buildSaveButton() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 40,
      child: SizedBox(
        height: 54,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _showCreateGroupDialog,
          child: Text(
            "Save (${_selectedScopeIds.length})",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> fetchScopes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('token');

      if (storedToken == null) {
        debugPrint('❌ No token found');
        setState(() {
          scopes = [];
          isLoading = false;
        });
        return;
      }

      final url = Uri.parse("${AppEnv.apiBaseUrl}/foxscope/my_scopes_and_saved/all");

      debugPrint('📡 Fetching scopes from: $url');

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $storedToken",
          "Accept": "application/json",
        },
      );

      debugPrint('📊 Response status: ${response.statusCode}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        setState(() {
          scopes = responseData is List ? responseData : [];
          isLoading = false;
        });

        debugPrint('✅ Loaded ${scopes.length} scopes');

        // Debug first scope structure
        if (scopes.isNotEmpty) {
          debugPrint('🔍 First scope structure:');
          final firstScope = scopes[0];
          debugPrint('  └─ id: ${firstScope['id']} (${firstScope['id'].runtimeType})');
          debugPrint('  └─ friendly_name: ${firstScope['friendly_name']}');
          debugPrint('  └─ owner_id: ${firstScope['owner_id']}');
          debugPrint('  └─ All keys: ${firstScope.keys.toList()}');
        }
      } else {
        debugPrint('⚠️ Failed to fetch scopes: ${response.statusCode}');
        setState(() {
          scopes = [];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('🔥 Error fetching scopes: $e');
      setState(() {
        scopes = [];
        isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Error",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.black,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text(
                  "OK",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _createGroup(String groupName, List<int> scopeIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('token');

      if (storedToken == null) {
        debugPrint('❌ No token found');
        return false;
      }

      final url = Uri.parse("${AppEnv.apiBaseUrl}/foxscope/groups/add");

      debugPrint('🔍 ========== CREATE GROUP DEBUG ==========');
      debugPrint('📁 Group name: "$groupName"');
      debugPrint('📊 Scope IDs: $scopeIds');

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $storedToken",
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          'data': jsonEncode({
            "name": groupName,
            "scopes": scopeIds,
          }),
        },
      );

      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📨 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Group created successfully');
        return true;
      } else {
        debugPrint('❌ Failed: ${response.statusCode}');
        return false;
      }

    } catch (e) {
      debugPrint('🔥 Error: $e');
      return false;
    }
  }

  void _onGroupCreated(String groupName) async {
    debugPrint("📁 Group name: $groupName");
    debugPrint("✅ Selected scopes: $_selectedScopeIds");

    // Show loading indicator
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Call API to create group
    final success = await _createGroup(groupName, _selectedScopeIds.toList());

    // Close loading indicator
    if (mounted) {
      Navigator.of(context).pop();
    }

    // Show appropriate dialog
    if (mounted) {
      if (success) {
        _showSuccessDialog();
      } else {
        _showErrorDialog('Failed to create group. Please try again.');
      }
    }
  }

  void _showSuccessDialog() {
    final String dialogMessage =
    widget.source == SelectScopeSource.createGroup
        ? "Group created successfully!"
        : "Scope added to the group";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: EdgeInsets.zero,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),

          title: Column(
            children: [
              const SizedBox(height: 24),
              CircleAvatar(
                backgroundColor: Colors.green.shade100,
                child: Icon(
                  Icons.check,
                  color: Colors.green,
                  size: 40,
                ),
              ),
            ],
          ),

          content: Text(
            dialogMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),

          actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.black,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Close success dialog
                  context.pop(_selectedScopeIds.toList()); // Return to previous page
                },
                child: const Text(
                  "Continue",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  //
}
