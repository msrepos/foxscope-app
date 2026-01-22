import 'package:flutter/material.dart';
import 'package:foxscope/features/home/presentation/pages/home_page.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/app_header.dart';

class ForwardPage extends StatefulWidget {
  const ForwardPage({super.key});

  @override
  State<ForwardPage> createState() => _ForwardPageState();
}

class _ForwardPageState extends State<ForwardPage> {
  // store selected indices
  final Set<int> _selectedIndexes = <int>{};
  final TextEditingController _message = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: "Chat"),
      backgroundColor: const Color(0xFFF2F2F2),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10,
          ),
          // search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSearchBar(),
          ),
          const SizedBox(height: 16),

          // list
          Expanded(
            child: _buildFavList(),
          ),

          // forward button (only when something is selected)
          if (_selectedIndexes.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10,0, 40),
                    child: TextField(
                      controller: _message,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 9,
                          horizontal: 12,
                        ),
                        labelText: "Forward Message",
                        labelStyle: const TextStyle(
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),


                const SizedBox(width: 12),

                /// ---- Forward Button ----
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 10, 40),
                  child: SizedBox(
                    height: 35,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _onForwardPressed,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [

                          Icon(
                            Icons.double_arrow,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
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

  // ---------- widgets ----------

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

  Widget _buildFavList() {
    final contacts = [
      {'image': 'assets/images/mahmoud.png', 'name': 'Mahmoud Farag'},
      {'image': 'assets/images/mostafa.png', 'name': 'Mostafa Kamal'},
      {'image': 'assets/images/mostafa.png', 'name': 'Mostafa Kamal'},
      {'image': 'assets/images/mahmoud.png', 'name': 'Mahmoud Farag'},
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: contacts.length,
      separatorBuilder: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Divider(
          height: 3,
          color: Colors.black12,
          indent: 10,
          endIndent: 10,
        ),
      ),
      itemBuilder: (context, index) {
        final c = contacts[index];
        return _buildForwardItem(
          index,
          c['image'] as String,
          c['name'] as String,
        );
      },
    );
  }

  Widget _buildForwardItem(int index, String imagePath, String name) {
    final bool isSelected = _selectedIndexes.contains(index);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedIndexes.remove(index);
          } else {
            _selectedIndexes.add(index);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black12 : Colors.transparent,
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
                  const Text(
                    "Sent Scope",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "12:34 PM",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------- actions ----------

  Future<void> _onForwardPressed() async {
    final count = _selectedIndexes.length;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Message Forwarded',
          style: TextStyle(color: AppColors.primary),
        ),
        content: Text(
          count == 1
              ? 'Your message was forwarded successfully.'
              : 'Your message was forwarded to $count contacts successfully.',
        ),
        actions: [
          TextButton(
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HomeScreen(),
                ),
              )
            },
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.black),
            ),
          ),
        ],
      ),
    );

    if (!mounted) return;
    // go back to home page route
    context.go('/home');
  }
}
