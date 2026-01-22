import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foxscope/core/widgets/map.dart';
import 'package:foxscope/features/chat/presentation/pages/forward_page.dart';
import 'package:foxscope/features/scope/presentation/pages/map_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_env.dart';
import '../../../../core/widgets/widgets.dart';

class CurrentLoctionPage extends StatefulWidget {
  final GeoLocation selectedLocation;

  const CurrentLoctionPage({
    required this.selectedLocation,
    super.key,
  });

  @override
  State<CurrentLoctionPage> createState() => _CurrentLoctionPageState();
}

class _CurrentLoctionPageState
    extends State<CurrentLoctionPage> {
  late GeoLocation selectedLocation;
  final GlobalKey<MapWidgetState> _mapKey = GlobalKey<MapWidgetState>();

  @override
  void initState() {
    super.initState();
    _getLiveLocation();
    selectedLocation = widget.selectedLocation;
  }

  @override
  Widget build(BuildContext context) {
    final mapHeight = 200.0;

    return Scaffold(
      appBar: const AppHeader(title: "Current Location"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
                    onPressed: () async {
                      final result = await Navigator.push<GeoLocation>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MapScopePage(
                            returnLocationOnly: true, // 🔥 IMPORTANT
                          ),
                        ),
                      );

                      if (result != null) {
                        setState(() {
                          selectedLocation = result;
                        });

                        // 🔥 MOVE MAP TO NEW LOCATION
                        _mapKey.currentState?.clearCustomMarkers();

                        _mapKey.currentState?.addCustomMarker(
                          markerId: "selected_location",
                          position: LatLng(
                            result.lat!.toDouble(),
                            result.lng!.toDouble(),
                          ),
                          title: result.name ?? "Selected Location",
                        );

                        _mapKey.currentState?.moveToLocation(
                          LatLng(
                            result.lat!.toDouble(),
                            result.lng!.toDouble(),
                          ),
                        );
                      }
                    },


                    child: const Text("Change"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 🔽 The three items under the map
            _locationActionTile(
              icon: Icons.share,
              text: "Share current location",
              onTap: () {
                final lat = selectedLocation.lat;
                final lng = selectedLocation.lng;

                final url =
                    "https://www.google.com/maps/search/?api=1&query=$lat,$lng";

                Share.share(
                  "Here is my current location:\n$url",
                  subject: "My current location",
                );
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(content: Text(msg)),
                // );
                // TODO: integrate share_plus or your share logic
              },
            ),
            _locationActionTile(
              icon: Icons.send,
              text: "Send current location",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ForwardPage(),
                  ),
                );
               /* ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Send location tapped")),
                );*/
              },
            ),
            _locationActionTile(
              icon: Icons.add_box_outlined,
              text: "Create scope",
              onTap: () {
                // TODO: navigate to your create-scope screen, passing the location
                context.push(
                  '/scope-create',
                  extra: selectedLocation,
                );
              },
            ),
          ],
        ),
      ),
      //bottomNavigationBar: const AppFooter(currentIndex: 0),
    );
  }

  Future<void> _getLiveLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1️⃣ Check if location service is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
       Widgets.instant.showError(context,"Location services are disabled");
      return;
    }

    // 2️⃣ Check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
         Widgets.instant.showError(context,"Location permission denied");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
       Widgets.instant.showError(context,"Location permission permanently denied");
      return;
    }

    // 3️⃣ Get current position
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // 4️⃣ Update location + map
    setState(() {
      selectedLocation = GeoLocation(
        lat: position.latitude,
        lng: position.longitude,
        name: "My Current Location",
      );
    });

    // Optional: move map camera if your MapWidget supports it
    _mapKey.currentState?.moveToLocation(
      LatLng(position.latitude, position.longitude),
    );
  }



  Widget _locationActions() {
    return Column(
      children: [
        _locationActionTile(
          icon: Icons.share,
          text: 'Share current location',
          onTap: () {
            final lat = selectedLocation.lat;
            final lng = selectedLocation.lng;

            // You can format this however you like
            final url =
                'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

            Share.share(
              'Here is my current location:\n$url',
              subject: 'My current location',
            );
          },
        ),
        _locationActionTile(
          icon: Icons.send,
          text: 'Send current location',
          onTap: () {
            // your send logic
          },
        ),
        _locationActionTile(
          icon: Icons.add_box_outlined,
          text: 'Create scope',
          onTap: () {
            // your create scope logic
          },
        ),
      ],
    );
  }

  Widget _locationActionTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

}
