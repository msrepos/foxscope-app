import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:foxscope/features/scope/presentation/pages/scopeActions.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:foxscope/core/theme/app_colors.dart';
import 'package:foxscope/features/scope/presentation/pages/create_page.dart';
import 'package:foxscope/features/scope/presentation/pages/scope_page.dart' hide EditFieldType;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_env.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/widgets/map.dart';
import '../../../market/presentation/pages/edit_marketplace.dart';
import 'add_to_group.dart';
import 'edit_scope_helper.dart';
import 'map_page.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
GlobalKey<NavigatorState>();

enum ScopeInfoType {
  address,
  website,
  workingHours,
  mobile,
}

class EditScope extends StatefulWidget {
  final String identifier;
  final String id;

  const EditScope({
    super.key,
    required this.identifier,
    required this.id,
  });

  @override
  State<EditScope> createState() => _EditScopeState();
}

class _EditScopeState extends State<EditScope> {

  //region Variables
  String _hintName = "Ahmed Mohamed";
  String _scopeType = "Commercial";
  String _description = "Enjoy your best meals and have unforgettable experience";
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
  String? _address;
  String? _website;
  String? _workingHours;
  String? _mobile;
  bool _isLoadingCategories = false;
  List<Map<String, dynamic>> _categories = [];
  bool get isPinned => scopeDetails?['pinned'] == true;
  bool isDeleting = false;
  String? _selectedCategoryName;
  int? _selectedCategoryId;

  bool get isFreeScope => scopeDetails?['category'] == null;

  //endregion

