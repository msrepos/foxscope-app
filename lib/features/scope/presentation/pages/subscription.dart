import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../market/presentation/pages/paying_screen.dart';


class SubscriptionPage extends StatefulWidget {
  final Map<String, dynamic>? scopeData;

  const SubscriptionPage({this.scopeData, super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final PageController _pageController = PageController();
  int currentIndex = 0;
  int selectedIndex = 0;
  bool _isProcessing = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: "Subscription"),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildSwitch(),
          const SizedBox(height: 24),

          Expanded( // ✅ gives PageView vertical bounds
            child: AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                    selectedIndex = index;
                  });
                },
                children: [
                  _buildPlanCard(
                    index: 0,
                    price: "QAR 4.99 / month",
                    showBadge: false,
                  ),
                  _buildPlanCard(
                    index: 1,
                    price: "QAR 50 / year",
                    showBadge: true,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isProcessing ? null : _handleSubscribe,
                child: _isProcessing
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  "Subscribe",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppFooter(currentIndex: 1),
    );
  }

  Future<void> _handleSubscribe() async {
    if (widget.scopeData == null) {
       Widgets.instant.showError(context,"No scope data available");
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
         Widgets.instant.showError(context,"Not logged in");
        setState(() => _isProcessing = false);
        return;
      }

      // Navigate to payment gateway with scope data
      final result = await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentGateway(
            scopeData: widget.scopeData!,
            subscriptionType: selectedIndex == 0 ? 'monthly' : 'yearly',
          ),
        ),
      );

      if (result == true && mounted) {
        // Payment successful, navigate back
        Navigator.of(context).pop(true);
      }
    } catch (e) {
       Widgets.instant.showError(context,"Error: $e");
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }



  Widget _buildSwitch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double itemWidth = constraints.maxWidth / 2;

          return Container(
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.primary),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  left: currentIndex * itemWidth,
                  child: IgnorePointer(
                    ignoring: true,
                    child: Container(
                      width: itemWidth,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    _buildSwitchText("Monthly", 0),
                    _buildSwitchText("Annually", 1),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSwitchText(String text, int index) {
    final bool isSelected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (currentIndex == index) return;

          setState(() {
            currentIndex = index;
            selectedIndex = index;
          });

          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        },
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required int index,
    required String price,
    required bool showBadge,
  }) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => selectedIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey.shade100,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade400,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (showBadge)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Best offer",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                "Upgrade to Prime to enjoy map visibility and a customized Prime name — stand out and get discovered faster!",
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),

      ),
    );
  }
}