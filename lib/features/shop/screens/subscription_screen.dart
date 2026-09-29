import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/features/subscription/models/subscription_models.dart';
import 'package:ludo_vibe/features/subscription/providers/subscription_provider.dart';
import 'package:ludo_vibe/features/subscription/widgets/vip_checkout_sheet.dart';
import 'package:ludo_vibe/shared/widgets/app_background.dart';
import 'package:ludo_vibe/shared/widgets/orange_button.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  int _selectedPlanIndex = 0; // 0 = Knight, 1 = Baron

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;

    final subState = ref.watch(subscriptionProvider);
    final currentSub = subState.currentSubscription;

    // Plans list fallback to default 2 plans if API not loaded yet
    final plans = subState.plans.isNotEmpty
        ? subState.plans
        : [
            SubscriptionPlanDto(
              tier: 'knight',
              title: 'KNIGHT PASS',
              price: 4.99,
              currency: 'USD',
              dailyCoins: 200,
              dailyDiamonds: 5,
            ),
            SubscriptionPlanDto(
              tier: 'baron',
              title: 'BARON PASS',
              price: 14.99,
              currency: 'USD',
              dailyCoins: 500,
              dailyDiamonds: 15,
            ),
          ];

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 16 * scale, vertical: 8 * scale),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 22 * scale),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        'VIP MEMBERSHIP PASS',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headingMedium.copyWith(
                          fontSize: 18 * scale,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 48 * scale),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                  child: Column(
                    children: [
                      SizedBox(height: 12 * scale),

                      // Subscription Crown Graphic Header
                      Container(
                        width: 80 * scale,
                        height: 80 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFFD369).withOpacity(0.2),
                          border: Border.all(
                              color: const Color(0xFFFFD369), width: 2 * scale),
                        ),
                        child: Icon(
                          Icons.workspace_premium_rounded,
                          size: 52 * scale,
                          color: const Color(0xFFFFD369),
                        ),
                      ),
                      SizedBox(height: 12 * scale),

                      if (currentSub != null && currentSub.isActive)
                        _buildActiveSubscriberView(context, currentSub, scale)
                      else
                        _buildNonSubscriberView(context, plans, scale),

                      SizedBox(height: 24 * scale),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Active Subscriber View
  // ---------------------------------------------------------------------------

  Widget _buildActiveSubscriberView(
      BuildContext context, SubscriptionDto sub, double scale) {
    final subState = ref.watch(subscriptionProvider);
    final isKnight = sub.tier.toLowerCase() == 'knight';
    final tierColor = isKnight ? const Color(0xFF5641F8) : const Color(0xFFFFD369);
    final title = isKnight ? 'KNIGHT PASS' : 'BARON PASS';

    final endDateStr = sub.currentPeriodEnd != null
        ? DateFormat('MMM dd, yyyy').format(sub.currentPeriodEnd!)
        : 'Active';

    final statusSubtitle = sub.autoRenew
        ? 'Renews on $endDateStr'
        : 'Ends on $endDateStr (Cancelled)';

    return Column(
      children: [
        Text(
          'YOUR VIP MEMBERSHIP',
          style: AppTextStyles.headingMedium.copyWith(
            fontSize: 18 * scale,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16 * scale),

        // Membership Card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20 * scale),
          decoration: BoxDecoration(
            gradient: AppColors.modalGradient,
            borderRadius: BorderRadius.circular(20 * scale),
            border: Border.all(color: tierColor, width: 3 * scale),
            boxShadow: [
              BoxShadow(
                color: tierColor.withOpacity(0.35),
                blurRadius: 18 * scale,
                spreadRadius: 2 * scale,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.stars_rounded, color: tierColor, size: 32 * scale),
                  SizedBox(width: 10 * scale),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.headingMedium.copyWith(
                            fontSize: 20 * scale,
                            color: tierColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          statusSubtitle,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12 * scale,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 6 * scale),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10 * scale, vertical: 4 * scale),
                    decoration: BoxDecoration(
                      color: sub.autoRenew ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12 * scale),
                      border: Border.all(
                          color: sub.autoRenew ? Colors.greenAccent : Colors.orangeAccent),
                    ),
                    child: Text(
                      sub.autoRenew ? 'ACTIVE' : 'NON-RENEWING',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10 * scale,
                        fontWeight: FontWeight.bold,
                        color: sub.autoRenew ? Colors.greenAccent : Colors.orangeAccent,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16 * scale),
              const Divider(color: Colors.white24, height: 1),
              SizedBox(height: 16 * scale),

              // Daily Reward Status
              Row(
                children: [
                  Icon(
                    sub.canClaimDailyReward
                        ? Icons.card_giftcard_rounded
                        : Icons.check_circle_outline_rounded,
                    color: sub.canClaimDailyReward ? Colors.orangeAccent : Colors.white38,
                    size: 22 * scale,
                  ),
                  SizedBox(width: 8 * scale),
                  Expanded(
                    child: Text(
                      sub.canClaimDailyReward
                          ? 'Daily VIP Reward Available!'
                          : 'Daily Reward Claimed Today',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13 * scale,
                        color: sub.canClaimDailyReward ? Colors.white : Colors.white54,
                        fontWeight: sub.canClaimDailyReward ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 24 * scale),

        // Claim Reward Button
        if (subState.isClaimLoading)
          const Center(child: CircularProgressIndicator())
        else
          OrangeButton(
            key: const Key('claim_daily_reward_button'),
            text: sub.canClaimDailyReward ? 'CLAIM DAILY REWARD' : 'REWARD CLAIMED TODAY',
            onPressed: sub.canClaimDailyReward
                ? () async {
                    final success = await ref
                        .read(subscriptionProvider.notifier)
                        .claimDailyReward();
                    if (success && mounted) {
                      final msg = ref.read(subscriptionProvider).actionSuccessMessage;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(msg ?? 'Claimed daily reward!'),
                          backgroundColor: const Color(0xFF56AB2F),
                        ),
                      );
                    }
                  }
                : null,
            width: double.infinity,
            height: 50 * scale,
          ),

        SizedBox(height: 16 * scale),

        // Cancel Subscription Button
        if (sub.autoRenew) ...[
          if (subState.isCancelLoading)
            const Center(child: CircularProgressIndicator())
          else
            OutlinedButton(
              key: const Key('cancel_subscription_button'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent, width: 1.5),
                padding: EdgeInsets.symmetric(vertical: 14 * scale),
                minimumSize: Size(double.infinity, 48 * scale),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14 * scale),
                ),
              ),
              onPressed: () => _confirmCancel(context),
              child: Text(
                'CANCEL SUBSCRIPTION',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ),
        ],
      ],
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text('Cancel Subscription?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Your VIP auto-renewal will be turned off. You will retain all VIP benefits until the end of your current period.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text('Keep VIP', style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.of(dialogCtx).pop(),
          ),
          ElevatedButton(
            key: const Key('confirm_cancel_button'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Cancel Auto-Renew', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              final success =
                  await ref.read(subscriptionProvider.notifier).cancel();
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Auto-renewal cancelled.'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Non-Subscriber View
  // ---------------------------------------------------------------------------

  Widget _buildNonSubscriberView(
      BuildContext context, List<SubscriptionPlanDto> plans, double scale) {
    final knightPlan = plans.firstWhere((p) => p.tier.toLowerCase() == 'knight',
        orElse: () => SubscriptionPlanDto(
            tier: 'knight',
            title: 'KNIGHT PASS',
            price: 4.99,
            currency: 'USD',
            dailyCoins: 200,
            dailyDiamonds: 5));

    final baronPlan = plans.firstWhere((p) => p.tier.toLowerCase() == 'baron',
        orElse: () => SubscriptionPlanDto(
            tier: 'baron',
            title: 'BARON PASS',
            price: 14.99,
            currency: 'USD',
            dailyCoins: 500,
            dailyDiamonds: 15));

    final selectedPlan = _selectedPlanIndex == 0 ? knightPlan : baronPlan;

    return Column(
      children: [
        Text(
          'CHOOSE YOUR ROYAL RANK',
          style: AppTextStyles.headingMedium.copyWith(
            fontSize: 18 * scale,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16 * scale),

        // Knight Plan Card
        _buildPlanCard(
          index: 0,
          plan: knightPlan,
          color: const Color(0xFF5641F8),
          perks: const [
            '200 Daily Bonus Gold Coins',
            '5 Daily Bonus Diamonds',
            'Knight VIP Badge & Profile Highlight',
            'Create VIP Game Rooms',
          ],
          scale: scale,
        ),
        SizedBox(height: 14 * scale),

        // Baron Plan Card
        _buildPlanCard(
          index: 1,
          plan: baronPlan,
          color: const Color(0xFFFFD369),
          badge: 'MOST POPULAR',
          perks: const [
            '500 Daily Bonus Gold Coins',
            '15 Daily Bonus Diamonds',
            'Baron Golden Profile Frame',
            'Create VIP Game Rooms',
            'VIP Voice Lounge Hosting (Coming Soon)',
          ],
          scale: scale,
        ),
        SizedBox(height: 24 * scale),

        // CTA Button
        OrangeButton(
          key: const Key('continue_to_checkout_button'),
          text: 'CONTINUE TO CHECKOUT',
          onPressed: () {
            VipCheckoutSheet.show(context, selectedPlan);
          },
          width: double.infinity,
          height: 50 * scale,
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required int index,
    required SubscriptionPlanDto plan,
    required Color color,
    required List<String> perks,
    required double scale,
    String? badge,
  }) {
    final isSelected = _selectedPlanIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlanIndex = index),
      child: AnimatedContainer(
        duration: AppConstants.animationFast,
        padding: EdgeInsets.all(16 * scale),
        decoration: BoxDecoration(
          gradient: AppColors.modalGradient,
          borderRadius: BorderRadius.circular(20 * scale),
          border: Border.all(
            color: isSelected ? color : Colors.white24,
            width: isSelected ? 3 * scale : 1 * scale,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 16 * scale,
                spreadRadius: 1 * scale,
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: isSelected ? color : Colors.white60,
                  size: 24 * scale,
                ),
                SizedBox(width: 10 * scale),
                Expanded(
                  child: Text(
                    plan.title,
                    style: AppTextStyles.headingMedium.copyWith(
                      fontSize: 16 * scale,
                      color: isSelected ? color : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 8 * scale),
                Text(
                  '\$${plan.price.toStringAsFixed(2)} / Month',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12 * scale),
            const Divider(color: Colors.white24, height: 1),
            SizedBox(height: 12 * scale),
            ...perks.map(
              (perk) => Padding(
                padding: EdgeInsets.only(bottom: 6 * scale),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: color, size: 16 * scale),
                    SizedBox(width: 8 * scale),
                    Expanded(
                      child: Text(
                        perk,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11 * scale,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
