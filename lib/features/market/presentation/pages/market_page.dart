import 'package:flutter/material.dart';
import 'package:foxscope/features/market/presentation/pages/profile_market_place.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/widgets.dart';
import 'edit_marketplace.dart';
import 'package:dio/dio.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.foxscope.com',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  // ✅ Call this AFTER login
  static void setToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }
}

class MarketApi {
  static Future<List<MarketItem>> fetchMarketplace({
    required int page,
    required int limit,
    required String token,
  }) async {
    final Response response = await ApiClient.dio.get(
      '/foxscope/market/list_items',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
      queryParameters: {
        'options': '{"page":$page,"limit":$limit}',
        'search': '',
      },
    );

    final List data = response.data as List;
    return data
        .map((e) => MarketItem.fromJson(e, isMine: false))
        .toList();
  }

  static Future<List<MarketItem>> fetchMyItems({
    required int page,
    required int limit,
    required String token,
  }) async {
    final Response response = await ApiClient.dio.get(
      '/foxscope/market/my_list_items',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
      queryParameters: {
        'options': '{"page":$page,"limit":$limit}',
        'search': '',
      },
    );

    final List data = response.data as List;
    return data
        .map((e) => MarketItem.fromJson(e, isMine: true))
        .toList();
  }
}

class MarketItem {
  final int id;
  final String identifier;
  final double price;
  final String? image;
  final bool isMine;

  MarketItem({
    required this.id,
    required this.identifier,
    required this.price,
    required this.image,
    required this.isMine,
  });

  factory MarketItem.fromJson(Map<String, dynamic> json, {required bool isMine}) {
    return MarketItem(
      id: json['id'],
      identifier: json['scope']['identifier'] ?? '',
      price: (json['price'] as num).toDouble(),
      image: json['scope']['image'],
      isMine: isMine,
    );
  }
}

class MarketPage extends StatefulWidget {
  const MarketPage({
    super.key,
    this.initialTabIndex = 0,
  });

  final int initialTabIndex;

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _activeTabIndex;
  final ScrollController _marketScroll = ScrollController();
  final ScrollController _myItemsScroll = ScrollController();

  List<MarketItem> _marketItems = [];
  List<MarketItem> _myItems = [];

  int _marketPage = 1;
  int _myItemsPage = 1;

  bool _loadingMarket = false;
  bool _loadingMyItems = false;
  bool _marketHasMore = true;
  bool _myItemsHasMore = true;

  static const int _limit = 20;

