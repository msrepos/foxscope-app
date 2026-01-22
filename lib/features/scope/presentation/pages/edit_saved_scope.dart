import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:foxscope/features/scope/presentation/pages/scopeActions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:foxscope/core/theme/app_colors.dart';
import 'package:foxscope/features/home/presentation/pages/qr_code_page.dart';
import 'package:foxscope/features/scope/presentation/pages/create_page.dart';
import 'package:foxscope/features/scope/presentation/pages/scope_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_env.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/widgets/map.dart';
import '../../../chat/presentation/pages/forward_page.dart';
import '../../../home/presentation/pages/current_location.dart';
import '../../../market/presentation/pages/edit_marketplace.dart';
import 'add_to_group.dart';
import 'map_page.dart';

class EditSavedScope extends StatefulWidget {
  final int scopeId;

  const EditSavedScope({
    super.key,
    required this.scopeId,
  });

  @override
  State<EditSavedScope> createState() => _EditSavedScopeState();
}

class _EditSavedScopeState extends State<EditSavedScope> {
  //region Variables
  String _hintName = "Ahmed Mohamed";
  String _scopeName = "Scope Name";
  String _scopeType = "Restaurant";
  String _description =
      "Enjoy your best meals and have unforgettable experience";
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  bool _hasImage = true;
  final currentLocation = GeoLocation(
    lat: 30.0444,
    lng: 31.2357,
    name: 'Qatar',
  );
  Map<String, dynamic>? scopeDetails;
  bool isLoading = true;
  static const bool kSaveScopeApiReady = false;

  bool _isLoadingCategories = false;
  List<Map<String, dynamic>> _categories = [];

  //endregion

