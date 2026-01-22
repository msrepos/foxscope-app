import 'package:flutter/material.dart';
import 'package:foxscope/core/theme/app_colors.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../market/presentation/pages/paying_screen.dart';

class RenewScope extends StatelessWidget {
  const RenewScope({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: "Scopes"),
      backgroundColor: const Color(0xFFF2F2F2),
      body: Column(
        children: [
          // scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildScopeCard(context),
            ),
          ),

          // button pinned above the footer
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  //todo
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => const PaymentGateway(scopeData: {},, subscriptionType: '',),
                  //   ),
                  // );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Renew",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppFooter(currentIndex: 0),
    );
  }

  Widget _buildScopeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all( 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFD8D8D8),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/profile_sample.png',
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "AhmedMohamed",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF000080),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: const Text(
                            "Ahmed Mohamed",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.more_vert,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Action icons row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26,vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _actionIcon(Icons.map_outlined, "Go"),
                _actionIcon(Icons.arrow_forward, "Forward"),
                _actionIcon(Icons.share_outlined, "Share"),
                _actionIcon(Icons.qr_code_2, "QR"),
                _actionIcon(Icons.copy, "Copy"),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1,indent: 15,endIndent: 15,),

          // Government office pill
          const SizedBox(height: 12),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E9DD),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              "Government Office",
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1,indent: 15,endIndent: 15,),

          // Location / Views / Saved
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _InfoColumn(
                  icon: Icons.location_on_outlined,
                  label: "Location",
                  value: "Qatar",
                ),
                _DashedDivider(),
                _InfoColumn(
                  icon: Icons.remove_red_eye_outlined,
                  label: "Views",
                  value: "1M",
                ),
                _DashedDivider(),
                _InfoColumn(
                  icon: Icons.save_outlined,
                  label: "Saved",
                  value: "2",
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1,indent: 15,endIndent: 15,),

          // Created / Expired row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Created",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                        fontWeight: FontWeight.bold

                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  ": 28/02/2023",
                  style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Expired",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  ": 28/02/2023",
                  style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const Divider(height: 1,indent: 15,endIndent: 15,),

          // Description + small icons
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Text(
                    "Lorem Ipsum is simply dummy text of the printing",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(width: 20),
                Row(
                  children: const [
                    Icon(Icons.edit,
                        size: 20, color: Color(0xFF000080)),
                    SizedBox(width: 8),
                    Icon(Icons.delete_outline,
                        size: 20, color:Color(0xFF000080)),
                    SizedBox(width: 8),
                    Icon(Icons.group_outlined,
                        size: 20, color:Color(0xFF000080)),
                  ],
                ),
                const SizedBox(width: 15),

              ],
            ),
          ),

          const Divider(height: 1,indent: 15,endIndent: 15,),

          // Bottom icons (Address, Website, Working Hours, Mobile)
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 34),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _BottomIcon(
                  icon: Icons.location_on_outlined,
                  label: "Address",
                ),
                _BottomIcon(
                  icon: Icons.public,
                  label: "Website",
                ),
                _BottomIcon(
                  icon: Icons.access_time,
                  label: "Working Hours",
                ),
                _BottomIcon(
                  icon: Icons.smartphone,
                  label: "Mobile",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            //color: const Color(0xFFFFF4E8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary, width: 1.3),
          ),
          child: Icon(
            icon,
            size: 24,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoColumn({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22, color: Colors.grey[700]),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

/// vertical dotted divider between info columns
class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Colors.grey,
            width: 0.5,
            style: BorderStyle.solid,
          ),
        ),
      ),
    );
  }
}

class _BottomIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BottomIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4E8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 22, color: AppColors.primary),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
