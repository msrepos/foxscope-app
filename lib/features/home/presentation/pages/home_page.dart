import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_footer.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // HEADER
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    height: 180,
                    color: Colors.black87,
                    padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white,
                          child:
                              Icon(Icons.person, color: Colors.grey, size: 35),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Text(
                              'Mahmoud Farag',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.share_outlined,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  // Floating Card
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: -40,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 22,
                                backgroundImage:
                                    AssetImage('assets/images/profile_sample.png'),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Abdelrahman Mohamed',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Chip(
                                      label: Text('Abdelrahman'),
                                      backgroundColor: AppColors.primary,
                                      labelStyle:
                                          TextStyle(color: Colors.white),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                            children: const [
                              Icon(Icons.device_hub_outlined,
                                  color: Colors.black54),
                              Icon(Icons.arrow_right_alt,
                                  color: Colors.black54),
                              Icon(Icons.share_outlined,
                                  color: Colors.black54),
                              Icon(Icons.qr_code, color: Colors.black54),
                              Icon(Icons.copy_outlined,
                                  color: Colors.black54),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 60),

              // CREATE NEW SCOPE BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/scope-map'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'CREATE NEW SCOPE',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // GRID MENU
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildGridItem(Icons.send, 'Send Scope', onTap: () {
                      context.go('/send');
                    }),
                    _buildGridItem(Icons.save, 'My Scope', onTap: () {
                      context.go('/scope');
                    }),
                    _buildGridItem(Icons.folder_shared, 'Saved Scopes', onTap: () {
                      context.go('/saved');
                    }),
                    _buildGridItem(Icons.qr_code, 'Scan Scope', onTap: () {
                      context.go('/scan');
                    }),
                    _buildGridItem(Icons.groups, 'My Groups', onTap: () {
                      context.go('/groups');
                    }),
                    _buildGridItem(Icons.storefront, 'Marketplace', onTap: () {
                      context.go('/market');
                    }),
                    _buildGridItem(Icons.chat_bubble_outline, 'Chat', onTap: () {
                          context.go('/chat');},
                        hasBadge: true),
                    _buildGridItem(Icons.notifications_outlined,
                        'Notifications', onTap: () {
                          context.go('/notifications');},
                        hasBadge: true),
                    _buildGridItem(Icons.check_circle_outline, 'Status', onTap: () {
                          context.go('/status');},
                        hasBadge: true),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Current location
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.my_location_outlined),
                  label: const Text('Current Location'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),

      // 🚀 NEW SHARED FOOTER
      bottomNavigationBar: const AppFooter(currentIndex: 0),
    );
  }

  Widget _buildGridItem(IconData icon, String label,
    {bool hasBadge = false, VoidCallback? onTap}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click, // ✅ show pointer on hover
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: AppColors.primary, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            if (hasBadge)
              const Positioned(
                top: 6,
                right: 10,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.red,
                  child: Text(
                    '2',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