  @override
  void initState() {
    super.initState();

    debugPrint('🟡 EditSavedScope initState, scopeId = ${widget.scopeId}');
    fetchScopeDetails();
    _fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    debugPrint('🧱 Building EditSavedScope | isLoading=$isLoading | scopeId=${widget.scopeId}');

    return Scaffold(
      appBar: const AppHeader(title: "Scopes"),
      backgroundColor: const Color(0xFFF2F2F2),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildScopeCard(context),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildScopeCard(BuildContext context) {
    final imageUrl = "http://sit.foxscope.com/storage/${scopeDetails?['img']}";
    debugPrint("🖼️ Scope image URL: $imageUrl");

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () async {
                    _showPhotoOptionsDialog();
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child:
                    Image.network(
                      buildImageUrl(),
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, error, __) {
                        debugPrint("❌ Image load failed: $error");
                        return Image.asset(
                          'assets/images/profile_sample.png',
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _scopeName ?? 'No Name Assigned',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700,color: AppColors.primary),
                      ),

                      const SizedBox(height: 8),

                      GestureDetector(
                        onTap: () async {
                          final result = await showEditFieldDialog(
                            context: context,
                            title: "Edit Hint Name",
                            fieldType: EditFieldType.text,
                            initialText: _hintName,
                          );

                          if (result is String && result.isNotEmpty) {
                            setState(() => _hintName = result);
                          }
                        },
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF000080),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Text(
                              _hintName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.bookmark,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    _showOptionsDialog();
                  },
                )
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Action icons row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
            child:ScopeActionsRow(scope: scopeDetails!,card:false),

            // child: Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     _actionIcon(
            //       Icons.map_outlined,
            //       "Go",
            //       onTap: _openGoogleMaps,
            //     ),
            //     _actionIcon(Icons.arrow_forward, "Forward", onTap: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (_) => ForwardPage(),
            //         ),
            //       );
            //     }),
            //     _shareIconBox(
            //       "https://foxscope.com/scope/${widget.scopeId}",
            //     ),
            //     _actionIcon(Icons.qr_code_2, "QR", onTap: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (_) => const QrCodePage(),
            //         ),
            //       );
            //     }),
            //     _actionIcon(
            //       Icons.copy,
            //       "Copy",
            //       onTap: () {
            //         final link = "https://foxscope.com/scope/${widget.scopeId}";
            //
            //         Clipboard.setData(ClipboardData(text: link));
            //
            //         ScaffoldMessenger.of(context).showSnackBar(
            //           const SnackBar(
            //             content: Text("Link copied to clipboard"),
            //             duration: Duration(seconds: 2),
            //             behavior: SnackBarBehavior.floating,
            //           ),
            //         );
            //       },
            //     ),
            //   ],
            // ),
          ),

          const SizedBox(height: 12),
          const Divider(
            height: 1,
            indent: 15,
            endIndent: 15,
          ),

          // Government office pill
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () async {
              final categoryNames = _categories
                  .map((c) => c["name"] as String)
                  .toSet() // ✅ ensure uniqueness
                  .toList();

              final safeInitialValue =
              categoryNames.contains(_scopeType) ? _scopeType : null;

              final result = await showEditFieldDialog(
                context: context,
                title: "Select Scope Category",
                fieldType: EditFieldType.dropdown,
                options: categoryNames,
                initialDropdownValue: safeInitialValue,
              );

              if (result is String && result.isNotEmpty) {
                setState(() {
                  _scopeType = result;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E9DD),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _scopeType,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Divider(
            height: 1,
            indent: 15,
            endIndent: 15,
          ),

          // Location / Views / Saved
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoColumn(
                  icon: Icons.location_on_outlined,
                  label: "Location",
                  value: scopeDetails?['location_name'] ?? '-',
                ),
                const _DashedDivider(),
                _InfoColumn(
                  icon: Icons.remove_red_eye_outlined,
                  label: "Views",
                  value:  scopeDetails?['views'] ?? '-' ,
                ),
                const _DashedDivider(),
                const _InfoColumn(
                  icon: Icons.save_outlined,
                  label: "Saved",
                  value: "2",
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(
            height: 1,
            indent: 15,
            endIndent: 15,
          ),

          // Description + small icons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _description,
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            indent: 15,
            endIndent: 15,
          ),

          // Bottom icons (Address, Website, Working Hours, Mobile)
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 34),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _BottomIcon(
                  icon: Icons.location_on_outlined,
                  label: "Address",
                ),
                _BottomIcon(
                  icon: Icons.public,
                  label: "Website",
                ),
                _BottomIcon(
                  icon: Icons.access_time,
                  label: "Working Hours",
                ),
                _BottomIcon(
                  icon: Icons.smartphone,
                  label: "Mobile",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchScopeDetails() async {
    try {
      debugPrint('🌐 Fetching scope from: ${AppEnv.apiBaseUrl}/scope/${widget.scopeId}');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = Uri.parse(
        '${AppEnv.apiBaseUrl}/scope/${widget.scopeId}',
      );

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
          _scopeName=decoded['name'] ?? _scopeName;
          _hintName = decoded['hint_name'] ?? _hintName;
          _scopeType = decoded['type'] ?? _scopeType;
          _description = decoded['note'] ?? _description;
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

  void showSelectFieldSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // for rounded corners
      builder: (context) => const SelectFieldSheet(),
    );
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoadingCategories = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("${AppEnv.apiBaseUrl}/category"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final List decoded = jsonDecode(response.body);

        setState(() {
          _categories = decoded
              .where((c) => c["is_active"] == 1)
              .map<Map<String, dynamic>>(
                (c) => Map<String, dynamic>.from(c),
          )
              .toList();
        });
      } else {
         Widgets.instant.showError(context,"Failed to load categories");
      }
    } catch (e) {
       Widgets.instant.showError(context,"Error loading categories: $e");
    } finally {
      setState(() => _isLoadingCategories = false);
    }
  }


  String dateOnly(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '-';

    return isoDate.split('T').first;
  }

  String buildImageUrl() {
    final img = scopeDetails?['img'];
    if (img == null || img.isEmpty) return '';

    return "http://sit.foxscope.com/imgs/$img";
  }

  void _showOptionsDialog() {
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
                text: 'pin / unpin Scope',
                onTap: () async {
                  Navigator.of(context).pop();

                  final scopeId = widget.scopeId.toString();
                  final isPinned = await _isScopePinned(scopeId);

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 30,
                        ),
                        content: Text(
                          isPinned
                              ? "Are you sure you want to unpin the scope?"
                              : "Are you sure you want to pin the scope?",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        actionsAlignment: MainAxisAlignment.center,
                        actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                        actions: [
                          Row(
                            children: [
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
                                    await _togglePinScope(scopeId);
                                    Navigator.pop(context);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isPinned
                                              ? "Scope unpinned successfully"
                                              : "Scope pinned successfully",
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    isPinned ? "Unpin" : "Pin",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 50),
                                    side: const BorderSide(color: Colors.grey),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(context),
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
                      );
                    },
                  );
                },
              ),
              const Divider(height: 0),
              Widgets.instant.option(
                text: 'Save',
                onTap: () async {
                  debugPrint("⭐ Save option tapped");

                  Navigator.of(context).pop(); // close menu

                  // 🚧 API NOT READY → STOP EARLY
                  if (!kSaveScopeApiReady) {
                    debugPrint("⚠️ Save API not ready yet");

                    if (!context.mounted) return;

                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        content: Padding(
                          padding: const EdgeInsets.only(top:20.0),
                          child: const Text(
                            "Saving scopes is coming soon 🚧\n\nThis feature will be enabled once the backend API is ready.",
                            textAlign: TextAlign.center,
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop(); // ✅ CORRECT
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'ok',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );


                    return; // ⛔ ABSOLUTELY CRITICAL
                  }

                  // 🟢 REAL LOGIC (future-ready)
                  final scopeId = widget.scopeId.toString();
                  debugPrint("📌 Scope ID: $scopeId");

                  final bool isCurrentlySaved = await _isScopeSaved(scopeId);
                  debugPrint(isCurrentlySaved
                      ? "➡️ Attempting UNSAVE"
                      : "➡️ Attempting SAVE");

                  if (!context.mounted) return;

                  showDialog(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 30,
                        ),
                        content: Text(
                          isCurrentlySaved
                              ? "Are you sure you want to unsave the scope?"
                              : "Are you sure you want to save the scope?",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        actionsAlignment: MainAxisAlignment.center,
                        actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                        actions: [
                          Row(
                            children: [
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
                                    Navigator.pop(dialogContext);

                                    bool success = isCurrentlySaved
                                        ? await _unsaveScope(scopeId)
                                        : await _saveScope(scopeId);

                                    if (!context.mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          success
                                              ? (isCurrentlySaved
                                              ? "Scope unsaved successfully"
                                              : "Scope saved successfully")
                                              : "Something went wrong. Please try again.",
                                        ),
                                        backgroundColor:
                                        success ? Colors.green : Colors.red,
                                      ),
                                    );

                                    if (success) setState(() {});
                                  },
                                  child: Text(
                                    isCurrentlySaved ? "Unsave" : "Save",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: const Text("Cancel"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
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
                      builder: (_) =>  AddToGroup(scopeId: scopeDetails?['id']),
                    ),
                  );
                },
              ),
              const Divider(height: 0),

              const Divider(height: 0),
              Widgets.instant.option(
                text: 'Report Scope',
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),

            ],
          ),
        );
      },
    );
  }

  void openSelectFieldPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SelectFieldSheet(),
    );
  }

  Future<bool> _isScopePinned(String scopeId) async {
    final prefs = await SharedPreferences.getInstance();
    final pinned = prefs.getStringList('pinned_scopes') ?? [];
    return pinned.contains(scopeId);
  }


  Future<bool> _isScopeSaved(String scopeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) return false;

      final response = await http.get(
        Uri.parse("${AppEnv.apiBaseUrl}/scope/$scopeId/saved"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded["saved"] == true;
      }

      return false;
    } catch (e) {
      debugPrint("❌ isScopeSaved error: $e");
      return false;
    }
  }


  Future<bool> _saveScope(String scopeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) return false;

      final response = await http.post(
        Uri.parse("${AppEnv.apiBaseUrl}/scope/save"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "scope_id": scopeId,
        }),
      );

      debugPrint("📥 SAVE SCOPE: ${response.statusCode}");
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("❌ saveScope error: $e");
      return false;
    }
  }

  Future<bool> _unsaveScope(String scopeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) return false;

      final response = await http.delete(
        Uri.parse("${AppEnv.apiBaseUrl}/scope/unsave/$scopeId"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      debugPrint("📥 UNSAVE SCOPE: ${response.statusCode}");
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint("❌ unsaveScope error: $e");
      return false;
    }
  }


  Future<void> _togglePinScope(String scopeId) async {
    final prefs = await SharedPreferences.getInstance();
    final pinned = prefs.getStringList('pinned_scopes') ?? [];

    if (pinned.contains(scopeId)) {
      pinned.remove(scopeId);
      debugPrint("📌 Scope UNPINNED: $scopeId");
    } else {
      pinned.add(scopeId);
      debugPrint("📌 Scope PINNED: $scopeId");
    }

    await prefs.setStringList('pinned_scopes', pinned);
  }



  //region Image=====================================
  void _showPhotoOptionsDialog() {
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
              Widgets.instant.photoOption(
                icon: Icons.photo_camera_outlined,
                text: 'Change Scope Photo',
                onTap: () {
                  Navigator.of(context).pop();
                  _changePhoto();
                },
              ),
              const Divider(height: 0),
              Widgets.instant.photoOption(
                icon: Icons.remove_red_eye_outlined,
                text: 'Preview Scope Photo',
                onTap: () {
                  Navigator.of(context).pop();
                  _previewPhoto();
                },
              ),
              const Divider(height: 0),
              Widgets.instant.photoOption(
                icon: Icons.delete_outline,
                text: 'Delete Scope Photo',
                onTap: () {
                  Navigator.of(context).pop();
                  _deletePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _changePhoto() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading:
                const Icon(Icons.photo_camera, color: AppColors.primary),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading:
                const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.grey),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
          _hasImage = true;
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile photo updated successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _previewPhoto() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(24), // margin from screen edges
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                backgroundColor: Colors.black,
                elevation: 0,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  'Scope Photo',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 260,
                  height: 260, // whatever size you like
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(130),
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 3.0,
                      child: _profileImage != null
                          ? Image.file(
                        _profileImage!,
                        fit: BoxFit.cover,
                      )
                          : Image.network(
                        "http://sit.foxscope.com/imgs/${scopeDetails?['img']}",
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Image.asset(
                              'assets/images/profile_sample.png');
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _deletePhoto() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Delete Photo'),
          content: const Text(
            'Are you sure you want to delete your scope photo?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _profileImage = null;
                  _hasImage = false;
                });
                Navigator.pop(context);

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Scope photo deleted'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
//endregion
}

//==========================================

class SelectFieldSheet extends StatefulWidget {
  const SelectFieldSheet({super.key});

  @override
  State<SelectFieldSheet> createState() => _SelectFieldSheetState();
}

class _SelectFieldSheetState extends State<SelectFieldSheet> {
  String expandedSection = "contact";
  String _phoneNumber = "00 000 00000";
  String _countryCode = "+976";


  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              "Select Field",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _section(
              title: "Contact Information",
              expanded: expandedSection == "contact",
              onTap: () => setState(() => expandedSection = "contact"),
              children: [
                _item(Icons.location_on, "Address", () {}),
                _item(Icons.edit, "Description", () {}),
                _item(Icons.public, "Website", () {}),
                _item(Icons.access_time, "Working Hours", () {
                  showWorkingHoursDialog(context);
                }),
                _item(Icons.smartphone, "Mobile", () async {
                  final result = await showEditFieldDialog(
                    context: context,
                    title: "Phone Number",
                    fieldType: EditFieldType.phone,
                    initialText: _phoneNumber,
                  );

                  if (result is Map) {
                    setState(() {
                      _countryCode = result["countryCode"];
                      _phoneNumber = result["number"];
                    });
                  }
                }),
                _item(Icons.call, "Phone", () {
                  showPhoneDialog(context);
                }),
                _item(Icons.email, "Email", () {}),
              ],
            ),

            _section(
              title: "Social Media",
              expanded: expandedSection == "social",
              onTap: () => setState(() => expandedSection = "social"),
              children: [
                _item(Icons.facebook, "Facebook", () {}),
                _item(Icons.camera_alt, "Instagram", () {}),
                _item(Icons.music_note, "Tiktok", () {}),
                _item(Icons.chat, "Whatsapp", () {}),
              ],
            ),

            _section(
              title: "Business Information",
              expanded: expandedSection == "business",
              onTap: () => setState(() => expandedSection = "business"),
              children: [
                _item(Icons.access_time, "Working Hours", () {
                  showWorkingHoursDialog(context);
                }),
                _item(Icons.menu_book, "Menu", () {}),
                _item(Icons.report_problem, "Complains", () {}),
                _item(Icons.campaign, "Promotions", () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _section({
  required String title,
  required bool expanded,
  required VoidCallback onTap,
  required List<Widget> children,
}) {
  return Column(
    children: [
      InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 16)),
              const Spacer(),
              Icon(expanded ? Icons.expand_less : Icons.expand_more),
            ],
          ),
        ),
      ),
      if (expanded)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(children: children),
        ),
      const SizedBox(height: 12),
    ],
  );
}

