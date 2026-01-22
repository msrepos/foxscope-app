import 'package:flutter/material.dart';
import 'package:foxscope/core/theme/app_colors.dart';
import 'package:foxscope/features/market/presentation/pages/paying_screen.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/app_header.dart';
import 'edit_marketplace.dart';

class ProfileCard extends StatefulWidget {
  final bool myItems; // <-- field

  const ProfileCard({
    super.key,
    required this.myItems, // <-- store it
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: "Marketplace"),
      backgroundColor: const Color(0xFFF2F2F2),
      body: Column(
        children: [
          Card(
            elevation: 4,
            color: Colors.white,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.myItems ? Colors.black26 : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/mostafa.png',
                            width: 68,
                            height: 68,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ahmed Mohamed',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3E9DD),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Government Office',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.myItems)
                          IconButton(
                            icon: const Icon(
                              Icons.more_vert,
                              size: 30,
                              color: AppColors.primary,
                            ),
                            onPressed: () {
                              _showOptionsDialog();
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                  ),

                  const Divider(),

                  // Price badge
                  const SizedBox(height: 3),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Text(
                        '50 USD',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Divider(),

                  const SizedBox(height: 12),

                  // Location / Views / Saved
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _InfoColumn(
                        icon: Icons.location_on_outlined,
                        label: 'Location',
                        value: 'Qatar',
                        color: AppColors.primary,
                      ),
                      _VerticalDivider(),
                      _InfoColumn(
                        icon: Icons.remove_red_eye_outlined,
                        label: 'Views',
                        value: '1M',
                        color: AppColors.primary,
                      ),
                      _VerticalDivider(),
                      _InfoColumn(
                        icon: Icons.save_outlined,
                        label: 'Saved',
                        value: '2',
                        color: AppColors.primary,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Description box
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Text(
                      'Lorem Ipsum is simply dummy text of the printing',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Phone
                  Row(
                    children: const [
                      Icon(Icons.phone, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '+974364443728',
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Email
                  Row(
                    children: const [
                      Icon(Icons.email_outlined,
                          color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'name@gmail.com',
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (!widget.myItems)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    //todo
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaymentGateway(scopeData: {}, subscriptionType: '',),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Proceed',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const AppFooter(currentIndex: 0),
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
                        borderRadius: BorderRadius.circular(16), // Slightly larger radius for the screenshot look
                      ),
                      titlePadding: EdgeInsets.zero,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      title: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 24),
                          const CircleAvatar(
                            radius: 24,
                            backgroundColor:AppColors.primary, // Sample Orange color
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
                          color: Colors.black87, // Match the dark text color
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
                                  backgroundColor: AppColors.primary, // Sample Orange color
                                  minimumSize: const Size(double.infinity, 50), // Ensure height
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

                            const SizedBox(width: 12), // Spacing between buttons

                            // 2. Cancel Button (White with Black/Grey Border)
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50), // Ensure height
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
}



class _InfoColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoColumn({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22, color: Colors.grey[700]),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 1,
      color: Colors.grey.shade300,
    );
  }
}
