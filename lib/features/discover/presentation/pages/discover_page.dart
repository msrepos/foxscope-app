import 'package:flutter/material.dart';
import 'package:foxscope/core/theme/app_colors.dart';
import 'package:foxscope/core/widgets/map.dart';
import 'package:foxscope/features/discover/data/models/scope.dart';
import 'package:foxscope/features/discover/data/scopes_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/app_header.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends BaseMapState<DiscoverPage> {
  List<Scope>? scopes;
  final Set<String> _addedMarkerIds = {};

  @override
  Widget mapContainer(Widget map) {
    return Scaffold(
      appBar: const AppHeader(title: "Discover"),
      body: Stack(
        children: [
          // Full-screen map placeholder image
          Positioned.fill(
            child: map,
          ),

          // Search bar on top
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
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
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 10),

                  /// Search field
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: "Search locations...",
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      style: const TextStyle(fontSize: 16),
                      onChanged: onSearchTextChanged,
                    ),
                  ),

                  /// Optional list icon
                  if (scopes?.isNotEmpty == true)
                    GestureDetector(
                      onTap: showScopesList,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(Icons.list, color: Colors.grey),
                      ),
                    ),

                  /// Divider
                  Container(
                    width: 1,
                    height: 24,
                    color: Colors.grey.shade300,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),

                  /// ✅ Filter icon (CLICKABLE)
                  GestureDetector(
                    onTap: onFilterTapped,
                    child: const Icon(
                      Icons.filter_list,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),


          // Search result
          if (searchText.isNotEmpty && scopes?.isNotEmpty == true)
            Positioned(
              top: 75,
              left: 16,
              right: 16,
              child: searchResultListWidget(),
            ),
        ],
      ),
      bottomNavigationBar: const AppFooter(currentIndex: 1),
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
        itemCount: scopes?.length ?? 0,
        itemBuilder: (context, idx) => scopeCardWidget(
          scope: scopes![idx],
          useCards: false,
          onTap: () => onScopeTapped(
            scopes![idx],
            close: () => setState(() {
              searchText = ""; //todo
              FocusScope.of(context).unfocus();
            }),
          ),
        ),
      ),
    );
  }

  void onFilterTapped() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FilterBottomSheet(),
    );
  }


  //---------------------------------------------------------------------------

  String searchText = "";
  bool waitText = false;

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

    if (lastReceivedLocation != null) {
      var scopes = await fetchScopes(lastReceivedLocation!);
      if (scopes?.isNotEmpty == true) {
        setState(() {});
      }
    }
    //
    else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        "Your location is unknow",
      )));
    }
  }

  //---------------------------------------------------------------------------

  void showScopesList() {
    //todo change the way of display
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  color: Colors.white,
                ),
                padding: EdgeInsets.all(15),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scopes',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ...scopes
                              ?.map(
                                (scope) => scopeCardWidget(
                                  scope: scope,
                                  onTap: () => onScopeTapped(scope),
                                ),
                              )
                              .toList() ??
                          []
                    ],
                  ),
                ),
              );
            });
      },
    );
  }

  Widget scopeCardWidget({
    required Scope scope,
    bool useCards = true,
    required VoidCallback onTap,
  }) {
    Widget content = Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            scope.code ?? "",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            scope.name ?? "",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            scope.note ?? "",
            style: const TextStyle(
              fontSize: 13,
            ),
          ),
        ],
      ),
    );

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: useCards
              ? Card(
            surfaceTintColor: Colors.white,
            elevation: 1,
            child: content,
          )
              : content,
        ),
      ),
    );
  }


  void onScopeTapped(Scope scope, {VoidCallback? close}) {
    if (close == null) Navigator.pop(context);
    close?.call();

    var lat = double.tryParse("${scope.lat}");
    var lng = double.tryParse("${scope.lng}");

    if (lat != null && lng != null) {
      mapState?.moveToLocation(LatLng(lat, lng));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Data is missing"),
        ),
      );
    }
  }

  //---------------------------------------------------------------------------

  GeoLocation? lastReceivedLocation;

  @override
  void onLocationDropped(GeoLocation location) {
    debugPrint("📍 Location dropped: ${location.lat}, ${location.lng}");
    lastReceivedLocation = location;
    fetchScopes(location);
  }

  Future<List<Scope>?> fetchScopes(GeoLocation location) async {
    debugPrint("🟡 FETCH SCOPES START");
    debugPrint("📍 User location: ${location.lat}, ${location.lng}");

    final scopesRes = await ScopesRepository().fetchScopes();

    if (!mounted) return null;

    final result = scopesRes.result;

    if (result == null || result.isEmpty) {
      debugPrint("❌ API returned NO scopes");
      setState(() => scopes = []);
      return [];
    }

    debugPrint("✅ ${result.length} scopes received");

    final validScopes = <Scope>[];

    for (final scope in result) {
      final lat = _parseDouble(scope.lat);
      final lng = _parseDouble(scope.lng);

      if (lat == null || lng == null) {
        debugPrint("⚠️ Invalid coordinates for scope ${scope.id}");
        continue;
      }

      final markerId = scope.id.toString();

      // 🔒 Prevent duplicate markers
      if (_addedMarkerIds.contains(markerId)) {
        continue;
      }

      _addedMarkerIds.add(markerId);
      validScopes.add(scope);

      debugPrint("📌 Adding marker for scope ${scope.id}");

      mapState?.addCustomMarker(
        markerId: markerId,
        position: LatLng(lat, lng),
        title: scope.name ?? "Scope",
        snippet: scope.note,
        onTap: () => viewScopeInfo(scope),
      );
    }

    setState(() {
      scopes = validScopes;
    });

    return validScopes;
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  void viewScopeInfo(Scope scope) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Main card
                Container(
                  width: MediaQuery.of(context).size.width - 40,
                  padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Scope name
                      Text(
                        scope.name ?? "",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Stats row
                      Row(
                        children: [
                          _infoItem(
                            Icons.location_on_outlined,
                            "Location",
                            scope.countryCode ?? "—",
                          ),
                          _divider(),
                          _infoItem(
                            Icons.remove_red_eye_outlined,
                            "Views",
                            "${scope.views ?? 0}",
                          ),
                          _divider(),
                          _infoItem(
                            Icons.bookmark_outline,
                            "Saved",
                            "2", // TODO: replace with real value
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Floating image
                Positioned(
                  top: -40,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/mostafa.png', // TODO replace with network
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoItem(IconData icon, String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.grey.shade300,
    );
  }


}

//================================================

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final Map<String, String?> selectedValues = {};
  final Map<String, bool> expandedSections = {};

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),

              /// Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 12),

              /// Title
              const Text(
                "Filters",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              /// Search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// Content
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _section(
                      title: "Education",
                      items: ["University", "School", "Library"],
                    ),
                    _section(
                      title: "Health & Safety",
                      items: [
                        "Hospital",
                        "Clinic",
                        "Pharmacy",
                        "Police Station",
                        "Fire Station"
                      ],
                    ),
                    _section(
                      title: "Government & Services",
                      items: [
                        "Government Office",
                        "Post Office",
                        "Embassy"
                      ],
                    ),
                    _section(
                      title: "Transportation",
                      items: [
                        "Train Station",
                        "Bus Station",
                        "Gas Station",
                        "Airport"
                      ],
                    ),
                    _section(
                      title: "Shopping & Dining",
                      items: ["Supermarket", "Mall", "Restaurant", "Cafe"],
                    ),
                    _section(
                      title: "Accommodation & Events",
                      items: ["Hotel", "Conference Center"],
                    ),
                    _section(
                      title: "Recreation & Entertainment",
                      items: [
                        "Zoo",
                        "Theater",
                        "Stadium",
                        "Cinema",
                        "Park",
                        "Museum",
                        "Beach"
                      ],
                    ),
                    _section(
                      title: "Finance",
                      items: ["Bank"],
                    ),
                  ],
                ),
              ),

              /// Save button
              Padding(
                padding: const EdgeInsets.fromLTRB(16,16,16,40),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      debugPrint("✅ Filters saved: $selectedValues");
                    },
                    child: const Text(
                      "Save",
                      style: TextStyle(fontSize: 16,color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Expandable section
  Widget _section({
    required String title,
    required List<String> items,
  }) {
    final isExpanded = expandedSections[title] ?? false;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: Icon(isExpanded
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down),
            onTap: () {
              setState(() {
                expandedSections[title] = !isExpanded;
              });
            },
          ),

          if (isExpanded)
            Column(
              children: items.map((item) {
                return RadioListTile<String>(
                  value: item,
                  groupValue: selectedValues[title],
                  title: Text(item),
                  onChanged: (value) {
                    setState(() {
                      selectedValues[title] = value;
                    });
                  },
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

/*
class _DiscoverPageState extends State<DiscoverPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: "Discover"),

      body: Stack(
        children: [
          // Full-screen map placeholder image
          Positioned.fill(
            child: Image.asset(
              'assets/images/maps.png',
              fit: BoxFit.cover,
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
        ],
      ),

      bottomNavigationBar: const AppFooter(currentIndex: 1),
    );
  }
}*/
