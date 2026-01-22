import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foxscope/core/widgets/map.dart';
import 'package:foxscope/features/scope/presentation/pages/map_page.dart';
import 'package:foxscope/features/scope/presentation/pages/scope_page.dart';
import 'package:foxscope/features/scope/presentation/pages/subscription.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_env.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../../../core/widgets/widgets.dart';

class CreateScopePage extends StatefulWidget {
  final GeoLocation selectedLocation;

  const CreateScopePage({
    required this.selectedLocation,
    super.key,
  });

  @override
  State<CreateScopePage> createState() => _CreateScopePageState();
}

class _CreateScopePageState extends State<CreateScopePage> {

  //region Variables
  late GeoLocation selectedLocation;
  final GlobalKey<MapWidgetState> _mapKey = GlobalKey<MapWidgetState>();
  final TextEditingController _scopeNameController = TextEditingController();
  final TextEditingController _hintNameController = TextEditingController();
  File? _selectedImage;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  bool _hasImage = true;
  bool _isCreating = false;
  bool _isPrime = false;
  List<Map<String, dynamic>> _categories = [];
  int? _selectedCategoryId;
  bool _isLoadingCategories = false;
  //endregion

  @override
  void initState() {
    super.initState();
    selectedLocation = widget.selectedLocation;
    _fetchCategories();
  }

