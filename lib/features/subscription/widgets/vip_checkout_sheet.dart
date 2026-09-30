import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/features/subscription/models/subscription_models.dart';
import 'package:ludo_vibe/features/subscription/providers/subscription_provider.dart';
import 'package:ludo_vibe/shared/widgets/orange_button.dart';

class VipCheckoutSheet extends ConsumerStatefulWidget {
  const VipCheckoutSheet({
    super.key,
    required this.plan,
  });

  final SubscriptionPlanDto plan;

  static Future<bool?> show(BuildContext context, SubscriptionPlanDto plan) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VipCheckoutSheet(plan: plan),
    );
  }

  @override
  ConsumerState<VipCheckoutSheet> createState() => _VipCheckoutSheetState();
}

class _VipCheckoutSheetState extends ConsumerState<VipCheckoutSheet> {
  final _cardNumberController = TextEditingController(text: '4532 •••• •••• 8892');
  final _expiryController = TextEditingController(text: '12/28');
  final _cvvController = TextEditingController(text: '882');

  bool _simulateDecline = false;
  bool _isProcessing = false;
  String? _inlineError;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _handlePayment() async {
    setState(() {
      _isProcessing = true;
      _inlineError = null;
    });

    // Simulated network/processing delay (1.2 seconds)
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    final success = await ref.read(subscriptionProvider.notifier).checkout(
          tier: widget.plan.tier,
          forceFailure: _simulateDecline,
        );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.plan.title} activated successfully!'),
          backgroundColor: const Color(0xFF56AB2F),
        ),
      );
    } else {
      final state = ref.read(subscriptionProvider);
      setState(() {
        _isProcessing = false;
        _inlineError = state.failure?.message ?? 'Payment failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / 393.0;

    final isKnight = widget.plan.tier.toLowerCase() == 'knight';
    final tierColor = isKnight ? const Color(0xFF5641F8) : const Color(0xFFFFD369);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.all(20 * scale),
        decoration: BoxDecoration(
          gradient: AppColors.modalGradient,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24 * scale)),
          border: Border.all(color: tierColor, width: 2 * scale),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.workspace_premium_rounded,
                    color: tierColor,
                    size: 28 * scale,
                  ),
                  SizedBox(width: 8 * scale),
                  Expanded(
                    child: Text(
                      'CHECKOUT - ${widget.plan.title}',
                      style: AppTextStyles.headingMedium.copyWith(
                        fontSize: 16 * scale,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: _isProcessing ? null : () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
              SizedBox(height: 12 * scale),
              const Divider(color: Colors.white24, height: 1),
              SizedBox(height: 16 * scale),

              // Plan Summary Card
              Container(
                padding: EdgeInsets.all(14 * scale),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(14 * scale),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.plan.title,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15 * scale,
                              fontWeight: FontWeight.bold,
                              color: tierColor,
                            ),
                          ),
                          SizedBox(height: 4 * scale),
                          Text(
                            '${widget.plan.dailyCoins} Gold Coins + ${widget.plan.dailyDiamonds} Diamonds daily',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11 * scale,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8 * scale),
                    Text(
                      '\$${widget.plan.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18 * scale,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16 * scale),

              // Dummy Card Entry Form
              Text(
                'PAYMENT METHOD (DUMMY GATEWAY)',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.white60,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: 8 * scale),
              TextField(
                controller: _cardNumberController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.credit_card_rounded, color: Colors.white70),
                  hintText: 'Card Number',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12 * scale),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 10 * scale),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expiryController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'MM/YY',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 * scale),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10 * scale),
                  Expanded(
                    child: TextField(
                      controller: _cvvController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'CVV',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 * scale),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12 * scale),

              // Debug-only Simulate Decline Toggle (kDebugMode)
              if (kDebugMode)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10 * scale),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bug_report_rounded, color: Colors.redAccent, size: 18),
                      SizedBox(width: 6 * scale),
                      Expanded(
                        child: Text(
                          'DEBUG: Simulate Payment Decline',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11 * scale,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Switch(
                        key: const Key('simulate_decline_switch'),
                        value: _simulateDecline,
                        activeColor: Colors.redAccent,
                        onChanged: (val) {
                          setState(() => _simulateDecline = val);
                        },
                      ),
                    ],
                  ),
                ),

              // Inline Error Message
              if (_inlineError != null) ...[
                SizedBox(height: 12 * scale),
                Container(
                  padding: EdgeInsets.all(10 * scale),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8 * scale),
                    border: Border.all(color: Colors.redAccent),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
                      SizedBox(width: 8 * scale),
                      Expanded(
                        child: Text(
                          _inlineError!,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12 * scale,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 20 * scale),

              // CTA Button / Loading State
              if (_isProcessing)
                Container(
                  height: 50 * scale,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(14 * scale),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    ),
                  ),
                )
              else
                OrangeButton(
                  text: 'PAY \$${widget.plan.price.toStringAsFixed(2)} & ACTIVATE VIP',
                  onPressed: _handlePayment,
                  width: double.infinity,
                  height: 50 * scale,
                ),
              SizedBox(height: 10 * scale),
            ],
          ),
        ),
      ),
    );
  }
}
