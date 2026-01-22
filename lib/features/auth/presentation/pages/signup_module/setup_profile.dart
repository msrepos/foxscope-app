import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foxscope/core/utils/account_storage.dart';
import 'package:foxscope/features/auth/data/models/user.dart';
import 'package:foxscope/features/auth/data/repositories/auth_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/constants/app_env.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_header.dart';
import '../../../../../core/widgets/app_footer.dart';
import '../../../../../core/widgets/widgets.dart';
import 'api.dart';

class SetupProfilePage extends StatefulWidget {
  const SetupProfilePage({super.key});

  @override
  State<SetupProfilePage> createState() => _SetupProfilePageState();
}

class _SetupProfilePageState extends State<SetupProfilePage> {
  final TextEditingController fNameController = TextEditingController();
  final TextEditingController lNameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  DateTime? selectedBirthDate;
  final ImagePicker _picker = ImagePicker();
  String? selectedGender;
  bool isLoading = false;
  File? _profileImage;
  bool _hasImage = true; // Track if user has a profile image
  final session = SignupSession().draft;

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => context.go('/onboarding'),
                icon: const Icon(Icons.arrow_back,
                    color: Colors.black87, size: 28),
              ),
              _buildProfileBox(),
              Center(
                child: const Text(
                  'Set your profile',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: fNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: userNameController,
                decoration: InputDecoration(
                  labelText: 'User Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedGender,
                decoration: InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Male',
                    child: Text('Male'),
                  ),
                  DropdownMenuItem(
                    value: 'Female',
                    child: Text('Female'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              TextField(
                controller: birthDateController,
                readOnly: true, // user can't type manually
                decoration: InputDecoration(
                  labelText: 'Birth Date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedBirthDate ?? DateTime(2000, 1, 1),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      selectedBirthDate = pickedDate;
                      birthDateController.text =
                      "${pickedDate.day.toString().padLeft(2, '0')}-"
                          "${pickedDate.month.toString().padLeft(2, '0')}-"
                          "${pickedDate.year}";
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                    try {
                      setState(() => isLoading = true);

                      final prefs = await SharedPreferences.getInstance();
                      final signupJwt = prefs.getString('signup_jwt');

                      if (signupJwt == null) {
                         Widgets.instant.showError(context,"Signup session expired. Please start again.");
                        return;
                      }

                      // Validate required fields
                      if (fNameController.text.isEmpty ||
                          lNameController.text.isEmpty ||
                          userNameController.text.isEmpty ||
                          passwordController.text.isEmpty) {
                         Widgets.instant.showError(context,"Please complete all required fields");
                        return;
                      }

                      final uri = Uri.parse(
                        "https://api.foxscope.com/foxscope/create_account_set_up_profile/",
                      );

                      final request = http.MultipartRequest('POST', uri);

                      /// 🔑 REQUIRED HEADERS
                      request.headers.addAll({
                        'Accept': 'application/json',
                        'Authorization': 'Bearer $signupJwt',
                      });

                      /// 📦 DATA FIELD (JSON STRING)
                      request.fields['data'] = jsonEncode({
                        "first_name": fNameController.text.trim(),
                        "last_name": lNameController.text.trim(),
                        "user_name": userNameController.text.trim(),
                        "password": passwordController.text,
                        "delete_picture": _profileImage == null,
                      });

                      if (_profileImage != null && await _profileImage!.exists()) {
                        final file = _profileImage!;
                        final stream = http.ByteStream(file.openRead());
                        final length = await file.length();

                        request.files.add(
                          http.MultipartFile(
                            'image',
                            stream,
                            length,
                            filename: file.path.split('/').last,
                          ),
                        );
                      }


                      final response = await request.send();
                      final body = await response.stream.bytesToString();

                      debugPrint("PROFILE SETUP STATUS: ${response.statusCode}");
                      debugPrint("PROFILE SETUP BODY: $body");

                      if (response.statusCode != 200) {
                         Widgets.instant.showError(context,"Failed to create account");
                        return;
                      }

                      final decoded = jsonDecode(body);
                      final finalToken = decoded['token'];

                      /// ✅ SAVE FINAL AUTH TOKEN
                      await prefs.setString('token', finalToken);

                      /// 🧹 CLEAR SIGNUP SESSION
                      await prefs.remove('signup_jwt');
                      await prefs.remove('signup_token');
                      await prefs.remove('signup_email');
                      SignupSession().clear();

                      /// 🚀 GO TO LOGIN (or HOME if auto-login)
                      if (mounted) context.go('/login');

                    } catch (e, s) {
                      debugPrint("SETUP PROFILE ERROR: $e");
                      debugPrint(s.toString());
                       Widgets.instant.showError(context,"Unexpected error occurred");
                    } finally {
                      if (mounted) setState(() => isLoading = false);
                    }
                  },


                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Create',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
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
                  onTap:(){
                    _changePhoto();
                  },
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

  Widget buildSuccessPopup(String message) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50), // green circle
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
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



}
