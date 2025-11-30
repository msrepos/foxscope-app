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

                  //todo may remove
                  if (scopes?.isNotEmpty == true)
                    GestureDetector(
                      onTap: showScopesList,
                      child: Icon(Icons.list, color: Colors.grey),
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
    Widget container(Widget child) => useCards
        ? Card(
            surfaceTintColor: Colors.white60,
            child: child,
          )
        : child;

    return SizedBox(
      width: double.maxFinite,
      child: GestureDetector(
        onTap: onTap,
        child: container(Padding(
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
              Text(
                scope.name ?? "",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                scope.note ?? "",
                style: TextStyle(
                  fontSize: 13,
                ),
              ),
            ],
          ),
        )),
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
    lastReceivedLocation = location;
    fetchScopes(location);
  }

  Future<List<Scope>?> fetchScopes(GeoLocation location) async {
    var scopesRes = await ScopesRepository().fetchScopes();
    scopes = scopesRes.result;

    if (!mounted) return scopes;

    setState(() {});

    if (scopesRes.result != null) {
      for (var scope in scopesRes.result!) {
        var lat = double.tryParse("${scope.lat}");
        var lng = double.tryParse("${scope.lng}");

        if (lat != null && lng != null) {
          mapState?.addCustomMarker(
            markerId: "${scope.id}",
            position: LatLng(lat, lng),
            title: scope.name ?? "Scope X",
            snippet: scope.note,
            //onTap: null,
            onTap: () => viewScopeInfo(scope),
          );
        }
      }
    }
    //
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(scopesRes.message?.get(true) ?? "No scopes found"),
          backgroundColor: Colors.red,
        ),
      );
    }

    return scopes;
  }

  void viewScopeInfo(Scope scope) {
    final imageHeight = 100.0;

    showDialog(
      context: context,
      builder: (context) {
        return Column(
          children: [
            Expanded(child: SizedBox()),
            Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(
                      top: imageHeight / 2,
                      left: 15,
                      right: 15,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: imageHeight / 2),
                        Center(
                          child: Text(
                            scope.name ?? "",
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            ...[
                              (
                                Icons.pin_drop_outlined,
                                "Location",
                                scope.countryCode,
                              ),
                              (
                                Icons.remove_red_eye_outlined,
                                "Views",
                                scope.views ?? "0",
                              ),
                              //todo what is the value of 'saved'?
                              (
                                Icons.save_outlined,
                                "Saved",
                                "0",
                              ),
                            ].map((e) => Expanded(
                                  child: Column(
                                    children: [
                                      Icon(e.$1),
                                      Text(
                                        e.$2,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      Text(
                                        e.$3,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                          ]
                            ..insert(
                                1,
                                Container(
                                  width: 1,
                                  height: 50,
                                  color: Colors.grey[300],
                                ))
                            ..insert(
                                3,
                                Container(
                                  width: 1,
                                  height: 50,
                                  color: Colors.grey[300],
                                )),
                        ),
                      ],
                    ),
                  ),

                  //photo
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: imageHeight,
                      width: imageHeight,
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        //todo replace with Image.network
                        'assets/images/mostafa.png',
                        width: imageHeight,
                        height: imageHeight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: SizedBox()),
          ],
        );
      },
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
