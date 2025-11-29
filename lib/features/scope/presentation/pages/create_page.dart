import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foxscope/core/widgets/map.dart';
import 'package:foxscope/features/scope/presentation/pages/map_page.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_env.dart';

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
  late GeoLocation selectedLocation;
  final GlobalKey<MapWidgetState> _mapKey = GlobalKey<MapWidgetState>();

  final TextEditingController _nameController = TextEditingController();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    selectedLocation = widget.selectedLocation;
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> createScope() async {
    final String name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter scope name")),
      );
      return;
    }

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image")),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // IMPORTANT FIX — USE THE CORRECT KEY
    int? userId = prefs.getInt("userId"); // NOT user_id ❗

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Not logged in — userId is null")),
      );
      return;
    }

    var url = Uri.parse("${AppEnv.apiBaseUrl}/scope");

    var request = http.MultipartRequest("POST", url);

    // Text fields
    request.fields['name'] = name;
    request.fields['code'] = "159-357-146.foxscope.com";
    request.fields['note'] = "foxscope";
    request.fields['lat'] = "31.852147";
    request.fields['lng'] = "22.369852";
    request.fields['user_id'] = userId.toString();
    request.fields['type_id'] = "1";
    request.fields['status_id'] = "1";
    request.fields['country_code'] = "EG";
    request.fields['privacy'] = "1";

    // Image file
    request.files.add(
      await http.MultipartFile.fromPath('img', _selectedImage!.path),
    );

    var response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Scope created successfully!")),
      );
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: ${response.statusCode}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapHeight = 200.0;

    return Scaffold(
      appBar: const AppHeader(title: "Create Scope"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // -----------------------------
            // 🌍 TOP MAP (KEPT EXACTLY AS YOU WANT)
            // -----------------------------
            Stack(
              children: [
                Container(
                  height: mapHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    /*image: const DecorationImage(
                      image: AssetImage('assets/images/maps.png'),
                      fit: BoxFit.cover,
                    ),*/
                  ),
                  child: MapWidget(
                    key: _mapKey,
                    height: mapHeight,
                    enablePinDropping: false,
                    initialPinLocation: LatLng(
                      selectedLocation.lat!.toDouble(),
                      selectedLocation.lng!.toDouble(),
                    ),
                    //
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
                    //onPressed: () => context.go('/scope-map'),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return MapScopePage(
                          onLocationSelected: (location) => setState(() {
                            selectedLocation = location;
                          }),
                        );
                      }));
                    },
                    child: const Text("Change"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --------------------------------------
            // FREE / PAID BOX (KEPT EXACTLY AS YOU WANT)
            // --------------------------------------
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
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text("Free",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text("Paid"),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // -----------------------------
            // IMAGE PICKER WITH PREVIEW
            // -----------------------------
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    image: _selectedImage != null
                        ? DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          )
                        : const DecorationImage(
                            image:
                                AssetImage('assets/images/default-scope.png'),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: InkWell(
                    onTap: pickImage,
                    child: Container(
                      height: 38,
                      width: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // NAME INPUT
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Scope Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // CREATE BUTTON
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
                onPressed: createScope,
                child: const Text(
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
}
