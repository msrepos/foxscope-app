import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../../../../core/constants/app_env.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_header.dart';
import '../../../../../core/widgets/app_footer.dart';
import '../../../../../core/widgets/widgets.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  //region Var========================
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _firstNameCtrl = TextEditingController();
  final TextEditingController _lastNameCtrl = TextEditingController();
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  final TextEditingController _nationalityCtrl = TextEditingController();
  String? _profileImageUrl;
  DateTime? _birthDate;
  String? _gender; // "male" | "female"
  bool _isLoading = true;
  bool _deletePicture = false;

  //endregion

  //region API=========================
  Future<void> _fetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null || token.isEmpty) {
        debugPrint("❌ TOKEN IS NULL OR EMPTY");
        Widgets.instant.showError(context, "Not authenticated");
        return;
      }

      final url = "${AppEnv.apiBaseUrl}/foxscope/profile/details";
      debugPrint("📡 GET PROFILE → $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      debugPrint("📥 STATUS: ${response.statusCode}");
      debugPrint("📦 BODY: ${response.body}");

      if (response.statusCode != 200) {
        Widgets.instant.showError(
          context,
          "Failed to load profile (${response.statusCode})",
        );
        return;
      }

      final data = jsonDecode(response.body);

      if (!mounted) return;

      setState(() {
        _firstNameCtrl.text = data["first_name"] ?? "";
        _lastNameCtrl.text = data["last_name"] ?? "";
        _usernameCtrl.text = data["uuid"] ?? "";
        _descriptionCtrl.text = data["description"] ?? "";
        _nationalityCtrl.text = data["nationality"] ?? "";
        _gender = data["gender"];

        if (data["birth_date"] != null) {
          _birthDate = DateTime.parse(data["birth_date"]);
        }


        _profileImageUrl = data["image"];
        _isLoading = false;
      });
    } catch (e, stack) {
      debugPrint("🔥 FETCH PROFILE ERROR: $e");
      debugPrint("📛 STACK: $stack");

      Widgets.instant.showError(context, "Failed to load profile");
    }
  }

  Future<void> _updateProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final request = http.MultipartRequest(
        "POST",
        Uri.parse("${AppEnv.apiBaseUrl}/foxscope/profile/update"),
      );

      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      request.fields["data"] = jsonEncode({
        "first_name": _firstNameCtrl.text.trim(),
        "last_name": _lastNameCtrl.text.trim(),
        "description": _descriptionCtrl.text.trim(),
        "nationality": _nationalityCtrl.text.trim(),
        "gender": _gender,
        "birth_date": _birthDate?.millisecondsSinceEpoch,
        "delete_picture": _deletePicture,
      });

      if (_profileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "image",
            _profileImage!.path,
          ),
        );
      }

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        //Widgets.instant.showSuccess(context, "Profile updated");
        context.go("/home");
      } else {
        Widgets.instant.showError(context, body);
      }
    } catch (e) {
      Widgets.instant.showError(context, "Update failed");
    }
  }

  //endregion

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const AppHeader(title: "Edit Profile", showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildProfileBox(),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                child: TextField(
                  controller: _firstNameCtrl,
                  decoration: InputDecoration(

                    labelText: 'First Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 5, 15, 10),
                child: TextField(
                  controller: _lastNameCtrl,

                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 5, 15, 10),
                child: TextField(
                  controller: _usernameCtrl,

                  decoration: InputDecoration(
                    labelText: 'User Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 5, 15, 10),
                child: TextField(
                  controller: _descriptionCtrl,
                  maxLines: 1,
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 5, 15, 10),
                child: TextField(
                  controller: _nationalityCtrl,
                  decoration: InputDecoration(
                    labelText: "Nationality",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 5, 15, 10),
                child: GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _birthDate ?? DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _birthDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: "Birth Date",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      _birthDate == null
                          ? "Select date"
                          : "${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}",
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 5, 15, 10),
                child: DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: InputDecoration(
                    labelText: "Gender",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: "male", child: Text("Male")),
                    DropdownMenuItem(value: "female", child: Text("Female")),
                  ],
                  onChanged: (v) => setState(() => _gender = v),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 5, 15, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Update',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppFooter(currentIndex: 3),
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
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!)
                        : const AssetImage('assets/images/profile_sample.png')
                    as ImageProvider,
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
                width: 160,
                height: 160,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.orange, // The color of the border
                      width: 3.0, // The thickness of the border
                    ),
                  ),
                  padding: const EdgeInsets.all(0.0),
                  child:CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!)
                        : const AssetImage(
                      'assets/images/profile_sample.png',
                    ) as ImageProvider,
                  ),

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
}
