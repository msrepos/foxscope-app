import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foxscope/core/theme/app_colors.dart';
import 'package:foxscope/features/scope/presentation/pages/select_scope_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_env.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/app_header.dart';
import 'edit_scope.dart';
class AddToGroup extends StatefulWidget {
  final int scopeId;

  const AddToGroup({
    super.key,
    required this.scopeId,
  });

  @override
  State<AddToGroup> createState() => _AddToGroupState();
}


class _AddToGroupState extends State<AddToGroup> {
  final Set<int> _selectedGroupIds = {};

  List<dynamic> groups = [];
  bool isLoadingGroups = false;
  bool isAddingToGroups = false;

  @override
  void initState() {
    super.initState();
    fetchGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: "Add to Group"),
      backgroundColor: const Color(0xFFF2F2F2),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: _buildSearchBar(),
          ),
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
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),

                    child: _buildGroupCard(
                      groupId: group['id'],
                      title: group['name'] ?? 'Unnamed Group',
                      description: "${group['scope_count'] ?? 0} scopes",
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedGroupIds.isEmpty
                      ? Colors.grey
                      : AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _selectedGroupIds.isEmpty || isAddingToGroups
                    ? null
                    : () async {
                  await _addScopeToSelectedGroups();
                },
                child: isAddingToGroups
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  _selectedGroupIds.isEmpty
                      ? 'Select a group'
                      : 'Add to ${_selectedGroupIds.length} Group${_selectedGroupIds.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // API: Add Scope to Selected Groups
  // ============================================
  Future<void> _addScopeToSelectedGroups() async {
    if (_selectedGroupIds.isEmpty) return;

    setState(() {
      isAddingToGroups = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No token found');
      }

      int successCount = 0;
      int failCount = 0;

      // Add scope to each selected group
      for (final groupId in _selectedGroupIds) {
        try {
          final url = Uri.parse(
            '${AppEnv.apiBaseUrl}/foxscope/groups/$groupId/add_scope/${widget.scopeId}',
          );

          debugPrint('📡 Adding scope ${widget.scopeId} to group $groupId: $url');

          final response = await http.post(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          );

          debugPrint('📊 Status: ${response.statusCode}');
          debugPrint('📨 Body: ${response.body}');

          if (response.statusCode == 200 || response.statusCode == 201) {
            successCount++;
            debugPrint('✅ Successfully added to group $groupId');
          } else {
            failCount++;
            debugPrint('❌ Failed to add to group $groupId');
          }
        } catch (e) {
          failCount++;
          debugPrint('🔥 Error adding to group $groupId: $e');
        }
      }

      if (!mounted) return;

      setState(() {
        isAddingToGroups = false;
      });

      // Show success/error message
      if (successCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              failCount > 0
                  ? 'Added to $successCount group(s), failed for $failCount'
                  : 'Successfully added to $successCount group(s)',
            ),
            backgroundColor: failCount > 0 ? Colors.orange : Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate back after success
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add scope to groups'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('🔥 Error in _addScopeToSelectedGroups: $e');

      if (!mounted) return;

      setState(() {
        isAddingToGroups = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ============================================
  // Fetch Groups
  // ============================================
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

  // ============================================
  // UI Components
  // ============================================
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: Colors.grey),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search groups...",
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

  Widget _buildGroupCard({
    required int groupId,
    required String title,
    required String description,
  }) {
    final bool isSelected = _selectedGroupIds.contains(groupId);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedGroupIds.remove(groupId);
          } else {
            _selectedGroupIds.add(groupId);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
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
                    style: TextStyle(
                      fontSize: 16,
                      color: isSelected ? AppColors.primary : AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppColors.primary : Colors.grey,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}