  @override
  void initState() {
    super.initState();
    debugPrint('🟡 EditScope initState | identifier=${widget.identifier}');
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
    debugPrint('🧱 Building EditScope | isLoading=$isLoading | scopeId=${widget.identifier}');

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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showSelectFieldSheet(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Add New",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //region API==================================

  Future<void> fetchScopeDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = Uri.parse(
        '${AppEnv.apiBaseUrl}/foxscope/${widget.identifier}/get_scope_by_indentifier/',
      );

      debugPrint('🌐 Fetching scope: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        debugPrint('📦 Scope details loaded');

        setState(() {
          scopeDetails = decoded;

          _hintName = decoded['friendly_name'] ?? '';
          _description = decoded['note'] ?? '';

          // 🔥 CATEGORY HANDLING
          if (decoded['category'] != null) {
            _selectedCategoryId = decoded['category']['id'];
            _selectedCategoryName = decoded['category']['name'];
          } else {
            _selectedCategoryId = null;
            _selectedCategoryName = "Free Scope";
          }

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

  Future<void> deleteScope(BuildContext dialogContext) async {
    debugPrint('🧨 DELETE SCOPE FLOW STARTED');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        debugPrint('🚨 TOKEN MISSING');
        return;
      }

      final scopeId = scopeDetails?['id'];
      debugPrint('🆔 Scope ID = $scopeId');

      final url = '${AppEnv.apiBaseUrl}/foxscope/$scopeId/delete_scope';
      debugPrint('🌐 DELETE URL = $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint('📡 STATUS = ${response.statusCode}');
      debugPrint('📦 BODY = ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('✅ DELETE SUCCESS');

        // ✅ Close the confirmation dialog
        if (dialogContext.mounted) {
          Navigator.of(dialogContext).pop();
        }

        // ✅ Close the options dialog (if open)
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        // ✅ Wait a moment for dialogs to close
        await Future.delayed(const Duration(milliseconds: 100));

        // ✅ Check if widget is still mounted before using context
        if (!mounted) return;

        // ✅ Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Scope deleted successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // ✅ Navigate back to scopes page using GoRouter
        // Pop until we're back at the scopes page
        if (context.mounted) {
          // Use context.go to navigate to scopes page
          context.go('/scopes'); // Adjust this to your actual route
        }

      } else {
        debugPrint('❌ DELETE FAILED: ${response.statusCode}');

        // Close dialog
        if (dialogContext.mounted) {
          Navigator.of(dialogContext).pop();
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete scope'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stack) {
      debugPrint('🔥 DELETE ERROR: $e');
      debugPrint('📛 STACK TRACE: $stack');

      // Try to close dialog
      if (dialogContext.mounted) {
        Navigator.of(dialogContext).pop();
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting scope: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    debugPrint('🏁 DELETE SCOPE FLOW ENDED');
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoadingCategories = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("${AppEnv.apiBaseUrl}/foxscope/scope_category/list"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      debugPrint("📡 CATEGORY STATUS: ${response.statusCode}");
      debugPrint("📦 CATEGORY BODY: ${response.body}");

      if (response.statusCode == 200) {
        final List decoded = jsonDecode(response.body);

        setState(() {
          _categories = decoded.map<Map<String, dynamic>>((c) {
            return {
              "id": c["value"],   // 👈 IMPORTANT
              "name": c["label"], // 👈 IMPORTANT
            };
          }).toList();
        });
      } else {
        Widgets.instant.showError(
          context,
          "Failed to load categories",
        );
      }
    } catch (e) {
      Widgets.instant.showError(
        context,
        "Error loading categories: $e",
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
      }
    }
  }

  //endregion

  void showSelectFieldSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // for rounded corners
      builder: (context) => const SelectFieldSheet(),
    );
  }

  Widget _buildScopeCard(BuildContext context) {
    if (scopeDetails == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    final imageUrl = scopeDetails?['image'];

    Image.network(
      imageUrl ?? '',
      errorBuilder: (_, __, ___) => Image.asset(
        'assets/images/profile_sample.png',
      ),
    );
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
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD8D8D8),
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
                        child: Image.network(
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
                            scopeDetails?['friendly_name'] ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
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
                                  horizontal: 12,
                                  vertical: 4,
                                ),
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
                        Icons.more_vert,
                        color: AppColors.primary,
                      ),
                      onPressed: _showOptionsDialog,
                    ),
                  ],
                ),
              ),

              // 📌 PIN BADGE (TOP RIGHT)
              if (isPinned)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(2),

                    child: const Icon(
                      Icons.push_pin,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Action icons row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
            child: ScopeActionsRow(scope: scopeDetails!, card: false),

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
          Opacity(
            opacity: isFreeScope ? 0.5 : 1,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),

              // 🚫 BLOCK TAP FOR FREE SCOPES
              onTap: isFreeScope
                  ? null
                  : () async {
                final result = await showEditFieldDialog(
                  context: context,
                  title: "Select Scope Category",
                  fieldType: EditFieldType.dropdown,
                  options: _categories.map((c) => c["name"] as String).toList(),
                  initialDropdownValue: _selectedCategoryName,
                );

                if (result is String) {
                  final selected = _categories.firstWhere(
                        (c) => c["name"] == result,
                  );

                  setState(() {
                    _selectedCategoryName = selected["name"];
                    _selectedCategoryId = selected["id"];
                  });
                }
              },

              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 6),
                decoration: BoxDecoration(
                  color: isFreeScope
                      ? Colors.grey.shade300
                      : const Color(0xFFF3E9DD),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  _selectedCategoryName ?? "Select Category",
                  style: TextStyle(
                    fontSize: 12,
                    color: isFreeScope ? Colors.grey : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          if (isFreeScope)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                "Category is available for Prime scopes only",
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
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
                InfoColumn(
                  icon: Icons.location_on_outlined,
                  label: "Location",
                  value: scopeDetails?['scopeDetail']['visits'].toString() ?? '-',
                ),
                const DashedDivider(),
                InfoColumn(
                  icon: Icons.remove_red_eye_outlined,
                  label: "Views",
                  value: scopeDetails?['scopeDetail']['views'].toString() ?? '-',
                ),
                const DashedDivider(),
                InfoColumn(
                  icon: Icons.save_outlined,
                  label: "Saved",
                  value: scopeDetails?['scopeDetail']['saves'].toString() ?? '-',
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

          // Created / Expired row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // ===== Created =====
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Created",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                Expanded(
                  child: Text(
                    ": ${Widgets.instant.dateOnly(scopeDetails?['createdtAt'] ?? "")}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // ===== Spacer between Created & Expired =====
                const SizedBox(width: 12),

                // ===== Expired =====
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Expired",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                Expanded(
                  child: Text(
                    ": ${Widgets.instant.dateOnly(scopeDetails?['expire_at'])}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
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

          // Description + small icons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    scopeDetails?['note'] ?? _description,
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(width: 8),

                // edit
                GestureDetector(
                  onTap: () async {
                    final result = await showEditFieldDialog(
                      context: context,
                      title: "Edit Description",
                      fieldType: EditFieldType.text,
                      initialText: _description,
                    );
                    if (result is String && result.isNotEmpty) {
                      setState(() => _description = result);
                    }
                  },
                  child: const Icon(
                    Icons.edit,
                    size: 20,
                    color: Color(0xFF000080),
                  ),
                ),
                const SizedBox(width: 6),

                // delete
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.white,
                        // Ensure the dialog's shape matches the screenshot
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              16), // Slightly larger radius for the screenshot look
                        ),
                        // Remove default title/content padding for the custom layout
                        titlePadding: EdgeInsets.zero,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),

                        // --- Custom Header (Icon + Disclaimer) ---
                        title: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 24),
                            // Orange Information Icon
                            const CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primary,
                              // Sample Orange color
                              child: Icon(
                                Icons.info_outline,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),

                        // --- Full Content Message ---
                        content: const Text(
                          "Are yoy sure you want to delete description? ",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            // Match the dark text color
                            height: 1.2,
                          ),
                        ),

                        actionsAlignment: MainAxisAlignment.center,
                        actionsPadding:
                            const EdgeInsets.fromLTRB(24, 8, 24, 24),

                        actions: [
                          Row(
                            children: [
                              // 1. Delete Button (Orange, Solid, Wide)
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    // Sample Orange color
                                    minimumSize:
                                        const Size(double.infinity, 50),
                                    // Ensure height
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed:(){

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
                              // Spacing between buttons

                              // 2. Cancel Button (White with Black/Grey Border)
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize:
                                        const Size(double.infinity, 50),
                                    // Ensure height
                                    side: const BorderSide(
                                      color: Colors.grey, // Border color
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: Colors.black, // Text color
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
                  child: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Color(0xFF000080),
                  ),
                ),
                const SizedBox(width: 6),

                // group
                GestureDetector(
                  onTap: () async {
                    final result = await showEditFieldDialog(
                      context: context,
                      title: "Edit Privacy",
                      fieldType: EditFieldType.dropdown,
                      options: const [
                        "Everyone",
                        "My contacts",
                        "Nobody",
                      ],
                    );
                  },
                  child: const Icon(
                    Icons.group_outlined,
                    size: 20,
                    color: Color(0xFF000080),
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
              children: [
                BottomIcon(
                  icon: Icons.location_on_outlined,
                  label: "Address",
                  onTap: () => _showOptionsDialog2(ScopeInfoType.address),
                ),
                BottomIcon(
                  icon: Icons.public,
                  label: "Website",
                  onTap: () => _showOptionsDialog2(ScopeInfoType.website),
                ),
                BottomIcon(
                  icon: Icons.access_time,
                  label: "Working Hours",
                  onTap: () => _showOptionsDialog2(ScopeInfoType.workingHours),
                ),
                BottomIcon(
                  icon: Icons.smartphone,
                  label: "Mobile",
                  onTap: () => _showOptionsDialog2(ScopeInfoType.mobile),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                text: 'Edit Location',
                onTap: () async {
                  Navigator.of(context).pop();
                  final result = await Navigator.push<GeoLocation>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MapScopePage(
                        returnLocationOnly: true, // 🔥 IMPORTANT
                      ),
                    ),
                  );
                },
              ),
              const Divider(height: 0),
              Widgets.instant.option(
                text: 'Duplicate Scope',
                onTap: () {
                  Navigator.of(context).pop();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateScopePage(
                        selectedLocation: currentLocation,
                      ),
                    ),
                  );
                  //Navigator.of(context).pop();
                  //
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
                      builder: (_) => AddToGroup(scopeId: scopeDetails?['id'])
                    ),
                  );
                },
              ),
              const Divider(height: 0),
              Widgets.instant.option(
                text: isPinned ? 'Unpin Scope' : 'Pin Scope',
                onTap: () async {
                  Navigator.of(context).pop();
                  await _togglePinScope();
                },
              ),
              const Divider(height: 0),
              Widgets.instant.option(
                text: 'Add to Marketplace',
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditInformationScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 0),
              Widgets.instant.option(
                text: 'Privacy',
                onTap: () async {
                  Navigator.of(context).pop();

                  final result = await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const PrivacyDialog(),
                  );

                  if (result != null) {
                    print(result);
                  }
                },
              ),
              const Divider(height: 0),
// Replace the delete option in _showOptionsDialog() with this:

              Widgets.instant.option(
                text: 'Delete',
                onTap: () {
                  final parentContext = context; // ✅ SAVE PAGE CONTEXT

                  Navigator.pop(context); // close options menu

                  showDialog(
                    context: parentContext,
                    builder: (dialogContext) => AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      titlePadding: EdgeInsets.zero,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),

                      title: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SizedBox(height: 24),
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.info_outline, color: Colors.white, size: 32),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Disclaimer",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      content: const Text(
                        "Are you sure you want to delete this scope?",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),

                      actions: [
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                onPressed: () async {
                                  debugPrint('🟥 DELETE BUTTON PRESSED FROM DIALOG');

                                  // ✅ PASS THE DIALOG CONTEXT
                                  await deleteScope(dialogContext);
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
                                  Navigator.pop(dialogContext); // ✅ CLOSE DIALOG
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

  Future<void> _togglePinScope() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = Uri.parse(
        '${AppEnv.apiBaseUrl}/foxscope/scope/${widget.id}/pin_scope',
      );

      debugPrint('📌 Toggling pin: $url');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          // 🔥 toggle locally without refetch
          scopeDetails!['pinned'] = !isPinned;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isPinned ? 'Scope unpinned' : 'Scope pinned',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Failed to toggle pin');
      }
    } catch (e) {
      debugPrint('❌ Pin/unpin error: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update pin status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String buildImageUrl() {
    final img = scopeDetails?['image'];
    if (img == null || img.isEmpty) return '';

    return "$img";
  }

  //region bottom buttons
  void _showOptionsDialog2(ScopeInfoType type) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogOption(
                  icon: Icons.open_in_new,
                  text: "Open",
                  onTap: () {
                    Navigator.pop(context);
                    _handleOpen(type);
                  },
                ),
                Widgets.instant.divider(),
                _dialogOption(
                  icon: Icons.edit,
                  text: "Edit",
                  onTap: () {
                    Navigator.pop(context);
                    _handleEdit(type);
                  },
                ),
                Widgets.instant.divider(),
                _dialogOption(
                  icon: Icons.lock_outline,
                  text: "Privacy",
                  onTap: () {
                    Navigator.pop(context);
                    _handlePrivacy(type);
                  },
                ),
                Widgets.instant.divider(),
                _dialogOption(
                  icon: Icons.delete_outline,
                  text: "Delete",
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteDialog(type);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dialogOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : AppColors.primary,
              size: 22,
            ),
            const SizedBox(width: 14),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDestructive ? Colors.red : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleEdit(ScopeInfoType type) async {
    final result = await showEditFieldDialog(
      context: context,
      title: "Edit ${_labelFromType(type)}",
      fieldType: EditFieldType.text,
      initialText: _valueFromType(type),
    );

    if (result is String && result.isNotEmpty) {
      _saveValueForType(type, result);
    }
  }

  String _valueFromType(ScopeInfoType type) {
    switch (type) {
      case ScopeInfoType.address:
        return _address ?? "";
      case ScopeInfoType.website:
        return _website ?? "";
      case ScopeInfoType.workingHours:
        return _workingHours ?? "";
      case ScopeInfoType.mobile:
        return _mobile ?? "";
    }
  }

  void _showDeleteDialog(ScopeInfoType type) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            const SizedBox(height: 24),
            const CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.info_outline, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              "Delete ${_labelFromType(type)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to delete this ${_labelFromType(type)}?",
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    // Sample Orange color
                    minimumSize: const Size(double.infinity, 50),
                    // Ensure height
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    _handleDelete(type);
                    Navigator.pop(context);
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
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize:
                    const Size(double.infinity, 50), // Ensure height
                    side: const BorderSide(
                      color: Colors.grey, // Border color
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.black, // Text color
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
  }

  void _handleOpen(ScopeInfoType type) async {
    switch (type) {
      case ScopeInfoType.address:
        await launchUrl(
          Uri.parse(
            "https://www.google.com/maps/search/?api=1&query=30.0444,31.2357",
          ),
          mode: LaunchMode.externalApplication,
        );
        break;

      case ScopeInfoType.website:
        await launchUrl(
          Uri.parse("https://example.com"),
          mode: LaunchMode.externalApplication,
        );
        break;

      case ScopeInfoType.mobile:
        await launchUrl(Uri.parse("tel:+201234567890"));
        break;

      case ScopeInfoType.workingHours:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Working hours opened")),
        );
        break;
    }
  }

  void _saveValueForType(ScopeInfoType type, String value) {
    setState(() {
      switch (type) {
        case ScopeInfoType.address:
          _address = value;
          break;
        case ScopeInfoType.website:
          _website = value;
          break;
        case ScopeInfoType.workingHours:
          _workingHours = value;
          break;
        case ScopeInfoType.mobile:
          _mobile = value;
          break;
      }
    });
  }

  void _handleDelete(ScopeInfoType type) {
    debugPrint("🗑 Deleted ${_labelFromType(type)}");
    // TODO: remove from backend / state
  }

  void _handlePrivacy(ScopeInfoType type) async {
    final result = await showEditFieldDialog(
      context: context,
      title: "Edit Privacy",
      fieldType: EditFieldType.dropdown,
      options: const [
        "Everyone",
        "My contacts",
        "Nobody",
      ],
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${_labelFromType(type)} privacy settings")),
    );
  }

  String _labelFromType(ScopeInfoType type) {
    switch (type) {
      case ScopeInfoType.address:
        return "Address";
      case ScopeInfoType.website:
        return "Website";
      case ScopeInfoType.workingHours:
        return "Working Hours";
      case ScopeInfoType.mobile:
        return "Mobile";
    }
  }

  //endregion

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
                              "http://sit.foxscope.com/imgs/${scopeDetails?['image']}",
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