  @override
  void initState() {
    super.initState();

    // ✅ SAFELY INIT TAB CONTROLLER
    final safeIndex =
    (widget.initialTabIndex < 0 || widget.initialTabIndex > 1)
        ? 0
        : widget.initialTabIndex;

    _activeTabIndex = safeIndex;

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: safeIndex,
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _activeTabIndex = _tabController.index;
        });
      }
    });

    // API calls
    _loadMarketplace();
    _loadMyItems();

    _marketScroll.addListener(() {
      if (_marketScroll.position.pixels >=
          _marketScroll.position.maxScrollExtent - 200) {
        _loadMarketplace();
      }
    });

    _myItemsScroll.addListener(() {
      if (_myItemsScroll.position.pixels >=
          _myItemsScroll.position.maxScrollExtent - 200) {
        _loadMyItems();
      }
    });


  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: "Marketplace"),
      backgroundColor: const Color(0xFFF2F2F2),
      body: Column(
        // Use Column instead of SingleChildScrollView for the main body
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSwitchMenu(), // TabBar goes here
                const SizedBox(height: 16),
                Widgets.instant.buildSearchBar(),
              ],
            ),
          ),

          // 3. TabBarView for swipable content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 4. Content for the "Marketplace" Tab (Index 0)
                _buildMarketplaceContent(),
                // 5. Content for the "My Items" Tab (Index 1)
                _buildMyItemsContent(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppFooter(currentIndex: 0),
    );
  }
  Future<void> _loadMarketplace() async {
    if (_loadingMarket || !_marketHasMore) return;

    setState(() => _loadingMarket = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if (token == null || token.isEmpty) {
        throw Exception('No auth token');
      }

      final items = await MarketApi.fetchMarketplace(
        page: _marketPage,
        limit: _limit,
        token: token,
      );

      setState(() {
        _marketItems.addAll(items);
        _marketPage++;
        _marketHasMore = items.length == _limit;
      });
    } on DioException catch (e) {
      debugPrint('❌ Marketplace error: ${e.response?.statusCode}');
    } finally {
      if (mounted) {
        setState(() => _loadingMarket = false);
      }
    }
  }

  Future<void> _loadMyItems() async {
    if (_loadingMyItems || !_myItemsHasMore) return;

    setState(() => _loadingMyItems = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if (token == null || token.isEmpty) {
        throw Exception('No auth token');
      }

      final items = await MarketApi.fetchMyItems(
        page: _myItemsPage,
        limit: _limit,
        token: token,
      );

      setState(() {
        _myItems.addAll(items);
        _myItemsPage++;
        _myItemsHasMore = items.length == _limit;
      });
    } on DioException catch (e) {
      debugPrint('❌ My Items error: ${e.response?.statusCode}');
    } finally {
      if (mounted) {
        setState(() => _loadingMyItems = false);
      }
    }
  }

  Widget _buildMarketplaceContent() {
    return ListView.builder(
      controller: _marketScroll,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _marketItems.length + (_loadingMarket ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _marketItems.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final item = _marketItems[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _marketCard(item),
        );
      },
    );
  }


  Widget _buildMyItemsContent() {
    return ListView.builder(
      controller: _myItemsScroll,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _myItems.length + (_loadingMyItems ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _myItems.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final item = _myItems[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _myItemCard(item),
        );
      },
    );
  }


  Widget _marketCard(MarketItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: item.image != null
                ? Image.network(item.image!, width: 80, height: 80, fit: BoxFit.cover)
                : Image.asset('assets/images/scope.jpg',
                width: 80, height: 80, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.identifier,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  "${item.price} USD",
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfileCard(myItems: false),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(120.0, 35.0),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Buy",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSwitchMenu() {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10), // Match the container radius
        ),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black,
        tabs: const [
          Tab(
            child: Text(
              "Marketplace",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Tab(
            child: Text(
              "My Items",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyItem(
      String image,
      String title,
      String price, {
        VoidCallback? onTap,
      }) {
    const double itemPadding = 10.0;
    const double iconOffset = 8.0;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
            20, itemPadding, itemPadding, itemPadding),
        decoration: BoxDecoration(
          color: Colors.black12,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.zero,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Image.asset(
                      image,
                      width: 80,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Positioned(
              top: -iconOffset,
              right: -iconOffset,
              child: IconButton(
                icon: const Icon(Icons.more_horiz,
                    color: AppColors.primary, size: 24),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  _showOptionsDialog();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsDialog() {
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
              _option(
                text: 'Remove the Market',
                onTap: () {
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            16), // Slightly larger radius for the screenshot look
                      ),
                      titlePadding: EdgeInsets.zero,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      title: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 24),
                          const CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.primary,
                            // Sample Orange color
                            child: Icon(
                              Icons.info_outline,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ],
                      ),

                      content: const Text(
                        "Are you sure you want to delete this item from  marketplace?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          // Match the dark text color
                          height: 1.2,
                        ),
                      ),

                      actionsAlignment: MainAxisAlignment.center,
                      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),

                      // --- Buttons (Row with Expanded) ---
                      actions: [
                        Row(
                          children: [
                            // 1. Delete Button (Orange, Solid, Wide)
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  // Sample Orange color
                                  minimumSize: const Size(double.infinity, 50),
                                  // Ensure height
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  // TODO: Add delete account logic here
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),
                            // Spacing between buttons

                            // 2. Cancel Button (White with Black/Grey Border)
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(
                                      double.infinity, 50), // Ensure height
                                  side: const BorderSide(
                                    color: Colors.grey, // Border color
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: Colors.black, // Text color
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Divider(height: 0),
              _option(
                text: 'Edit Item',
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditInformationScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _option({
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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


  Widget _myItemCard(MarketItem item) {
    const double iconOffset = 8.0;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ProfileCard(myItems: true),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: item.image != null
                      ? Image.network(
                    item.image!,
                    width: 80,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                      : Image.asset(
                    'assets/images/scope.jpg',
                    width: 80,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.identifier,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${item.price} USD",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),

            // Options menu
            Positioned(
              top: -iconOffset,
              right: -iconOffset,
              child: IconButton(
                icon: const Icon(
                  Icons.more_horiz,
                  color: AppColors.primary,
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _showOptionsDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