Widget _item(IconData icon, String text, VoidCallback onTap) {
  return ListTile(
    onTap: onTap,
    leading: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    ),
    title: Text(text),
  );
}

void showPhoneDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Phone Number",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextField(
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "00 000 00000",
                prefixText: "+974 ",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text("Save"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void showWorkingHoursDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return const WorkingHoursDialog();
    },
  );
}

class WorkingHoursDialog extends StatefulWidget {
  const WorkingHoursDialog({super.key});

  @override
  State<WorkingHoursDialog> createState() => _WorkingHoursDialogState();
}

class _WorkingHoursDialogState extends State<WorkingHoursDialog> {
  final List<_WorkingHourRow> rows = [_WorkingHourRow()];

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
            // TITLE (same style)
            Row(
              children: [
                const Text(
                  "Working Hours",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, color: AppColors.primary),
                  onPressed: () {
                    setState(() {
                      rows.add(_WorkingHourRow());
                    });
                  },
                )
              ],
            ),

            // BODY
            _buildWorkingHours(),

            const SizedBox(height: 20),

            // BUTTONS (same as EditFieldDialog)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO collect working hours
                      Navigator.pop(context, rows);
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
  Widget _buildWorkingHours() {
    return Column(
      children: [
        SizedBox(
          height: 260,
          child: ListView.builder(
            itemCount: rows.length,
            itemBuilder: (context, index) {
              return _workingHourItem(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _workingHourItem(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: "Select Day",
                    isDense: true, // 👈 reduces height
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  items: const [
                    "Sunday",
                    "Monday",
                    "Tuesday",
                    "Wednesday",
                    "Thursday",
                    "Friday",
                    "Saturday",
                  ].map(
                        (d) => DropdownMenuItem(
                      value: d,
                      child: Text(
                        d,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ).toList(),
                  onChanged: (_) {},
                ),
              ),

              IconButton(
                icon: const Icon(Icons.delete, color: AppColors.primary),
                onPressed: () {
                  setState(() {
                    rows.removeAt(index);
                  });
                },
              )
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: "From",
                    isDense: true,
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  items: _timeItems(),
                  onChanged: (_) {},
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: "To",
                    isDense: true,
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  items: _timeItems(),
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _timeItems() {
    return List.generate(
      24,
          (i) {
        final time = "${i.toString().padLeft(2, '0')}:00";
        return DropdownMenuItem(value: time, child: Text(time));
      },
    );
  }
}

class _WorkingHourRow {}

//===========================================================
class _InfoColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoColumn({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22, color: Colors.grey[700]),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Colors.grey,
            width: 0.5,
            style: BorderStyle.solid,
          ),
        ),
      ),
    );
  }
}

class _BottomIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BottomIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4E8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 22, color: AppColors.primary),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
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

//=============================================================

enum EditFieldType {
  text,
  dropdown,
  multiSelect,
  phone,
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
  late TextEditingController _phoneController;
  String _countryCode = "+974";

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController(text: widget.initialText ?? "");
    _phoneController = TextEditingController(text: widget.initialText ?? "");

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

                        case EditFieldType.phone:
                          result = {
                            "countryCode": _countryCode,
                            "number": _phoneController.text.trim(),
                          };
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
          dropdownColor: Colors.white,
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
      case EditFieldType.phone:
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              // COUNTRY CODE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Text(
                      _countryCode,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              ),

              const VerticalDivider(width: 1),

              // PHONE NUMBER
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: "00 000 00000",
                    border: InputBorder.none,
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        );

    }
  }
}

