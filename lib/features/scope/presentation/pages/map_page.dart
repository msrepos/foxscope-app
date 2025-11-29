import 'package:flutter/material.dart';
import 'package:foxscope/core/widgets/map.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/theme/app_colors.dart';

class MapScopePage extends StatefulWidget {
  final Function(GeoLocation)? onLocationSelected;

  const MapScopePage({
    this.onLocationSelected,
    super.key,
  });

  @override
  State<MapScopePage> createState() => _MapScopePageState();
}

class _MapScopePageState extends State<MapScopePage> {
  final GlobalKey<MapWidgetState> _mapKey = GlobalKey<MapWidgetState>();
  GeoLocation? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: const AppHeader(title: "Confirm Scope Location"),
      body: Stack(
        children: [
          // Full-screen map placeholder image
          /*Positioned.fill(
            child: Image.asset(
              'assets/images/maps.png',
              fit: BoxFit.cover,
            ),
          ),*/
          Positioned.fill(
            child: MapWidget(
              key: _mapKey,
              height: size.height,
              // * 1.3,
              enablePinDropping: true,
              controllersTopOffset: size.height - 380,
              onPinDropped: (location) => setState(() {
                _selectedLocation = location;
              }),
              //
              showCurrentLocationButton: true,
              autoMoveToCurrentLocation: true,
              onFocusMovedToCurrentLocation: (lat, lng) => setState(() {
                _selectedLocation = GeoLocation(lng: lng, lat: lat, name: null);
              }),
            ),
          ),

          // Search bar on top
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: const [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search locations...",
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Full-width button on bottom over map
          Positioned(
            left: 16,
            right: 16,
            bottom: 32,
            child: SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedLocation == null
                      ? AppColors.primary.withAlpha(100)
                      : AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _selectedLocation == null
                    ? null
                    : () {
                        if (widget.onLocationSelected == null) {
                          context.go('/scope-create', extra: _selectedLocation);
                        }
                        //
                        else {
                          widget.onLocationSelected!(_selectedLocation!);
                        }
                      },
                child: const Text(
                  "Confirm Location",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppFooter(currentIndex: 1),
    );
  }
}
