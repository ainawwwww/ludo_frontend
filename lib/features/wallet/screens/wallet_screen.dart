import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/features/wallet/models/wallet_management_models.dart';
import 'package:ludo_vibe/features/wallet/providers/wallet_management_provider.dart';
import 'package:ludo_vibe/features/wallet/widgets/wallet_modals.dart';
import 'package:ludo_vibe/shared/widgets/app_background.dart';
import 'package:ludo_vibe/shared/widgets/app_close_button.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  int _selectedFilterIndex = 0; // 0: All, 1: Deposits, 2: Withdrawals, 3: Conversions

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale =
        (size.width / AppConstants.designWidth).clamp(0.8, 1.25);
    final walletState = ref.watch(walletManagementProvider);
    final isPkr = walletState.currencyMode == CurrencyMode.pkr;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0826),
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top Header Bar with Standard AppCloseButton & Currency Mode Switcher
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 14 * scale, vertical: 8 * scale),
                child: Row(
                  children: [
                    AppCloseButton(
                      size: 36 * scale,
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppConstants.homeRoute);
                        }
                      },
                    ),
                    SizedBox(width: 10 * scale),
                    Expanded(
                      child: Text(
                        'WALLET MANAGEMENT',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFFD54F),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    // Currency Toggle Pill (PKR / USD)
                    Container(
                      padding: EdgeInsets.all(2 * scale),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F114D),
                        borderRadius: BorderRadius.circular(16 * scale),
                        border: Border.all(
                            color: const Color(0xFF7A5EC7), width: 1.2),
                      ),
                      child: Row(
                        children: [
                          _buildCurrencyToggleChip('PKR', isPkr, () {
                            ref
                                .read(walletManagementProvider.notifier)
                                .switchCurrency(CurrencyMode.pkr);
                          }, scale),
                          _buildCurrencyToggleChip('USD', !isPkr, () {
                            ref
                                .read(walletManagementProvider.notifier)
                                .switchCurrency(CurrencyMode.usd);
                          }, scale),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Main Scrollable Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                      horizontal: 14 * scale, vertical: 6 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Hero Total Balance Card
                      _buildHeroBalanceCard(walletState, scale),
                      SizedBox(height: 14 * scale),

                      // 2. Main Action Buttons Row (DEPOSIT & WITHDRAW)
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionBigButton(
                              label: 'DEPOSIT',
                              subLabel: 'Add Funds via JazzCash / EasyPaisa',
                              icon: Icons.add_card_rounded,
                              gradientColors: const [
                                Color(0xFF22C55E),
                                Color(0xFF15803D),
                              ],
                              shadowColor: const Color(0x6622C55E),
                              onTap: () => DepositModalSheet.show(context),
                              scale: scale,
                            ),
                          ),
                          SizedBox(width: 10 * scale),
                          Expanded(
                            child: _buildActionBigButton(
                              label: 'WITHDRAW',
                              subLabel: 'Cash out to Bank or Mobile Wallet',
                              icon: Icons.payments_rounded,
                              gradientColors: const [
                                Color(0xFFFFB300),
                                Color(0xFFD97706),
                              ],
                              shadowColor: const Color(0x66FFB300),
                              onTap: () => WithdrawModalSheet.show(context),
                              scale: scale,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16 * scale),

                      // 3. Quick Converters Section (Money to Coins & Coins to Money)
                      Text(
                        'QUICK CONVERTERS',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFFD54F),
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 8 * scale),
                      Row(
                        children: [
                          Expanded(
                            child: _buildConverterCard(
                              title: 'Money ➔ Coins',
                              desc: 'Instant Coin Top-up',
                              rate: isPkr
                                  ? 'Rs 100 = 10,000 Coins'
                                  : '\$1 = 28,000 Coins',
                              btnText: 'Convert',
                              btnColor: const Color(0xFF3B82F6),
                              onTap: () => QuickConverterModalSheet.show(
                                  context,
                                  isMoneyToCoins: true),
                              scale: scale,
                            ),
                          ),
                          SizedBox(width: 10 * scale),
                          Expanded(
                            child: _buildConverterCard(
                              title: 'Coins ➔ Money',
                              desc: 'Coins into Cash Credit',
                              rate: isPkr
                                  ? '10,000 Coins = Rs 100'
                                  : '28,000 Coins = \$1.0',
                              btnText: 'Cash Out',
                              btnColor: const Color(0xFFA855F7),
                              onTap: () => QuickConverterModalSheet.show(
                                  context,
                                  isMoneyToCoins: false),
                              scale: scale,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 18 * scale),

                      // 4. Linked Payment Accounts Section (JazzCash / EasyPaisa / Bank)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'PAYMENT ACCOUNTS',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13 * scale,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFFFD54F),
                              letterSpacing: 0.5,
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                ManagePaymentAccountSheet.show(context),
                            child: Row(
                              children: [
                                Icon(Icons.add_circle_outline_rounded,
                                    color: const Color(0xFF60A5FA),
                                    size: 16 * scale),
                                SizedBox(width: 4 * scale),
                                Text(
                                  'Add Account',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12 * scale,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF60A5FA),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8 * scale),
                      _buildPaymentAccountsList(walletState, scale),
                      SizedBox(height: 18 * scale),

                      // 5. Transaction History Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TRANSACTION HISTORY',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13 * scale,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFFFD54F),
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            '${walletState.transactions.length} Records',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11 * scale,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8 * scale),

                      // Filter chips for History
                      _buildHistoryFilterTabs(scale),
                      SizedBox(height: 10 * scale),

                      // History List
                      _buildHistoryList(walletState, scale),
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

  Widget _buildCurrencyToggleChip(
      String label, bool isSelected, VoidCallback onTap, double scale) {
    return GestureDetector(
      onTap: () {
        SoundService().playButtonClick();
        onTap();
      },
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD54F) : Colors.transparent,
          borderRadius: BorderRadius.circular(12 * scale),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11 * scale,
            fontWeight: FontWeight.w900,
            color: isSelected ? Colors.black : Colors.white70,
          ),
        ),
      ),
    );
  }

  // --- Hero Balance Card ---
  Widget _buildHeroBalanceCard(WalletManagementState state, double scale) {
    final currencySymbol = state.currencySymbol;
    final moneyEst = state.estimatedMoneyValue;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF381577),
            Color(0xFF200C4D),
            Color(0xFF140733),
          ],
        ),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
          BoxShadow(
            color: Color(0x33FFD54F),
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ESTIMATED CASH VALUE',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 8 * scale, vertical: 2 * scale),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8 * scale),
                  border: Border.all(color: const Color(0xFF22C55E), width: 1),
                ),
                child: Text(
                  'Active Wallet',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 9.5 * scale,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4ADE80),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6 * scale),

          // Big Cash Value
          Row(
            children: [
              Text(
                '$currencySymbol ',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22 * scale,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFFFD54F),
                ),
              ),
              Text(
                moneyEst.toStringAsFixed(2),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 30 * scale,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(width: 8 * scale),
              Text(
                state.currencyCode,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),
          const Divider(color: Color(0xFF4A2C8F), height: 1),
          SizedBox(height: 12 * scale),

          // Coins & Diamonds Pill Row
          Row(
            children: [
              // Coins Pill
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10 * scale, vertical: 8 * scale),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D0E44),
                    borderRadius: BorderRadius.circular(12 * scale),
                    border: Border.all(color: const Color(0xFF5333A0)),
                  ),
                  child: Row(
                    children: [
                      Image.asset('assets/graphics/icon_coins.png',
                          width: 22 * scale, height: 22 * scale),
                      SizedBox(width: 8 * scale),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('COINS',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 9 * scale,
                                  color: Colors.white54,
                                  fontWeight: FontWeight.bold)),
                          Text(
                            NumberFormat('#,###').format(state.coins),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFFFD54F),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10 * scale),
              // Diamonds Pill
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10 * scale, vertical: 8 * scale),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D0E44),
                    borderRadius: BorderRadius.circular(12 * scale),
                    border: Border.all(color: const Color(0xFF5333A0)),
                  ),
                  child: Row(
                    children: [
                      Image.asset('assets/graphics/icon_diamond.png',
                          width: 22 * scale, height: 22 * scale),
                      SizedBox(width: 8 * scale),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DIAMONDS',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 9 * scale,
                                  color: Colors.white54,
                                  fontWeight: FontWeight.bold)),
                          Text(
                            NumberFormat('#,###').format(state.diamonds),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF00E5FF),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Big Action Buttons ---
  Widget _buildActionBigButton({
    required String label,
    required String subLabel,
    required IconData icon,
    required List<Color> gradientColors,
    required Color shadowColor,
    required VoidCallback onTap,
    required double scale,
  }) {
    return GestureDetector(
      onTap: () {
        SoundService().playButtonClick();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: 12 * scale, vertical: 12 * scale),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(16 * scale),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8 * scale),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 22 * scale),
            ),
            SizedBox(width: 8 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    subLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9 * scale,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Converter Card ---
  Widget _buildConverterCard({
    required String title,
    required String desc,
    required String rate,
    required String btnText,
    required Color btnColor,
    required VoidCallback onTap,
    required double scale,
  }) {
    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF221355),
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(color: const Color(0xFF5A41A0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.5 * scale,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2 * scale),
          Text(
            rate,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10 * scale,
              color: const Color(0xFFFFD54F),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10 * scale),
          SizedBox(
            width: double.infinity,
            height: 32 * scale,
            child: ElevatedButton(
              onPressed: () {
                SoundService().playButtonClick();
                onTap();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: btnColor,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
              ),
              child: Text(
                btnText,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Payment Accounts List ---
  Widget _buildPaymentAccountsList(WalletManagementState state, double scale) {
    if (state.paymentAccounts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(14 * scale),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1045),
          borderRadius: BorderRadius.circular(14 * scale),
          border: Border.all(color: Colors.white12),
        ),
        child: Center(
          child: Text(
            'No JazzCash, EasyPaisa, or Bank Account added yet.',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12 * scale,
                color: Colors.white60),
          ),
        ),
      );
    }

    return Column(
      children: state.paymentAccounts.map((acc) {
        return Container(
          margin: EdgeInsets.only(bottom: 8 * scale),
          padding: EdgeInsets.all(12 * scale),
          decoration: BoxDecoration(
            color: const Color(0xFF200F4E),
            borderRadius: BorderRadius.circular(14 * scale),
            border: Border.all(color: const Color(0xFF4C2F8A)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8 * scale),
                decoration: BoxDecoration(
                  color: acc.type == PaymentMethodType.jazzcash
                      ? const Color(0xFFFF416C).withOpacity(0.2)
                      : acc.type == PaymentMethodType.easypaisa
                          ? const Color(0xFF00B09B).withOpacity(0.2)
                          : const Color(0xFF7A5EC7).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  acc.type == PaymentMethodType.jazzcash
                      ? Icons.phone_android_rounded
                      : acc.type == PaymentMethodType.easypaisa
                          ? Icons.account_balance_wallet_rounded
                          : Icons.account_balance_rounded,
                  color: acc.type == PaymentMethodType.jazzcash
                      ? const Color(0xFFFF416C)
                      : acc.type == PaymentMethodType.easypaisa
                          ? const Color(0xFF00B09B)
                          : const Color(0xFFB388FF),
                  size: 20 * scale,
                ),
              ),
              SizedBox(width: 10 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          acc.type == PaymentMethodType.jazzcash
                              ? 'JazzCash'
                              : acc.type == PaymentMethodType.easypaisa
                                  ? 'EasyPaisa'
                                  : (acc.bankName ?? 'Bank'),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (acc.isDefault) ...[
                          SizedBox(width: 6 * scale),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6 * scale, vertical: 1.5 * scale),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD54F).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4 * scale),
                            ),
                            child: Text(
                              'Default',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 8.5 * scale,
                                  color: const Color(0xFFFFD54F),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '${acc.accountTitle} • ${acc.accountNumber}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11 * scale,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit_outlined,
                    color: const Color(0xFFB388FF), size: 18 * scale),
                onPressed: () => ManagePaymentAccountSheet.show(context,
                    account: acc),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // --- History Filter Tabs ---
  Widget _buildHistoryFilterTabs(double scale) {
    final filters = ['All', 'Deposits', 'Withdrawals', 'Conversions'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.asMap().entries.map((entry) {
          final isSelected = _selectedFilterIndex == entry.key;
          return Padding(
            padding: EdgeInsets.only(right: 8 * scale),
            child: ChoiceChip(
              label: Text(
                entry.value,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.black : Colors.white70,
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFFFFD54F),
              backgroundColor: const Color(0xFF221355),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFFFFD54F)
                    : const Color(0xFF4C2F8A),
              ),
              onSelected: (val) {
                if (val) {
                  SoundService().playButtonClick();
                  setState(() => _selectedFilterIndex = entry.key);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- History List ---
  Widget _buildHistoryList(WalletManagementState state, double scale) {
    List<WalletRecord> filtered = state.transactions;

    if (_selectedFilterIndex == 1) {
      filtered = filtered
          .where((t) => t.type == TransactionType.deposit)
          .toList();
    } else if (_selectedFilterIndex == 2) {
      filtered = filtered
          .where((t) => t.type == TransactionType.withdraw)
          .toList();
    } else if (_selectedFilterIndex == 3) {
      filtered = filtered
          .where((t) =>
              t.type == TransactionType.moneyToCoins ||
              t.type == TransactionType.coinsToMoney)
          .toList();
    }

    if (filtered.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(24 * scale),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1045),
          borderRadius: BorderRadius.circular(14 * scale),
        ),
        child: Center(
          child: Text(
            'No transactions in this category.',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12 * scale,
                color: Colors.white54),
          ),
        ),
      );
    }

    return Column(
      children: filtered.map((tx) {
        final isCredit = tx.coinsDelta >= 0;
        final currencySymbol = state.currencySymbol;

        return Container(
          margin: EdgeInsets.only(bottom: 8 * scale),
          padding: EdgeInsets.all(12 * scale),
          decoration: BoxDecoration(
            color: const Color(0xFF200F4E),
            borderRadius: BorderRadius.circular(14 * scale),
            border: Border.all(color: const Color(0xFF4C2F8A)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8 * scale),
                decoration: BoxDecoration(
                  color: isCredit
                      ? const Color(0xFF22C55E).withOpacity(0.18)
                      : const Color(0xFFEF4444).withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCredit
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: isCredit
                      ? const Color(0xFF4ADE80)
                      : const Color(0xFFF87171),
                  size: 18 * scale,
                ),
              ),
              SizedBox(width: 10 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.description,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2 * scale),
                    Row(
                      children: [
                        Text(
                          DateFormat('dd MMM, hh:mm a').format(tx.timestamp),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10 * scale,
                            color: Colors.white54,
                          ),
                        ),
                        if (tx.referenceId != null) ...[
                          const Text(' • ',
                              style: TextStyle(color: Colors.white38)),
                          Text(
                            'Ref: ${tx.referenceId}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10 * scale,
                              color: const Color(0xFFFFD54F),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isCredit ? "+" : ""}${tx.coinsDelta} Coins',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.5 * scale,
                      fontWeight: FontWeight.w900,
                      color: isCredit
                          ? const Color(0xFF4ADE80)
                          : const Color(0xFFF87171),
                    ),
                  ),
                  Text(
                    '$currencySymbol ${tx.amountMoney.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10.5 * scale,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2 * scale),
                  _buildStatusBadge(tx.status, scale),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusBadge(TransactionStatus status, double scale) {
    Color color;
    String label;

    switch (status) {
      case TransactionStatus.completed:
        color = const Color(0xFF22C55E);
        label = 'Completed';
        break;
      case TransactionStatus.pending:
        color = const Color(0xFFFFB300);
        label = 'Pending';
        break;
      case TransactionStatus.failed:
        color = const Color(0xFFEF4444);
        label = 'Failed';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6 * scale, vertical: 1 * scale),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(4 * scale),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 8.5 * scale,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