//=============================================================

enum PrivacyOption { everyone, contacts, nobody }

class PrivacyDialog extends StatefulWidget {
  const PrivacyDialog({super.key});

  @override
  State<PrivacyDialog> createState() => _PrivacyDialogState();
}

class _PrivacyDialogState extends State<PrivacyDialog> {
  PrivacyOption mapPrivacy = PrivacyOption.everyone;
  PrivacyOption navigationPrivacy = PrivacyOption.everyone;
  PrivacyOption notificationPrivacy = PrivacyOption.contacts;

  Widget _sectionTitle(String title) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _sectionSubtitle(String subtitle) {
    return Center(
      child: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _radioTile(
      String label,
      IconData icon,
      PrivacyOption value,
      PrivacyOption groupValue,
      ValueChanged<PrivacyOption?> onChanged,
      ) {
    return RadioListTile<PrivacyOption>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppColors.primary,

      dense: true,
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      contentPadding: EdgeInsets.zero,
      //horizontalTitleGap: 0,
      //minLeadingWidth: 0,
      controlAffinity: ListTileControlAffinity.leading,

      title: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 6), // minimal icon-text spacing
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Map Privacy
              _sectionTitle("Map Privacy"),
              _sectionSubtitle("Your visibility on the discover map"),
              _radioTile(
                "Everyone",
                Icons.group,
                PrivacyOption.everyone,
                mapPrivacy,
                    (v) => setState(() => mapPrivacy = v!),
              ),
              _radioTile(
                "My Contacts",
                Icons.person_add_alt_1_rounded,
                PrivacyOption.contacts,
                mapPrivacy,
                    (v) => setState(() => mapPrivacy = v!),
              ),
              _radioTile(
                "Nobody",
                Icons.group_remove_sharp,
                PrivacyOption.nobody,
                mapPrivacy,
                    (v) => setState(() => mapPrivacy = v!),
              ),

              /// Navigation Privacy
              _sectionTitle("Navigation Privacy"),
              _sectionSubtitle("Who can navigate location"),
              _radioTile(
                "Everyone",
                Icons.group,
                PrivacyOption.everyone,
                navigationPrivacy,
                    (v) => setState(() => navigationPrivacy = v!),
              ),
              _radioTile(
                "My Contacts",
                Icons.person_add_alt_1_rounded,
                PrivacyOption.contacts,
                navigationPrivacy,
                    (v) => setState(() => navigationPrivacy = v!),
              ),
              _radioTile(
                "Nobody",
                Icons.group_remove_sharp,
                PrivacyOption.nobody,
                navigationPrivacy,
                    (v) => setState(() => navigationPrivacy = v!),
              ),

              /// Notifications Privacy
              _sectionTitle("Notifications Privacy"),
              _sectionSubtitle("Who can see your updates"),
              _radioTile(
                "Everyone",
                Icons.group,
                PrivacyOption.everyone,
                notificationPrivacy,
                    (v) => setState(() => notificationPrivacy = v!),
              ),
              _radioTile(
                "My Contacts",
                Icons.person_add_alt_1_rounded,
                PrivacyOption.contacts,
                notificationPrivacy,
                    (v) => setState(() => notificationPrivacy = v!),
              ),
              _radioTile(
                "Nobody",
                Icons.group_remove_sharp,
                PrivacyOption.nobody,
                notificationPrivacy,
                    (v) => setState(() => notificationPrivacy = v!),
              ),

              /// Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        // ↓ from 14
                        minimumSize: const Size(0, 36), // forces compact height
                      ),
                      onPressed: () {
                        Navigator.pop(context, {
                          "map": mapPrivacy,
                          "navigation": navigationPrivacy,
                          "notifications": notificationPrivacy,
                        });
                      },
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          fontSize: 14, // ↓ from 16
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10), // slightly tighter gap
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(color: Colors.black),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        minimumSize: const Size(0, 36),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
