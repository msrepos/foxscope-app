import 'package:flutter/material.dart';
import 'package:foxscope/features/discover/data/models/scope.dart';
import 'package:foxscope/features/scope/presentation/pages/scope_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/app_header.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/app_header.dart';
import 'chat_details.dart';

class ChatPage extends StatefulWidget {
  final int initialTabIndex;

  const ChatPage({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late int _currentIndex;
  late PageController _pageController;
  int? _activeIndex;
  final Map<int, bool> _mutedChats = {};
  final Map<int, bool> _blockedChats = {};
  int? _selectedChatIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex.clamp(0, 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: "Chat"),
      backgroundColor: const Color(0xFFF2F2F2),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSwitchMenu(),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSearchBar(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              children: [
                _buildChatsList(), // Chats tab
                _buildFavList(), // Favourites tab (same content for now)
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppFooter(currentIndex: 0),
    );
  }

  Widget _buildSwitchMenu() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Chats tab
          Expanded(
            child: GestureDetector(
              onTap: () => _onTabSelected(0),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _currentIndex == 0 ? AppColors.primary : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Text(
                  "Chat",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _currentIndex == 0 ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          // Favourites tab
          Expanded(
            child: GestureDetector(
              onTap: () => _onTabSelected(1),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _currentIndex == 1 ? AppColors.primary : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  "Favourites",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _currentIndex == 1 ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
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
      child: const Row(
        children: [
          Icon(Icons.search, color: Colors.grey),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search chats...",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatsList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildChatItem(
          index: 0,
          imagePath: 'assets/images/mahmoud.png',
          name: 'Mahmoud Farag',
          message: 'send scope',
          time: '12:30 pm',
          //showActions: _activeIndex == 0,
        ),
        const SizedBox(height: 16),
        _buildChatItem(
          index: 1,
          imagePath: 'assets/images/mostafa.png',
          name: 'Mostafa Kamal',
          message: 'send scope',
          time: '03:48 pm',
          //showActions: _activeIndex == 1,
        ),
      ],
    );
  }

  Widget _buildFavList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildFavItem('assets/images/mahmoud.png', 'Mahmoud Farag'),
        SizedBox(height: 5),
        Divider(
          height: 3,
          color: Colors.black12,
          indent: 10,
          endIndent: 10,
        ),
        SizedBox(height: 5),
        _buildFavItem('assets/images/mostafa.png', 'Mostafa Kamal'),
        SizedBox(height: 5),
        Divider(
          height: 3,
          color: Colors.black12,
          indent: 10,
          endIndent: 10,
        ),
        SizedBox(height: 5),
        _buildFavItem('assets/images/mostafa.png', 'Mostafa Kamal'),
        SizedBox(height: 5),
        Divider(
          height: 3,
          color: Colors.black12,
          indent: 10,
          endIndent: 10,
        ),
        SizedBox(height: 5),
        _buildFavItem('assets/images/mahmoud.png', 'Mahmoud Farag'),
        SizedBox(height: 5),
        //invite part
        /*  Divider(
          height: 3,
          color: Colors.black12,
          indent: 10,
          endIndent: 10,
        ),
        SizedBox(height: 10),
        Text(
          "Invite to scope",
          style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 20),


        ),
        _buildInviteItem('assets/images/mahmoud.png', 'Ahmed Temraz'),
        SizedBox(height: 5),
        Divider(
          height: 3,
          color: Colors.black12,
          indent: 10,
          endIndent: 10,
        ),
        SizedBox(height: 10),
        _buildInviteItem('assets/images/mahmoud.png', 'Ahmed Temraz'),
        SizedBox(height: 5),
        Divider(
          height: 3,
          color: Colors.black12,
          indent: 10,
          endIndent: 10,
        ),
        SizedBox(height: 10),
        _buildInviteItem('assets/images/mahmoud.png', 'Ahmed Temraz'),
        SizedBox(height: 5),
*/
      ],
    );
  }

  Widget _buildFavItem(String imagePath, String name) {
    return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // ✅ Open chat screen

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ChatDetailsPage(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 5, 16, 5),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 29,
                  backgroundImage: AssetImage(imagePath),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          "Username",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildChatItem({
    required int index,
    required String imagePath,
    required String name,
    required String message,
    required String time,
  }) {
    return Slidable(
      key: ValueKey(index),

      // Swipe LEFT actions
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.44,
        children: [
          SlidableAction(
            onPressed: (_) {
              _selectedChatIndex = index;
              _showOptionsDialog();
            },
            backgroundColor: AppColors.black,
            foregroundColor: Colors.white,
            label: 'More',
            borderRadius: BorderRadius.circular(8),
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
          ),
          SlidableAction(
            onPressed: (_) => _showDeleteDialog(),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            label: 'Delete',
            borderRadius: BorderRadius.circular(8),
            padding: const EdgeInsets.symmetric(
              vertical: 6,
              horizontal: 8,
            ),
          ),
        ],
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // ✅ Open chat screen

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ChatDetailsPage(),
            ),
          );
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 76),
          // ✅ critical
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),

          child: Row(
            children: [
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 29,
                  backgroundImage: AssetImage(imagePath),
                ),
              ),
              const SizedBox(width: 16),

              // Name + message
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            message,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                    ),
                  ],
                ),
              ),

              // Time
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),

                  /// 🔕 MUTE ICON
                  if (_mutedChats[index] == true)
                    const Icon(
                      Icons.notifications_off,
                      size: 16,
                      color: Colors.grey,
                    ),

                  /// 🚫 BLOCK ICON
                  if (_blockedChats[index] == true)
                    const Icon(
                      Icons.block,
                      size: 16,
                      color: Colors.redAccent,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsDialog() {
    if (_selectedChatIndex == null) return;

    final index = _selectedChatIndex!;
    final isMuted = _mutedChats[index] ?? false;
    final isBlocked = _blockedChats[index] ?? false;

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
                text: 'Add to Favorites',
                onTap: () {
                  Navigator.pop(context);
                  // TODO
                },
              ),
              const Divider(height: 0),

              /// 🔕 MUTE / UNMUTE
              _option(
                text: isMuted ? 'Unmute' : 'Mute',
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _mutedChats[index] = !isMuted;
                  });
                },
              ),
              const Divider(height: 0),

              /// 🚫 BLOCK / UNBLOCK
              _option(
                text: isBlocked ? 'Unblock' : 'Block',
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _blockedChats[index] = !isBlocked;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              // Ensure the dialog's shape matches the screenshot
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    16), // Slightly larger radius for the screenshot look
              ),
              // Remove default title/content padding for the custom layout
              titlePadding: EdgeInsets.zero,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),

              // --- Custom Header (Icon + Disclaimer) ---
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 24),
                  // Orange Information Icon
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
                  const SizedBox(height: 16),
                  // Bolded "Disclaimer" text
                  const Text(
                    "Disclaimer",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // --- Full Content Message ---
              content: const Text(
                "Are you sure you want to delete this chat?",
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
                          minimumSize:
                              const Size(double.infinity, 50), // Ensure height
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
            ));
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
}
