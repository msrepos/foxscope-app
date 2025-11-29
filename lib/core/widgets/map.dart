import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

///https://pub.dev/packages/flutter_polyline_points

class MapWidget extends StatefulWidget {
  final double height;
  final bool enablePinDropping;
  final Function(GeoLocation)? onPinDropped;
  final Function(GeoLocation)? onLocationSelected;
  final LatLng? initialPinLocation;
  final double controllersTopOffset;
  final VoidCallback? onMapInteractionStart;
  final VoidCallback? onMapInteractionEnd;
  final bool showRouteVisualization;
  final Color routeColor;

  //
  final bool showCurrentLocationButton;
  final bool autoMoveToCurrentLocation;
  final void Function(double lat, double lng)? onFocusMovedToCurrentLocation;

  const MapWidget({
    required this.height,
    this.enablePinDropping = false,
    this.onPinDropped,
    this.onLocationSelected,
    this.initialPinLocation,
    this.controllersTopOffset = 60,
    this.onMapInteractionStart,
    this.onMapInteractionEnd,
    this.showRouteVisualization = false,
    this.routeColor = Colors.orange,
    //
    this.showCurrentLocationButton = true,
    this.autoMoveToCurrentLocation = true,
    this.onFocusMovedToCurrentLocation,
    super.key,
  });

  @override
  State<MapWidget> createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget>
    with AutomaticKeepAliveClientMixin {
  //TODO XXXXXX<< THIS KEY MUST CHANGE >>XXXXXX
  static const _gak1_1 = 'A';
  static const _gak1_2 = 'I';
  static const _gak1_3 = 'zaSyAsW';
  static const _gak2 = '1MKToKpb';
  static const _gak3 = 'AlwgzL_';
  static const _gak4 = 'ByKs6Cy';
  static const _gak5 = 'TA60njiM'; //this key 'fox-portal';
  static String get _gak =>
      [_gak1_1, _gak1_2, _gak1_3, _gak2, _gak3, _gak4, _gak5].join();

  final _polylinePoints = PolylinePoints(apiKey: _gak);
  GoogleMapController? _controller;
  final Completer<GoogleMapController> _mapController = Completer();

  bool _isEmulator = false;
  final Map<String, BitmapDescriptor> _customIcons = {};
  Set<Marker> _markers = {};

  final Set<Polyline> _polylines = {};
  LatLng? _droppedPinLocation;
  final bool _isDropPinMode = false;

  late final LatLng capitalPoint;


  //---------------------------------------------------------------------------

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    capitalPoint = LatLng(25.276987, 51.520008);

    _checkIfEmulator();
    _loadCustomIcons();
    //_initializeMarkers();
  }

  void _checkIfEmulator() {
    _isEmulator = !kIsWeb &&
        (Platform.isAndroid &&
            (Platform.environment['ANDROID_EMULATOR'] == '1' ||
                Platform.environment.containsKey('ANDROID_SDK_ROOT')));
  }

  Future<void> _loadCustomIcons() async {
    final size = 48.0;
    final config = ImageConfiguration(size: Size(size, size));
    debugPrint('pin-icon-size: $size');

    final pinIconPath = 'assets/images/pin_small.png';
    final pinSmallIconPath = 'assets/images/pin_small.png';

    try {
      _customIcons[MapMarkerType.pickup.toString()] = await BitmapDescriptor
              .fromAssetImage(
                  config, Platform.isAndroid ? pinIconPath : pinSmallIconPath)
          .catchError((_) =>
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen));

      _customIcons[MapMarkerType.dropOff.toString()] = await BitmapDescriptor
              .fromAssetImage(
                  config, Platform.isAndroid ? pinIconPath : pinSmallIconPath)
          .catchError((_) =>
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));

