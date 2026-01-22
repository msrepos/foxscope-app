import 'package:flutter/material.dart';
import 'package:foxscope/features/market/presentation/pages/profile_market_place.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/widgets.dart';
import 'add_card.dart';

class SelectBankCardPage extends StatefulWidget {
  const SelectBankCardPage({super.key});

  @override
  State<SelectBankCardPage> createState() => _SelectBankCardPageState();
}

class _SelectBankCardPageState extends State<SelectBankCardPage> {
  int? selectedCardIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: "My Scopes"),
      backgroundColor: const Color(0xFFF2F2F2),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16), // ✅ rounded corners
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // ✅ wrap content height
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select your Bank card",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Widgets.instant.bankCardItem(
                selected: selectedCardIndex == 0,
                onTap: () {
                  setState(() {
                    selectedCardIndex = 0;
                  });
                },
              ),
              Widgets.instant.bankCardItem(
                selected: selectedCardIndex == 1,
                onTap: () {
                  setState(() {
                    selectedCardIndex = 1;
                  });
                },
              ),
              const SizedBox(height: 15),
              if (selectedCardIndex != null) ...[
                ElevatedButton(
                  onPressed: () {
                   Navigator.pop(context);
                   Navigator.pop(context);

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Add To Marketplace",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddCardPage(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    side: BorderSide(color: AppColors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Add New card",
                    style: TextStyle(color: AppColors.black),
                  ),
                ),
              ],
              if (selectedCardIndex == null)
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddCardPage(),
                      ),
                    );                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Add New Card",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
