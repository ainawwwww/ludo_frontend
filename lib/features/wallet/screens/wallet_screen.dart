import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/shared/widgets/app_background.dart';
import 'package:ludo_vibe/shared/widgets/orange_button.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<_TransactionItem> _transactions = const [
    _TransactionItem(title: 'Match Victory Reward', date: 'Today, 14:20', amount: '+ 2,000 Coins', isCredit: true),
    _TransactionItem(title: 'Ludo Lobby Entry Bet', date: 'Today, 14:15', amount: '- 500 Coins', isCredit: false),
    _TransactionItem(title: 'Daily Task Bonus', date: 'Yesterday', amount: '+ 500 Coins', isCredit: true),
    _TransactionItem(title: 'Gold Pack Purchase', date: 'Jul 30', amount: '+ 50,000 Coins', isCredit: true),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22 * scale),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        'MY WALLET',
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

              // Wallet Card
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                padding: EdgeInsets.all(20 * scale),
                decoration: BoxDecoration(
                  gradient: AppColors.modalGradient,
                  borderRadius: BorderRadius.circular(24 * scale),
                  border: Border.all(color: const Color(0xFFFFD369), width: 1.5 * scale),
                  boxShadow: [
                    BoxShadow(color: AppColors.shadowDark, blurRadius: 10 * scale),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'TOTAL BALANCE',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11 * scale,
                        color: Colors.white70,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/graphics/icon_coins.png', width: 32 * scale, height: 32 * scale),
                        SizedBox(width: 8 * scale),
                        Text(
                          '33,500 COINS',
                          style: AppTextStyles.headingLarge.copyWith(
                            fontSize: 24 * scale,
                            color: const Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16 * scale),
                    Row(
                      children: [
                        Expanded(
                          child: OrangeButton(
                            text: 'ADD COINS',
                            onPressed: () => context.push(AppConstants.goldShopRoute),
                            height: 38 * scale,
                          ),
                        ),
                        SizedBox(width: 12 * scale),
                        Expanded(
                          child: Container(
                            height: 38 * scale,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0C073E).withOpacity(0.6),
                              borderRadius: BorderRadius.circular(19 * scale),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Center(
                              child: Text(
                                'WITHDRAW',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12 * scale,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8 * scale),

              // Tabs
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16 * scale),
                height: 40 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFF0C073E).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20 * scale),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: AppColors.leagueCardGradient,
                    borderRadius: BorderRadius.circular(20 * scale),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 11 * scale, fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'History'),
                    Tab(text: 'Deposit'),
                    Tab(text: 'Withdrawal'),
                  ],
                ),
              ),
              SizedBox(height: 12 * scale),

              // History list
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildHistoryList(scale),
                    _buildDepositPlaceholder(scale),
                    _buildWithdrawPlaceholder(scale),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList(double scale) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final tx = _transactions[index];
        return Container(
          margin: EdgeInsets.only(bottom: 10 * scale),
          padding: EdgeInsets.all(12 * scale),
          decoration: BoxDecoration(
            color: const Color(0xFF1B114D).withOpacity(0.7),
            borderRadius: BorderRadius.circular(16 * scale),
            border: Border.all(color: AppColors.primaryBorder.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                tx.isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                color: tx.isCredit ? const Color(0xFF56AB2F) : const Color(0xFFE31E24),
                size: 24 * scale,
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.title,
                      style: AppTextStyles.bodyMediumBold.copyWith(fontSize: 13 * scale, color: Colors.white),
                    ),
                    SizedBox(height: 2 * scale),
                    Text(
                      tx.date,
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 10 * scale, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              Text(
                tx.amount,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.bold,
                  color: tx.isCredit ? const Color(0xFF56AB2F) : const Color(0xFFE31E24),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDepositPlaceholder(double scale) {
    return Center(
      child: Text(
        'Select Payment Gateway (UPI / Credit Card / Wallet)',
        style: TextStyle(fontFamily: 'Poppins', fontSize: 12 * scale, color: Colors.white60),
      ),
    );
  }

  Widget _buildWithdrawPlaceholder(double scale) {
    return Center(
      child: Text(
        'Min Withdrawal: 1,000 Coins (\$1.00 USD)',
        style: TextStyle(fontFamily: 'Poppins', fontSize: 12 * scale, color: Colors.white60),
      ),
    );
  }
}

class _TransactionItem {
  final String title;
  final String date;
  final String amount;
  final bool isCredit;

  const _TransactionItem({
    required this.title,
    required this.date,
    required this.amount,
    required this.isCredit,
  });
}