      _customIcons[MapMarkerType.stop.toString()] = await BitmapDescriptor
              .fromAssetImage(
                  config, Platform.isAndroid ? pinIconPath : pinSmallIconPath)
          .catchError((_) =>
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue));

      _customIcons[MapMarkerType.general.toString()] = await BitmapDescriptor
              .fromAssetImage(
                  config, Platform.isAndroid ? pinIconPath : pinSmallIconPath)
          .catchError((_) =>
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure));
    } catch (e) {
      debugPrint('Error loading custom icons: $e');
      // Fallback to default icons
      _customIcons[MapMarkerType.pickup.toString()] =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      _customIcons[MapMarkerType.dropOff.toString()] =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      _customIcons[MapMarkerType.stop.toString()] =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      _customIcons[MapMarkerType.general.toString()] =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }

    if (mounted) {
      setState(() {});
      if (_droppedPinLocation != null) {
        _addDroppedPin(_droppedPinLocation!);
      }
    }
  }

  void _initializeMarkers() {
    _markers = Set.from(_createDefaultMarkers());

    debugPrint('map._initializeMarkers --> ${widget.initialPinLocation}');

    if (widget.initialPinLocation != null) {
      _droppedPinLocation = widget.initialPinLocation;
      _addDroppedPin(widget.initialPinLocation!);

      Future.delayed(Duration(milliseconds: 500), () {
        moveToLocation(widget.initialPinLocation!);
      });
    }
  }

  Set<Marker> _createDefaultMarkers() {
    return {
      /*Marker(
        markerId: const MarkerId('doha_center'),
        position: capitalPoint,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(
          title: 'Doha City Center',
          snippet: 'Capital of Qatar',
        ),
      ),*/
    };
  }

  //---------------------------------------------------------------------------

  void _addDroppedPin(LatLng location) {
    final icon = _customIcons[MapMarkerType.general.toString()] ??
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);

    final newMarkers = Set<Marker>.from(_markers)
      ..removeWhere((m) => m.markerId.value == 'dropped_pin')
      ..add(
        Marker(
          markerId: const MarkerId('dropped_pin'),
          position: location,
          icon: icon,
          infoWindow: InfoWindow(
            title: 'Selected Location',
            snippet:
                '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
          ),
          onTap: () => _showLocationDetails(location),
        ),
      );

    setState(() => _markers = newMarkers);
  }

  void _showLocationDetails(LatLng location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Location Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Latitude: ${location.latitude.toStringAsFixed(8)}'),
            SizedBox(height: 8),
            Text('Longitude: ${location.longitude.toStringAsFixed(8)}'),
            SizedBox(height: 16),
            Text('You can use this location for pickup/dropoff points.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(
                text: '${location.latitude}, ${location.longitude}',
              ));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Coordinates copied to clipboard!')),
              );
            },
            child: Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  //---------------------------------------------------------------------------

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.autoMoveToCurrentLocation) {
      Future.delayed(Duration(milliseconds: 800), () {
        gotoCurrentLocation();
      });
    }

    _initializeMarkers();
  }

  //---------------------------------------------------------------------------

  @override
  void dispose() {
    debugPrint("🗑️ Disposing MapWidget");
    _controller?.dispose();
    super.dispose();
  }

  //---------------------------------------------------------------------------

  //region Public methods for external control
  Future<void> drawDrivingRoute(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return;

    final origin = PointLatLng(
      waypoints.first.latitude,
      waypoints.first.longitude,
    );
    final destination = PointLatLng(
      waypoints.last.latitude,
      waypoints.last.longitude,
    );
    final intermediates = waypoints
        .sublist(1, waypoints.length - 1)
        .map((p) => PolylineWayPoint(
              location: '${p.latitude},${p.longitude}',
              stopOver: false,
            ))
        .toList();

    try {
      final result = await _polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: origin,
          destination: destination,
          mode: TravelMode.driving,
          wayPoints: intermediates,
        ),
      );

      debugPrint('Directions status: ${result.status}');
      debugPrint('Directions error: ${result.errorMessage}');
      debugPrint('Directions points: ${result.points.length}');

      if (!mounted) return;
      if (result.points.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Directions failed: ${result.errorMessage ?? result.status ?? "unknown"}')),
        );
        return; // don’t draw straight line here while debugging
      }

      final route =
          result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
      setState(() {
        _polylines
          ..clear()
          ..add(Polyline(
            polylineId: const PolylineId('main_route'),
            points: route,
            color: widget.routeColor,
            width: 5,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            jointType: JointType.round,
          ));
      });
      _fitCameraToPoints(route);
    } catch (e, st) {
      debugPrint('Directions exception: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Directions request denied—check API key & restrictions')),
      );
    }
  }

  /// Draw route between multiple points
  void drawRoute(List<LatLng> points) {
    if (points.length < 2 || !widget.showRouteVisualization) return;

    final polyline = Polyline(
      polylineId: PolylineId('main_route'),
      points: points,
      color: widget.routeColor,
      width: 4,
      patterns: [],
      jointType: JointType.round,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );

    setState(() {
      _polylines.clear();
      _polylines.add(polyline);
    });

    // Fit camera to show all route points
    _fitCameraToPoints(points);
  }

  void _fitCameraToPoints(List<LatLng> points) async {
    if (points.isEmpty || _controller == null) return;

    if (points.length == 1) {
      await _controller!.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 15.0),
      );
      return;
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (LatLng point in points) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    await _controller!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100.0),
    );
  }

  //------------------------------------------

  /// Clear the current route
  void clearRoute() {
    setState(() {
      _polylines.clear();
    });
  }

  /// Add custom marker with specific type
  void addCustomMarker({
    required String markerId,
    required LatLng position,
    required String title,
    String? snippet,
    MapMarkerType markerType = MapMarkerType.general,
    VoidCallback? onTap,
  }) {
    final icon =
        _customIcons[markerType.toString()] ?? BitmapDescriptor.defaultMarker;

    final marker = Marker(
      markerId: MarkerId(markerId),
      position: position,
      icon: icon,
      infoWindow: InfoWindow(
        title: title,
        snippet: snippet,
      ),
      onTap: onTap,
    );

    setState(() {
      _markers.removeWhere((m) => m.markerId.value == markerId);
      _markers.add(marker);
    });
  }

  /// Clear all custom markers (preserves default markers)
  void clearCustomMarkers() {
    setState(() {
      _markers.removeWhere((marker) =>
          marker.markerId.value != 'doha_center' &&
          marker.markerId.value != 'dropped_pin');
    });
  }

  /// Remove specific marker by ID
  void removeMarker(String markerId) {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == markerId);
    });
  }

  void removePoint(double latitude, double longitude) {
    setState(() {
      _markers.removeWhere(
        (m) =>
            m.position.latitude == latitude &&
            m.position.longitude == longitude,
      );
    });
  }

  //------------------------------------------

  LatLng? getDroppedPinLocation() => _droppedPinLocation;

  Set<Marker> getMarkers() => _markers;

  Set<Polyline> getPolylines() => _polylines;

  void dropPinAt(LatLng location) {
    if (!widget.enablePinDropping) return;

    debugPrint("📍 Map tapped at: ${location.latitude}, ${location.longitude}");

    setState(() {
      _droppedPinLocation = location;
      _addDroppedPin(location);
    });

    var l = GeoLocation(
      lng: location.longitude,
      lat: location.latitude,
      name: null,
    );
    widget.onPinDropped?.call(l);
    widget.onLocationSelected?.call(l);
  }

  Future<void> moveToLocation(LatLng location, {double zoom = 15.0}) async {
    await _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(location, zoom),
    );
  }

  //-----------------------------------

  Future<void> gotoCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        //todo show warning message, and let user decide to accept or deny
        //
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            _showLocationError('Location permissions are denied');
            return;
          }
        }

        //
        if (permission == LocationPermission.deniedForever) {
          _showLocationError('Location permissions are permanently denied');
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      await _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          15.0,
        ),
      );

      widget.onFocusMovedToCurrentLocation?.call(
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      _showLocationError('Could not get current location: ${e.toString()}');
    }
  }

  void _showLocationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  //endregion

  //---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
        color: Colors.blue.withOpacity(0.1),
      ),
      child: Stack(
        children: [
          _isEmulator ? _buildEmulatorFallback() : _buildGoogleMap(),

          //
          if (widget.enablePinDropping) _buildMapControls(),

          //
          if (widget.enablePinDropping && _isDropPinMode)
            _buildDropPinIndicator(),
        ],
      ),
    );
  }

  Widget _buildEmulatorFallback() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map,
              size: 64,
              color: Colors.grey[600],
            ),
            SizedBox(height: 16),
            Text(
              'Interactive Map View',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Doha, Qatar (${capitalPoint.latitude}, ${capitalPoint.longitude})',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            if (widget.enablePinDropping) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[300]!),
                ),
                child: Text(
                  'Pin Dropping Mode: ${_isDropPinMode ? "ON" : "OFF"}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue[800],
                  ),
                ),
              ),
            ],
            if (_polylines.isNotEmpty) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: widget.routeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: widget.routeColor),
                ),
                child: Text(
                  'Route Visualization Active',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: widget.routeColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
              ),
            ],
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[300]!),
              ),
              child: Text(
                'Google Maps not available in emulator.\nTest on physical device for full functionality.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //-----------------------------------

  Widget _buildGoogleMap() {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: capitalPoint,
          zoom: 13,
        ),
        markers: _markers,
        polylines: _polylines,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
          Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
          Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        compassEnabled: true,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        rotateGesturesEnabled: true,
        scrollGesturesEnabled: true,
        tiltGesturesEnabled: true,
        zoomGesturesEnabled: true,
        minMaxZoomPreference: const MinMaxZoomPreference(8.0, 20.0),
        liteModeEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
          _mapController.complete(controller);
        },
        onTap: (p) => dropPinAt(p),
        onLongPress: (LatLng loc) {
          if (widget.enablePinDropping) dropPinAt(loc);
        },
        onCameraMoveStarted: () => widget.onMapInteractionStart?.call(),
        onCameraIdle: () => widget.onMapInteractionEnd?.call(),
        onCameraMove: (_) => widget.onMapInteractionStart?.call(),
      ),
    );
  }

  //-----------------------------------

  Widget _buildMapControls() {
    return Positioned(
      top: widget.controllersTopOffset,
      right: 6,
      child: Column(
        children: [
          // Pin drop toggle button
          /*_buildControlButton(
            heroTag: "pin_drop_${widget.hashCode}",
            onPressed: _toggleDropPinMode,
            backgroundColor: _isDropPinMode ? Colors.red : Colors.white,
            icon: _isDropPinMode ? Icons.push_pin : Icons.push_pin_outlined,
            iconColor: _isDropPinMode ? Colors.white : Colors.red,
            tooltip:
                _isDropPinMode ? 'Disable pin dropping' : 'Enable pin dropping',
          ),*/

          SizedBox(height: 8),

          // Zoom controls
          _buildZoomControls(),

          SizedBox(height: 8),

          // Clear pin button
          /*if (_droppedPinLocation != null)
            _buildControlButton(
              heroTag: "clear_pin_${widget.hashCode}",
              onPressed: _clearDroppedPin,
              backgroundColor: Colors.white,
              icon: Icons.clear,
              iconColor: Colors.orange,
              tooltip: 'Clear dropped pin',
            ),

          if (_droppedPinLocation != null) SizedBox(height: 8),*/

          // Current location button
          if (widget.showCurrentLocationButton)
            _buildControlButton(
              heroTag: "current_location_${widget.hashCode}",
              onPressed: gotoCurrentLocation,
              backgroundColor: Colors.white,
              icon: Icons.my_location,
              iconColor: Colors.black,
              tooltip: 'Go to current location',
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required String heroTag,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required IconData icon,
    required Color iconColor,
    required String tooltip,
  }) {
    return FloatingActionButton.small(
      heroTag: heroTag,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      elevation: 4,
      child: Icon(icon, color: iconColor),
      tooltip: tooltip,
    );
  }

  Widget _buildZoomControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () async {
              await _controller?.animateCamera(CameraUpdate.zoomIn());
            },
            child: Container(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.add, size: 20),
            ),
          ),
          Container(height: 1, color: Colors.grey[300]),
          InkWell(
            onTap: () async {
              await _controller?.animateCamera(CameraUpdate.zoomOut());
            },
            child: Container(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.remove, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  //-----------------------------------

  Widget _buildDropPinIndicator() {
    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.push_pin, color: Colors.white, size: 16),
            SizedBox(width: 4),
            Text(
              'Tap to drop pin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum MapMarkerType {
  pickup,
  dropOff,
  stop,
  general,
}

class GeoLocation {
  num? lng;
  num? lat;
  String? _name;

  GeoLocation({
    required this.lng,
    required this.lat,
    required String? name,
  }) : _name = name;

  GeoLocation.non();

  String? get name => _name?.isNotEmpty == true ? _name : null;

  String get alterName => '($lat,$lng)';

  @override
  String toString() {
    return 'GeoLocation{lng: $lng, lat: $lat, name: $_name}';
  }
}

///=============================================================================

class GeoCodingHelper {
  static Future<String?> generateLocationDisplayName({
    required double lat,
    required double lng,
    Value<String>? altName,
  }) async {
    try {
      List<geocoding.Placemark> placemarks =
          await geocoding.placemarkFromCoordinates(lat, lng);

      debugPrint('GeoCodingHelper.generateLocationDisplayName('
          'location: {lat: $lat, lng: $lng}'
          ') ----> place: ${placemarks.firstOrNull}');

      if (placemarks.isNotEmpty) {
        geocoding.Placemark place = placemarks.first;

        String address = '';
        if (place.street?.isNotEmpty == true) {
          address += place.street!;
        }
        if (place.locality?.isNotEmpty == true) {
          if (address.isNotEmpty) address += ', ';
          address += place.locality!;
        }
        if (place.administrativeArea?.isNotEmpty == true) {
          if (address.isNotEmpty) address += ', ';
          address += place.administrativeArea!;
        }

        return address;
      }
      //
      else {
        debugPrint('GeoCodingHelper.generateLocationDisplayName('
            'location: {lat: $lat, lng: $lng}'
            ') ----> no places found');
      }
    } catch (e) {
      debugPrint("GeoCodingHelper.generateLocationDisplayName("
          "location: {lat: $lat, lng: $lng}"
          ") ----> "
          "EXCEPTION:: $e");
    }

    return altName?.value ?? "($lat,$lng)";
  }
}

class Value<V> {
  final V? value;

  Value(this.value);
}

///=============================================================================

class BaseMapState<W extends StatefulWidget> extends State<W> {
  final GlobalKey<MapWidgetState> _mapKey = GlobalKey<MapWidgetState>();
  GeoLocation? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return mapContainer(_map(height: size.height));
  }

  Widget mapContainer(Widget map) {
    return map;
  }

  MapWidgetState? get mapState => _mapKey.currentState;

  GeoLocation? get selectedLocation => _selectedLocation;

  void setLocation(GeoLocation location) {
    _handleLocationSelected(location);
  }

  void removeMapMarker(double latitude, double longitude) {
    final mapWidget = _mapKey.currentState;
    if (mapWidget == null) return;

    mapWidget.removePoint(latitude, longitude);
  }

  void onLocationDropped(GeoLocation location) {}

  //region map widget methods
  Widget _map({required double height}) {
    return MapWidget(
      key: _mapKey,
      height: height,// * 1.3,
      enablePinDropping: true,
      controllersTopOffset: height - 300,
      onPinDropped: _handleLocationSelected,
      showRouteVisualization: true,
      routeColor: Colors.orange,
      //
      showCurrentLocationButton: true,
      autoMoveToCurrentLocation: true,
      onFocusMovedToCurrentLocation: (lat, lng) {
        _handleLocationSelected(GeoLocation(lng: lng, lat: lat, name: null));
      },
    );
  }

  void _handleLocationSelected(GeoLocation location) async {
    final latLng = LatLng(location.lat!.toDouble(), location.lng!.toDouble());
    _selectedLocation = GeoLocation(
      lat: location.lat,
      lng: location.lng,
      name: location.name?.isNotEmpty == true
          ? location.name!
          : (await _generateLocationDisplayName(latLng)),
    );

    _updateMapMarkers();

    onLocationDropped(location);
  }

  Future<String> _generateLocationDisplayName(LatLng location) async {
    return (await GeoCodingHelper.generateLocationDisplayName(
      lat: location.latitude,
      lng: location.longitude,
    ))!;
  }

  void _updateMapMarkers() {
    final mapWidget = _mapKey.currentState;
    if (mapWidget == null) return;

    mapWidget.clearCustomMarkers();

    // Add pickup marker
    if (_selectedLocation != null) {
      final latLng = LatLng(
        _selectedLocation!.lat!.toDouble(),
        _selectedLocation!.lng!.toDouble(),
      );

      mapWidget.addCustomMarker(
        markerId: 'pickup',
        position: latLng,
        title: 'Pickup Location',
        snippet: _selectedLocation!.name,
        markerType: MapMarkerType.pickup,
      );
    }
  }

//endregion
}