  @override
  void dispose() {
    _scopeNameController.dispose();
    _hintNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapHeight = 150.0;
    return Scaffold(
      appBar: const AppHeader(title: "Create Scope"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Map Section
            Stack(
              children: [
                Container(
                  height: mapHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: MapWidget(
                    key: _mapKey,
                    height: mapHeight,
                    enablePinDropping: false,
                    initialPinLocation: LatLng(
                      selectedLocation.lat!.toDouble(),
                      selectedLocation.lng!.toDouble(),
                    ),
                    showCurrentLocationButton: false,
                    autoMoveToCurrentLocation: false,
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapScopePage(
                            onLocationSelected: (location) => setState(() {
                              selectedLocation = location;
                            }),
                          ),
                        ),
                      );
                    },
                    child: const Text("Change"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Free/Prime Toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !_isPrime ? AppColors.primary : Colors.white,
                          foregroundColor: !_isPrime ? Colors.white : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: !_isPrime ? AppColors.primary : Colors.grey,
                            ),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _isPrime = false;
                            _selectedCategoryId = null;
                            _scopeNameController.clear();
                          });
                        },
                        child: const Text("Free"),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isPrime ? AppColors.primary : Colors.white,
                          foregroundColor: _isPrime ? Colors.white : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: _isPrime ? AppColors.primary : Colors.grey,
                            ),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _isPrime = true;
                          });
                        },
                        child: const Text("Prime"),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _buildProfileBox(),

            const SizedBox(height: 16),

            // Prime Scope Name (only for Prime)
            if (_isPrime) ...[
              TextField(
                controller: _scopeNameController,
                decoration: InputDecoration(
                  labelText: "Prime Scope Name",
                  hintText: "e.g., MyRestaurant",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Friendly Name (Hint Name)
            TextField(
              controller: _hintNameController,
              decoration: InputDecoration(
                labelText: "Hint Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Category (only for Prime)
            if (_isPrime)
              GestureDetector(
                onTap: _isLoadingCategories ? null : _openCategorySheet,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Category",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    suffixIcon: const Icon(Icons.keyboard_arrow_down),
                  ),
                  child: Text(
                    _selectedCategoryId == null
                        ? "Select category"
                        : _categories
                        .firstWhere((c) => c["id"] == _selectedCategoryId)["name"],
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedCategoryId == null
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),
                ),
              ),


            const SizedBox(height: 20),

            // Create Button
            SizedBox(
              height: 45,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isCreating ? null : _handleCreateScope,
                child: _isCreating
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  "Create Scope",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: const AppFooter(currentIndex: 1),
    );
  }

  Future<int?> _createScope({
    required String token,
    required String friendlyName,
     File? image,
    required int typeId,
  }) async {
    final url = Uri.parse("${AppEnv.apiBaseUrl}/scope");

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id");

    if (userId == null) {
       Widgets.instant.showError(context,"User ID not found");
      return null;
    }

    final request = http.MultipartRequest("POST", url);

    request.headers.addAll({
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    });

    request.fields.addAll({
      "name": _isPrime ? _scopeNameController.text.trim(): friendlyName.toLowerCase().replaceAll(' ', '-'),
      "code": "${friendlyName.toLowerCase().replaceAll(' ', '-')}.${userId}",
      "note": _hintNameController.text.trim(),
      "lat": selectedLocation.lat.toString(),
      "lng": selectedLocation.lng.toString(),
      "user_id": userId.toString(),
      "type_id": typeId.toString(), // 👈 critical
      "status_id": "1",
      "country_code": "QA",
      "privacy": "1",
    });

    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath('img', image.path),
      );
    }


    // 🔥 LOG EVERYTHING
    debugPrint("🚀 CREATE SCOPE REQUEST");
    debugPrint("URL: $url");
    debugPrint("FIELDS: ${request.fields}");
    debugPrint("IMAGE: ${image?.path ?? 'NO IMAGE (DEFAULT)'}");
    final response = await request.send();
    final body = await response.stream.bytesToString();

    debugPrint("📥 STATUS CODE: ${response.statusCode}");
    debugPrint("📥 BODY: $body");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(body);

      debugPrint("📦 DECODED: $decoded");

      return decoded["id"];
    } else {
       Widgets.instant.showError(context,"Create scope failed:\n$body");
      return null;
    }
  }

  Future<void> _handleCreateScope() async {
    final friendlyName = _hintNameController.text.trim();
    File? image = _profileImage ?? _selectedImage;

    if (friendlyName.isEmpty) {
       Widgets.instant.showError(context,"Please enter a friendly name");
      return;
    }

    if (image == null || !await image.exists()) {
      image = await assetToFile('assets/images/profile_sample.png');
    }


    setState(() => _isCreating = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
         Widgets.instant.showError(context,"Not logged in");
        return;
      }

      final scopeId = await _createFreeScope(
        token: token,
        friendlyName: friendlyName,
        latitude: selectedLocation.lat!.toDouble(),
        longitude: selectedLocation.lng!.toDouble(),
        image: image,
      );

      if (!mounted || scopeId == null) return;

// ✅ ASSIGN CATEGORY (ONLY FOR PRIME)
      if (_isPrime) {
        if (_selectedCategoryId == null) {
           Widgets.instant.showError(context,"Category is required for Prime scopes");
          return;
        }

        final assigned = await _assignScopeToCategory(
          token: token,
          scopeId: scopeId,
          categoryId: _selectedCategoryId!,
        );

        if (!assigned) {
           Widgets.instant.showError(context,"Failed to assign scope to category");
          return;
        }else{
          print("## Successfully assigned to it");
        }
      }

      // 🔁 PRIME → SUBSCRIPTION
      if (_isPrime) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SubscriptionPage(
              scopeData: {
                'scope_id': scopeId,
                'prime_name': _scopeNameController.text.trim(),
                'friendly_name': friendlyName,
                'category_id': _selectedCategoryId!,
                'latitude': selectedLocation.lat!,
                'longitude': selectedLocation.lng!,
                'image': image,
              },
            ),
          ),
        );
      }
      // ✅ FREE → SCOPES PAGE
      else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ScopePage(
              showScopeAddedPopup: true,
            ),
          ),
        );
      }
    } catch (e) {
       Widgets.instant.showError(context,"Error: $e");
    } finally {
      if (mounted) {
        setState(() => _isCreating = false); // ✅ ALWAYS RESET
      }
    }
  }



  Future<File> persistImage(XFile pickedFile) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = path.basename(pickedFile.path);

    final savedImage = File('${dir.path}/$fileName');
    return File(pickedFile.path).copy(savedImage.path);
  }

  Future<int?> _createFreeScope({
    required String token,
    required String friendlyName,
    required double latitude,
    required double longitude,
    File? image,
  }) async {
    final url = Uri.parse(
      "${AppEnv.apiBaseUrl}/foxscope/create_scope/",
    );

    final request = http.MultipartRequest("POST", url);

    request.headers.addAll({
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    });

    // ✅ REQUIRED "data" FIELD
    final dataPayload = {
      "latitude": latitude,
      "longitude": longitude,
      "friendly_name": friendlyName,
      "category": null,
      "prime_mode": false,
    };

    request.fields["data"] = jsonEncode(dataPayload);

    // ✅ OPTIONAL IMAGE
    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath("image", image.path),
      );
    }

    // 🔍 LOGS
    debugPrint("🚀 CREATE FREE SCOPE");
    debugPrint("URL: $url");
    debugPrint("DATA: ${request.fields["data"]}");
    debugPrint("IMAGE: ${image?.path ?? 'NO IMAGE'}");

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    debugPrint("📡 STATUS: ${response.statusCode}");
    debugPrint("📨 BODY: $responseBody");

    if (response.statusCode == 200 || response.statusCode == 201) {
      // ✅ HANDLE ALL RESPONSE TYPES
      try {
        final decoded = jsonDecode(responseBody);

        // Case 1: backend returns plain int
        if (decoded is int) {
          return decoded;
        }

        // Case 2: backend returns { "id": 123 }
        if (decoded is Map && decoded["id"] != null) {
          return decoded["id"];
        }

        // Case 3: backend returns [ { "id": 123 } ]
        if (decoded is List && decoded.isNotEmpty && decoded[0]["id"] != null) {
          return decoded[0]["id"];
        }

        Widgets.instant.showError(
          context,
          "Unexpected response format",
        );
        return null;
      } catch (e) {
        // 🔥 Fallback: try parsing as plain int
        final id = int.tryParse(responseBody);
        if (id != null) return id;

        Widgets.instant.showError(
          context,
          "Failed to parse scope ID",
        );
        return null;
      }
    } else {
      Widgets.instant.showError(
        context,
        "Create scope failed:\n$responseBody",
      );
      return null;
    }
  }

  Future<bool> _assignScopeToCategory({
    required String token,
    required int scopeId,
    required int categoryId,
  }) async {
    final url = Uri.parse("${AppEnv.apiBaseUrl}/category-scope");

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "scope_id": scopeId,
          "category_id": categoryId,
        }),
      );

      debugPrint("🚀 ASSIGN CATEGORY REQUEST");
      debugPrint("URL: $url");
      debugPrint("BODY: scope_id=$scopeId, category_id=$categoryId");
      debugPrint("📥 STATUS CODE: ${response.statusCode}");
      debugPrint("📥 BODY: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("❌ ASSIGN CATEGORY ERROR: $e");
      return false;
    }
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

  void _openCategorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SizedBox(
          height: 360, // 👈 shows ~4 items then scrolls
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "Select Category",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: ListView.separated(
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected =
                        _selectedCategoryId == category["id"];

                    return ListTile(
                      title: Text(
                        category["name"],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = category["id"];
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Future<File> assetToFile(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();

    final file = File(
      path.join(tempDir.path, path.basename(assetPath)),
    );

    await file.writeAsBytes(
      byteData.buffer.asUint8List(),
      flush: true,
    );

    return file;
  }

  //region Image Section=============================
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
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
                leading: const Icon(Icons.photo_camera, color: AppColors.primary),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
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
        final persistedImage = await persistImage(pickedFile);

        setState(() {
          _profileImage = persistedImage;
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
                  'Profile Photo',
                  style: TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(height: 16),

              // 👉 Constrained, centered image
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
                          : Image.asset(
                        'assets/images/profile_sample.png',
                        fit: BoxFit.cover,
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

  Widget _buildProfileBox() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircleAvatar(
                  radius: 80,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!) as ImageProvider
                      : _hasImage
                      ? const AssetImage('assets/images/profile_sample.png')
                      : null,
                  backgroundColor: Colors.grey[300],
                  child: !_hasImage && _profileImage == null
                      ? const Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.grey,
                  )
                      : null,
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: InkWell(
                  onTap: _showPhotoOptionsDialog,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4,
                          spreadRadius: 1,
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 18,
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
            'Are you sure you want to delete your profile photo?',
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
                    content: Text('Profile photo deleted'),
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
              _photoOption(
                icon: Icons.photo_camera_outlined,
                text: 'Change Photo',
                onTap: () {
                  Navigator.of(context).pop();
                  _changePhoto();
                },
              ),
              const Divider(height: 0),
              _photoOption(
                icon: Icons.remove_red_eye_outlined,
                text: 'Preview Photo',
                onTap: () {
                  Navigator.of(context).pop();
                  _previewPhoto();
                },
              ),
              const Divider(height: 0),
              _photoOption(
                icon: Icons.delete_outline,
                text: 'Delete Photo',
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

  Widget _photoOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
  //endregion

}
