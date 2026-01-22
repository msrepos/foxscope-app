
import 'package:flutter/material.dart';
import 'package:foxscope/features/market/presentation/pages/profile_market_place.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/widgets.dart';


class SelectBankCardWithActionPage extends StatefulWidget {
  const SelectBankCardWithActionPage({super.key});

  @override
  State<SelectBankCardWithActionPage> createState() =>
      _SelectBankCardWithActionPageState();
}

class _SelectBankCardWithActionPageState
    extends State<SelectBankCardWithActionPage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: "My Scopes"),
      backgroundColor: const Color(0xFFF2F2F2),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Select your Bank card",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),

            Widgets.instant.bankCardItem(
              selected: selectedIndex == 0,
              onTap: () => setState(() => selectedIndex = 0),
            ),
            Widgets.instant.bankCardItem(
              selected: selectedIndex == 1,
              onTap: () => setState(() => selectedIndex = 1),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text("Add to Marketplace"),
            ),
            const SizedBox(height: 10),

            OutlinedButton(
              onPressed: () {
                context.push('/add-card');
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text("Add New Card"),
            ),
          ],
        ),
      ),
    );
  }
}
