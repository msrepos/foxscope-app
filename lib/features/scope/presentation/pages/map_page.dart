import 'package:flutter/material.dart';
import 'package:foxscope/core/widgets/map.dart';
import 'package:foxscope/core/widgets/wait_spinner.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/theme/app_colors.dart';
import 'create_page.dart';

class MapScopePage extends StatefulWidget {
  final Function(GeoLocation)? onLocationSelected;
  final bool returnLocationOnly;


  const MapScopePage({
    this.returnLocationOnly = false,
    this.onLocationSelected,
    super.key,
  });

  @override
  State<MapScopePage> createState() => _MapScopePageState();
}

class _MapScopePageState extends State<MapScopePage> {

  //region variables
  final GlobalKey<MapWidgetState> _mapKey = GlobalKey<MapWidgetState>();
  GeoLocation? _selectedLocation;
  List<GeoLocation>? _foundLocations;
  String searchText = "";
  bool waitText = false;
  //endregion

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: const AppHeader(title: "Confirm Scope Location"),
      body: Stack(
        children: [
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
                children: [
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
                      onChanged: onSearchTextChanged,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search result
          if (searchText.isNotEmpty && _foundLocations?.isNotEmpty == true)
            Positioned(
              top: 75,
              left: 16,
              right: 16,
              child: searchResultListWidget(),
            ),

          // Full-width button on bottom over map
          Positioned(
            left: 70,
            right: 70,
            bottom: 70,
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
                  if (widget.returnLocationOnly) {
                    // 🔁 Return location to previous screen
                    print("#####$_selectedLocation");
                    Navigator.pop(context, _selectedLocation);
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateScopePage(
                          selectedLocation: _selectedLocation!,
                        ),
                      ),
                    );
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
      //bottomNavigationBar: const AppFooter(currentIndex: 0),
    );
  }

  Widget searchResultListWidget() {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      height: screenSize.height / 2 - 50,
      width: screenSize.width,
      //margin: EdgeInsets.only(left: 20, right: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        boxShadow: [
          BoxShadow(spreadRadius: 0.01, blurRadius: 0.01, offset: Offset(0, 1)),
        ],
      ),
      child: ListView.builder(
        itemCount: _foundLocations?.length ?? 0,
        itemBuilder: (context, idx) => Padding(
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          child: TextButton(
            onPressed: () => setState(() {
              searchText = ""; //todo

              var loc = _foundLocations![idx];
              var position = LatLng(
                loc.lat!.toDouble(),
                loc.lng!.toDouble(),
              );

              _mapKey.currentState?.clearCustomMarkers();

              _mapKey.currentState?.addCustomMarker(
                markerId: loc.alterName,
                position: position,
                title: loc.name ?? loc.alterName,
              );

              _mapKey.currentState?.moveToLocation(position);
            }),
            style: ButtonStyle(
              alignment: Alignment.centerLeft,
            ),
            child: Text(
              _foundLocations![idx].name ?? _foundLocations![idx].alterName,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  void onSearchTextChanged(String value) {
    searchText = value;
    if (searchText.isEmpty) setState(() {});

    if (!waitText) {
      waitText = true;
      Future.delayed(Duration(milliseconds: 800), () {
        if (searchText.isNotEmpty) {
          runSearchJob(searchText);
        }

        waitText = false;
      });
    }
  }

  void runSearchJob(String searchText) async {
    //todo call api
    debugPrint("$runtimeType.runSearchJob(searchText: $searchText)");

    WaitSpinner.show(context, msg: "Find places...");

    var response = await GooglePlacesApi()
        .call(query: "$searchText + qatar + قطر"); //todo change query
    if (!mounted) return;

    await WaitSpinner.dismiss(context);

    if (response.result?.isNotEmpty == true) {
      setState(() {
        _foundLocations = response.result;
      });
    }
  }
}
