import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/features/wallet/models/wallet_management_models.dart';
import 'package:ludo_vibe/features/wallet/providers/wallet_management_provider.dart';
import 'package:ludo_vibe/shared/widgets/app_close_button.dart';

/// 1. DEPOSIT MODAL SHEET
class DepositModalSheet extends ConsumerStatefulWidget {
  const DepositModalSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DepositModalSheet(),
    );
  }

  @override
  ConsumerState<DepositModalSheet> createState() => _DepositModalSheetState();
}

class _DepositModalSheetState extends ConsumerState<DepositModalSheet> {
  PaymentMethodType _selectedMethod = PaymentMethodType.jazzcash;
  final TextEditingController _amountController =
      TextEditingController(text: '500');
  final TextEditingController _senderController = TextEditingController();
  final TextEditingController _trxIdController = TextEditingController();

  final List<double> _quickAmountsPkr = [200, 500, 1000, 2500, 5000];
  final List<double> _quickAmountsUsd = [5, 10, 25, 50, 100];

  @override
  void dispose() {
    _amountController.dispose();
    _senderController.dispose();
    _trxIdController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    SoundService().playButtonClick();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard!'),
        backgroundColor: const Color(0xFF2E1065),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale =
        (MediaQuery.sizeOf(context).width / AppConstants.designWidth).clamp(0.8, 1.25);
    final walletState = ref.watch(walletManagementProvider);
    final isPkr = walletState.currencyMode == CurrencyMode.pkr;
    final currencySymbol = walletState.currencySymbol;

    final parsedAmount = double.tryParse(_amountController.text) ?? 0.0;
    final coinsEquivalent = isPkr
        ? (parsedAmount * WalletManagementState.coinsPerPkr).round()
        : (parsedAmount * WalletManagementState.coinsPerUsd).round();

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.88,
      decoration: BoxDecoration(
        color: const Color(0xFF160D42),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24 * scale)),
        border: Border.all(color: const Color(0xFF7A5EC7), width: 1.5),
        boxShadow: const [
          BoxShadow(
              color: Colors.black87, blurRadius: 24, offset: Offset(0, -6)),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 16 * scale, vertical: 14 * scale),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6 * scale),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E1C7E),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add_card_rounded,
                      color: const Color(0xFF4ADE80), size: 20 * scale),
                ),
                SizedBox(width: 10 * scale),
                Text(
                  'DEPOSIT FUNDS',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                AppCloseButton(
                  size: 30 * scale,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF382375), height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment Method Selector
                  Text(
                    '1. Select Payment Method',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFD54F),
                    ),
                  ),
                  SizedBox(height: 10 * scale),
                  Row(
                    children: [
                      _buildMethodChip(
                        type: PaymentMethodType.jazzcash,
                        label: 'JazzCash',
                        icon: Icons.phone_android_rounded,
                        activeColor: const Color(0xFFFF416C),
                        scale: scale,
                      ),
                      SizedBox(width: 8 * scale),
                      _buildMethodChip(
                        type: PaymentMethodType.easypaisa,
                        label: 'EasyPaisa',
                        icon: Icons.account_balance_wallet_rounded,
                        activeColor: const Color(0xFF00B09B),
                        scale: scale,
                      ),
                      SizedBox(width: 8 * scale),
                      _buildMethodChip(
                        type: PaymentMethodType.bank,
                        label: 'Bank',
                        icon: Icons.account_balance_rounded,
                        activeColor: const Color(0xFF6A11CB),
                        scale: scale,
                      ),
                    ],
                  ),
                  SizedBox(height: 16 * scale),

                  // Official Account Card to Transfer to
                  _buildOfficialAccountCard(scale),
                  SizedBox(height: 18 * scale),

                  // Amount Selection
                  Text(
                    '2. Select or Enter Amount ($currencySymbol)',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFD54F),
                    ),
                  ),
                  SizedBox(height: 8 * scale),

                  // Quick amount chips
                  Wrap(
                    spacing: 8 * scale,
                    runSpacing: 8 * scale,
                    children: (isPkr ? _quickAmountsPkr : _quickAmountsUsd)
                        .map((amount) {
                      final isSelected =
                          parsedAmount == amount;
                      return ChoiceChip(
                        label: Text(
                          '$currencySymbol ${amount.toInt()}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 12 * scale,
                            color: isSelected ? Colors.black : Colors.white,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: const Color(0xFFFFD54F),
                        backgroundColor: const Color(0xFF2A1961),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFFFFD54F)
                              : const Color(0xFF5A41A0),
                        ),
                        onSelected: (val) {
                          if (val) {
                            SoundService().playButtonClick();
                            setState(() {
                              _amountController.text = amount.toInt().toString();
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 10 * scale),

                  // Custom Amount Input Field
                  TextField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14 * scale, vertical: 12 * scale),
                        child: Text(
                          currencySymbol,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: const Color(0xFFFFD54F),
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF221355),
                      hintText: 'Enter deposit amount',
                      hintStyle: const TextStyle(color: Colors.white38),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12 * scale),
                        borderSide:
                            const BorderSide(color: Color(0xFF5A41A0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12 * scale),
                        borderSide:
                            const BorderSide(color: Color(0xFF5A41A0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12 * scale),
                        borderSide: const BorderSide(
                            color: Color(0xFFFFD54F), width: 1.5),
                      ),
                    ),
                  ),
                  SizedBox(height: 6 * scale),

                  // Coins Preview Indicator
                  Row(
                    children: [
                      Icon(Icons.stars_rounded,
                          color: const Color(0xFFFFD54F), size: 16 * scale),
                      SizedBox(width: 4 * scale),
                      Text(
                        'You will receive: ',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12 * scale,
                            color: Colors.white70),
                      ),
                      Text(
                        '+$coinsEquivalent Coins',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF4ADE80),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18 * scale),

                  // Step 3: Proof of Payment
                  Text(
                    '3. Enter Transfer Verification Details',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFD54F),
                    ),
                  ),
                  SizedBox(height: 8 * scale),

                  TextField(
                    controller: _senderController,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontSize: 13 * scale),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF221355),
                      hintText: 'Your Sender Mobile / Account Number',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.person_outline_rounded,
                          color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12 * scale),
                        borderSide:
                            const BorderSide(color: Color(0xFF5A41A0)),
                      ),
                    ),
                  ),
                  SizedBox(height: 10 * scale),

                  TextField(
                    controller: _trxIdController,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontSize: 13 * scale),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF221355),
                      hintText: 'Transaction ID / Trx Ref (e.g. TID-98214)',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.receipt_long_rounded,
                          color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12 * scale),
                        borderSide:
                            const BorderSide(color: Color(0xFF5A41A0)),
                      ),
                    ),
                  ),
                  SizedBox(height: 24 * scale),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 48 * scale,
                    child: ElevatedButton(
                      onPressed: walletState.isSubmitting
                          ? null
                          : () async {
                              SoundService().playButtonClick();
                              final success = await ref
                                  .read(walletManagementProvider.notifier)
                                  .submitDeposit(
                                    moneyAmount: parsedAmount,
                                    currency: walletState.currencyMode,
                                    method: _selectedMethod,
                                    senderAccount: _senderController.text,
                                    transactionId: _trxIdController.text,
                                  );
                              if (success && mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Deposit of $currencySymbol${parsedAmount.toStringAsFixed(0)} verified! +$coinsEquivalent Coins credited.'),
                                    backgroundColor: const Color(0xFF22C55E),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14 * scale),
                        ),
                        elevation: 4,
                      ),
                      child: walletState.isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : Text(
                              'CONFIRM & SUBMIT DEPOSIT',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14 * scale,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 20 * scale),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodChip({
    required PaymentMethodType type,
    required String label,
    required IconData icon,
    required Color activeColor,
    required double scale,
  }) {
    final isSelected = _selectedMethod == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          SoundService().playButtonClick();
          setState(() => _selectedMethod = type);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10 * scale),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withOpacity(0.2) : const Color(0xFF221355),
            borderRadius: BorderRadius.circular(12 * scale),
            border: Border.all(
              color: isSelected ? activeColor : const Color(0xFF4A3188),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? activeColor : Colors.white70, size: 22 * scale),
              SizedBox(height: 4 * scale),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfficialAccountCard(double scale) {
    String title;
    String number;
    String? bankName;
    String? iban;

    switch (_selectedMethod) {
      case PaymentMethodType.jazzcash:
        title = 'LudoVibe Official';
        number = '0302-8877665';
        break;
      case PaymentMethodType.easypaisa:
        title = 'LudoVibe Official';
        number = '0345-1122334';
        break;
      case PaymentMethodType.bank:
        title = 'LudoVibe Gaming (Pvt) Ltd';
        bankName = 'Meezan Bank Ltd (Main Branch)';
        number = '01020304050601';
        iban = 'PK12MEZN0001020304050601';
        break;
    }

    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF261463),
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(color: const Color(0xFF7A5EC7).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: Color(0xFFFFD54F), size: 16),
              const SizedBox(width: 6),
              Text(
                'Transfer to Company Account:',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11 * scale,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          if (bankName != null) ...[
            Text('Bank: $bankName',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12 * scale,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 4 * scale),
          ],
          Row(
            children: [
              Expanded(
                child: Text('Title: $title',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12 * scale,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SizedBox(height: 4 * scale),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Account/No: $number',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13 * scale,
                    color: const Color(0xFFFFD54F),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _copyToClipboard(number, 'Account Number'),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A3188),
                    borderRadius: BorderRadius.circular(6 * scale),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.copy_rounded,
                          size: 12 * scale, color: Colors.white),
                      SizedBox(width: 4 * scale),
                      Text('Copy',
                          style: TextStyle(
                              fontSize: 10 * scale,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (iban != null) ...[
            SizedBox(height: 4 * scale),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'IBAN: $iban',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11 * scale,
                        color: Colors.white70),
                  ),
                ),
                GestureDetector(
                  onTap: () => _copyToClipboard(iban!, 'IBAN'),
                  child: Icon(Icons.copy_rounded,
                      size: 14 * scale, color: const Color(0xFFFFD54F)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// 2. WITHDRAWAL MODAL SHEET
class WithdrawModalSheet extends ConsumerStatefulWidget {
  const WithdrawModalSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const WithdrawModalSheet(),
    );
  }

  @override
  ConsumerState<WithdrawModalSheet> createState() => _WithdrawModalSheetState();
}

class _WithdrawModalSheetState extends ConsumerState<WithdrawModalSheet> {
  final TextEditingController _coinsController =
      TextEditingController(text: '10000');
  UserPaymentAccount? _selectedAccount;

  @override
  void initState() {
    super.initState();
    final accounts = ref.read(walletManagementProvider).paymentAccounts;
    if (accounts.isNotEmpty) {
      _selectedAccount = accounts.first;
    }
  }

  @override
  void dispose() {
    _coinsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale =
        (MediaQuery.sizeOf(context).width / AppConstants.designWidth).clamp(0.8, 1.25);
    final walletState = ref.watch(walletManagementProvider);
    final isPkr = walletState.currencyMode == CurrencyMode.pkr;
    final currencySymbol = walletState.currencySymbol;

    final parsedCoins = int.tryParse(_coinsController.text) ?? 0;
    final moneyValue = isPkr
        ? parsedCoins / WalletManagementState.coinsPerPkr
        : parsedCoins / WalletManagementState.coinsPerUsd;

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.88,
      decoration: BoxDecoration(
        color: const Color(0xFF160D42),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24 * scale)),
        border: Border.all(color: const Color(0xFF7A5EC7), width: 1.5),
        boxShadow: const [
          BoxShadow(
              color: Colors.black87, blurRadius: 24, offset: Offset(0, -6)),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 16 * scale, vertical: 14 * scale),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6 * scale),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E1C7E),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.payments_rounded,
                      color: const Color(0xFFFFB300), size: 20 * scale),
                ),
                SizedBox(width: 10 * scale),
                Text(
                  'WITHDRAW FUNDS',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                AppCloseButton(
                  size: 30 * scale,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF382375), height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Available Balance Box
                  Container(
                    padding: EdgeInsets.all(12 * scale),
                    decoration: BoxDecoration(
                      color: const Color(0xFF231358),
                      borderRadius: BorderRadius.circular(12 * scale),
                      border: Border.all(color: const Color(0xFF5A41A0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Available Balance:',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12 * scale,
                                color: Colors.white70)),
                        Row(
                          children: [
                            Image.asset('assets/graphics/icon_coins.png',
                                width: 18 * scale, height: 18 * scale),
                            SizedBox(width: 4 * scale),
                            Text(
                              '${walletState.coins} Coins',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13 * scale,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFFFD54F),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16 * scale),

                  // Step 1: Select Destination Account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '1. Payout Destination Account',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFD54F),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => ManagePaymentAccountSheet.show(context),
                        child: Text(
                          '+ Add Account',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF60A5FA),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8 * scale),

                  if (walletState.paymentAccounts.isEmpty) ...[
                    Container(
                      padding: EdgeInsets.all(14 * scale),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A1961),
                        borderRadius: BorderRadius.circular(12 * scale),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'No payment accounts added yet.',
                            style: TextStyle(
                                fontFamily: 'Poppins', color: Colors.white70),
                          ),
                          SizedBox(height: 6 * scale),
                          ElevatedButton.icon(
                            onPressed: () =>
                                ManagePaymentAccountSheet.show(context),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add JazzCash / EasyPaisa / Bank'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7A5EC7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    ...walletState.paymentAccounts.map((acc) {
                      final isSelected =
                          _selectedAccount?.id == acc.id;
                      return GestureDetector(
                        onTap: () {
                          SoundService().playButtonClick();
                          setState(() => _selectedAccount = acc);
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 8 * scale),
                          padding: EdgeInsets.all(12 * scale),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF381577)
                                : const Color(0xFF221355),
                            borderRadius: BorderRadius.circular(12 * scale),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFFD54F)
                                  : const Color(0xFF4A3188),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                acc.type == PaymentMethodType.jazzcash
                                    ? Icons.phone_android_rounded
                                    : acc.type == PaymentMethodType.easypaisa
                                        ? Icons.account_balance_wallet_rounded
                                        : Icons.account_balance_rounded,
                                color: isSelected
                                    ? const Color(0xFFFFD54F)
                                    : Colors.white70,
                                size: 22 * scale,
                              ),
                              SizedBox(width: 12 * scale),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      acc.accountTitle,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13 * scale,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '${acc.bankName != null ? "${acc.bankName} - " : ""}${acc.accountNumber}',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 11 * scale,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded,
                                    color: Color(0xFFFFD54F), size: 20),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                  SizedBox(height: 16 * scale),

                  // Step 2: Withdrawal Coins Input
                  Text(
                    '2. Coins to Withdraw',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFD54F),
                    ),
                  ),
                  SizedBox(height: 8 * scale),

                  TextField(
                    controller: _coinsController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(12 * scale),
                        child: Image.asset('assets/graphics/icon_coins.png',
                            width: 20 * scale, height: 20 * scale),
                      ),
                      suffixIcon: TextButton(
                        onPressed: () {
                          SoundService().playButtonClick();
                          setState(() {
                            _coinsController.text =
                                walletState.coins.toString();
                          });
                        },
                        child: const Text('MAX',
                            style: TextStyle(
                                color: Color(0xFFFFD54F),
                                fontWeight: FontWeight.bold)),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF221355),
                      hintText: 'Enter coins to withdraw',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12 * scale),
                        borderSide:
                            const BorderSide(color: Color(0xFF5A41A0)),
                      ),
                    ),
                  ),
                  SizedBox(height: 6 * scale),
                  Text(
                    'Min withdrawal: 10,000 Coins (Rs 100). Processing time: 2-6 Hours.',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10.5 * scale,
                        color: Colors.white54),
                  ),
                  SizedBox(height: 16 * scale),

                  // Payout Calculation Summary Box
                  Container(
                    padding: EdgeInsets.all(14 * scale),
                    decoration: BoxDecoration(
                      color: const Color(0xFF261463),
                      borderRadius: BorderRadius.circular(14 * scale),
                      border: Border.all(color: const Color(0xFF7A5EC7)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Coins Deducted:',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12 * scale,
                                    color: Colors.white70)),
                            Text('$parsedCoins Coins',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12 * scale,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ],
                        ),
                        SizedBox(height: 6 * scale),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Processing Fee:',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12 * scale,
                                    color: Colors.white70)),
                            Text('FREE (Rs 0)',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12 * scale,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF4ADE80))),
                          ],
                        ),
                        const Divider(color: Colors.white24, height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('You Receive:',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14 * scale,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            Text(
                              '$currencySymbol ${moneyValue.toStringAsFixed(1)}',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16 * scale,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFFFD54F),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24 * scale),

                  // Submit Withdrawal Button
                  SizedBox(
                    width: double.infinity,
                    height: 48 * scale,
                    child: ElevatedButton(
                      onPressed: (_selectedAccount == null ||
                              walletState.isSubmitting ||
                              parsedCoins < 10000 ||
                              parsedCoins > walletState.coins)
                          ? null
                          : () async {
                              SoundService().playButtonClick();
                              final success = await ref
                                  .read(walletManagementProvider.notifier)
                                  .submitWithdrawal(
                                    coinsToWithdraw: parsedCoins,
                                    destinationAccount: _selectedAccount!,
                                  );
                              if (success && mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Withdrawal request for $currencySymbol${moneyValue.toStringAsFixed(1)} submitted successfully!'),
                                    backgroundColor: const Color(0xFF22C55E),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14 * scale),
                        ),
                        elevation: 4,
                      ),
                      child: walletState.isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.black, strokeWidth: 2.5),
                            )
                          : Text(
                              'REQUEST WITHDRAWAL',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14 * scale,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 20 * scale),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 3. CONVERTER MODAL (Money <-> Coins)
class QuickConverterModalSheet extends ConsumerStatefulWidget {
  final bool initialMoneyToCoins;
  const QuickConverterModalSheet({super.key, this.initialMoneyToCoins = true});

  static Future<void> show(BuildContext context,
      {bool isMoneyToCoins = true}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          QuickConverterModalSheet(initialMoneyToCoins: isMoneyToCoins),
    );
  }

  @override
  ConsumerState<QuickConverterModalSheet> createState() =>
      _QuickConverterModalSheetState();
}

class _QuickConverterModalSheetState
    extends ConsumerState<QuickConverterModalSheet> {
  late bool _isMoneyToCoins;
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isMoneyToCoins = widget.initialMoneyToCoins;
    _inputController.text = _isMoneyToCoins ? '500' : '50000';
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale =
        (MediaQuery.sizeOf(context).width / AppConstants.designWidth).clamp(0.8, 1.25);
    final walletState = ref.watch(walletManagementProvider);
    final isPkr = walletState.currencyMode == CurrencyMode.pkr;
    final currencySymbol = walletState.currencySymbol;

    final parsedVal = double.tryParse(_inputController.text) ?? 0.0;

    int computedCoins = 0;
    double computedMoney = 0.0;

    if (_isMoneyToCoins) {
      computedCoins = isPkr
          ? (parsedVal * WalletManagementState.coinsPerPkr).round()
          : (parsedVal * WalletManagementState.coinsPerUsd).round();
    } else {
      computedMoney = isPkr
          ? parsedVal / WalletManagementState.coinsPerPkr
          : parsedVal / WalletManagementState.coinsPerUsd;
    }

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.72,
      decoration: BoxDecoration(
        color: const Color(0xFF160D42),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24 * scale)),
        border: Border.all(color: const Color(0xFF7A5EC7), width: 1.5),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 16 * scale, vertical: 14 * scale),
            child: Row(
              children: [
                Icon(Icons.currency_exchange_rounded,
                    color: const Color(0xFFFFD54F), size: 22 * scale),
                SizedBox(width: 10 * scale),
                Text(
                  _isMoneyToCoins
                      ? 'MONEY ➔ COINS CONVERTER'
                      : 'COINS ➔ MONEY CONVERTER',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                AppCloseButton(
                  size: 28 * scale,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF382375), height: 1),

          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16 * scale),
              child: Column(
                children: [
                  // Direction Switch Tab
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF231358),
                      borderRadius: BorderRadius.circular(14 * scale),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              SoundService().playButtonClick();
                              setState(() {
                                _isMoneyToCoins = true;
                                _inputController.text = '500';
                              });
                            },
                            child: Container(
                              padding:
                                  EdgeInsets.symmetric(vertical: 10 * scale),
                              decoration: BoxDecoration(
                                color: _isMoneyToCoins
                                    ? const Color(0xFF7A5EC7)
                                    : Colors.transparent,
                                borderRadius:
                                    BorderRadius.circular(12 * scale),
                              ),
                              child: Center(
                                child: Text(
                                  'Money to Coins',
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
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              SoundService().playButtonClick();
                              setState(() {
                                _isMoneyToCoins = false;
                                _inputController.text = '50000';
                              });
                            },
                            child: Container(
                              padding:
                                  EdgeInsets.symmetric(vertical: 10 * scale),
                              decoration: BoxDecoration(
                                color: !_isMoneyToCoins
                                    ? const Color(0xFF7A5EC7)
                                    : Colors.transparent,
                                borderRadius:
                                    BorderRadius.circular(12 * scale),
                              ),
                              child: Center(
                                child: Text(
                                  'Coins to Money',
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
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20 * scale),

                  // Input Box
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _isMoneyToCoins
                          ? 'Enter Cash Amount ($currencySymbol)'
                          : 'Enter Coins Amount',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFD54F)),
                    ),
                  ),
                  SizedBox(height: 8 * scale),

                  TextField(
                    controller: _inputController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixIcon: _isMoneyToCoins
                          ? Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14 * scale, vertical: 12 * scale),
                              child: Text(currencySymbol,
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 18 * scale,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFFFD54F))),
                            )
                          : Padding(
                              padding: EdgeInsets.all(12 * scale),
                              child: Image.asset(
                                  'assets/graphics/icon_coins.png',
                                  width: 20 * scale,
                                  height: 20 * scale),
                            ),
                      filled: true,
                      fillColor: const Color(0xFF221355),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12 * scale),
                        borderSide:
                            const BorderSide(color: Color(0xFF5A41A0)),
                      ),
                    ),
                  ),
                  SizedBox(height: 16 * scale),

                  // Conversion Result Arrow Indicator
                  Icon(Icons.arrow_downward_rounded,
                      color: const Color(0xFFFFD54F), size: 24 * scale),
                  SizedBox(height: 12 * scale),

                  // Result Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16 * scale),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E1C7E), Color(0xFF1E1055)],
                      ),
                      borderRadius: BorderRadius.circular(16 * scale),
                      border: Border.all(
                          color: const Color(0xFFFFD54F), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _isMoneyToCoins
                              ? 'YOU WILL RECEIVE'
                              : 'EQUIVALENT CASH VALUE',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11 * scale,
                              color: Colors.white70,
                              letterSpacing: 1),
                        ),
                        SizedBox(height: 6 * scale),
                        if (_isMoneyToCoins) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/graphics/icon_coins.png',
                                  width: 26 * scale, height: 26 * scale),
                              SizedBox(width: 8 * scale),
                              Text(
                                '+$computedCoins COINS',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 22 * scale,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFFFD54F),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Text(
                            '$currencySymbol ${computedMoney.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 22 * scale,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF4ADE80),
                            ),
                          ),
                        ],
                        SizedBox(height: 4 * scale),
                        Text(
                          isPkr
                              ? 'Exchange Rate: 100 Coins = Rs 1 PKR'
                              : 'Exchange Rate: 28,000 Coins = \$1 USD',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10.5 * scale,
                              color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Execute Convert Button
                  SizedBox(
                    width: double.infinity,
                    height: 48 * scale,
                    child: ElevatedButton(
                      onPressed: parsedVal <= 0
                          ? null
                          : () async {
                              SoundService().playButtonClick();
                              if (_isMoneyToCoins) {
                                await ref
                                    .read(walletManagementProvider.notifier)
                                    .convertMoneyToCoins(
                                      moneyAmount: parsedVal,
                                      currency: walletState.currencyMode,
                                    );
                              } else {
                                await ref
                                    .read(walletManagementProvider.notifier)
                                    .convertCoinsToMoney(
                                      coinsAmount: parsedVal.toInt(),
                                      currency: walletState.currencyMode,
                                    );
                              }
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(_isMoneyToCoins
                                        ? 'Converted! +$computedCoins Coins added to wallet'
                                        : 'Converted $parsedVal Coins into $currencySymbol${computedMoney.toStringAsFixed(1)} cash credit!'),
                                    backgroundColor: const Color(0xFF22C55E),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD54F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14 * scale),
                        ),
                      ),
                      child: Text(
                        _isMoneyToCoins
                            ? 'CONVERT & ADD COINS'
                            : 'CONVERT TO CASH CREDIT',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16 * scale),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 4. MANAGE PAYMENT ACCOUNTS MODAL SHEET
class ManagePaymentAccountSheet extends ConsumerStatefulWidget {
  final UserPaymentAccount? initialAccount;
  const ManagePaymentAccountSheet({super.key, this.initialAccount});

  static Future<void> show(BuildContext context,
      {UserPaymentAccount? account}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ManagePaymentAccountSheet(initialAccount: account),
    );
  }

  @override
  ConsumerState<ManagePaymentAccountSheet> createState() =>
      _ManagePaymentAccountSheetState();
}

class _ManagePaymentAccountSheetState
    extends ConsumerState<ManagePaymentAccountSheet> {
  late PaymentMethodType _type;
  late final TextEditingController _titleController;
  late final TextEditingController _numberController;
  late final TextEditingController _bankNameController;
  late final TextEditingController _ibanController;

  @override
  void initState() {
    super.initState();
    _type = widget.initialAccount?.type ?? PaymentMethodType.jazzcash;
    _titleController =
        TextEditingController(text: widget.initialAccount?.accountTitle ?? '');
    _numberController =
        TextEditingController(text: widget.initialAccount?.accountNumber ?? '');
    _bankNameController =
        TextEditingController(text: widget.initialAccount?.bankName ?? '');
    _ibanController =
        TextEditingController(text: widget.initialAccount?.iban ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _numberController.dispose();
    _bankNameController.dispose();
    _ibanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale =
        (MediaQuery.sizeOf(context).width / AppConstants.designWidth).clamp(0.8, 1.25);

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.82,
      decoration: BoxDecoration(
        color: const Color(0xFF160D42),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24 * scale)),
        border: Border.all(color: const Color(0xFF7A5EC7), width: 1.5),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 16 * scale, vertical: 14 * scale),
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet_rounded,
                    color: const Color(0xFFFFD54F), size: 22 * scale),
                SizedBox(width: 10 * scale),
                Text(
                  widget.initialAccount == null
                      ? 'ADD PAYMENT ACCOUNT'
                      : 'EDIT PAYMENT ACCOUNT',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                AppCloseButton(
                  size: 28 * scale,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF382375), height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Select Account Type
                  Text(
                    'Select Account Type:',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFD54F)),
                  ),
                  SizedBox(height: 8 * scale),
                  Row(
                    children: [
                      _buildTypeRadio(PaymentMethodType.jazzcash, 'JazzCash',
                          scale),
                      SizedBox(width: 8 * scale),
                      _buildTypeRadio(PaymentMethodType.easypaisa, 'EasyPaisa',
                          scale),
                      SizedBox(width: 8 * scale),
                      _buildTypeRadio(PaymentMethodType.bank, 'Bank', scale),
                    ],
                  ),
                  SizedBox(height: 16 * scale),

                  // Account Holder Name
                  Text(
                    'Account Holder Name:',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12 * scale,
                        color: Colors.white70),
                  ),
                  SizedBox(height: 6 * scale),
                  TextField(
                    controller: _titleController,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontSize: 14 * scale),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF221355),
                      hintText: 'e.g. Muhammad Ali',
                      hintStyle: const TextStyle(color: Colors.white38),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12 * scale),
                      ),
                    ),
                  ),
                  SizedBox(height: 14 * scale),

                  // Number
                  Text(
                    _type == PaymentMethodType.bank
                        ? 'Bank Account Number:'
                        : 'Mobile Account Number:',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12 * scale,
                        color: Colors.white70),
                  ),
                  SizedBox(height: 6 * scale),
                  TextField(
                    controller: _numberController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontSize: 14 * scale),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF221355),
                      hintText: _type == PaymentMethodType.bank
                          ? 'e.g. 01020304050601'
                          : 'e.g. 0300-1234567',
                      hintStyle: const TextStyle(color: Colors.white38),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12 * scale),
                      ),
                    ),
                  ),
                  SizedBox(height: 14 * scale),

                  if (_type == PaymentMethodType.bank) ...[
                    Text(
                      'Bank Name:',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12 * scale,
                          color: Colors.white70),
                    ),
                    SizedBox(height: 6 * scale),
                    TextField(
                      controller: _bankNameController,
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontSize: 14 * scale),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF221355),
                        hintText: 'e.g. Meezan Bank / HBL / Allied',
                        hintStyle: const TextStyle(color: Colors.white38),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 * scale),
                        ),
                      ),
                    ),
                    SizedBox(height: 14 * scale),

                    Text(
                      'IBAN (Optional):',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12 * scale,
                          color: Colors.white70),
                    ),
                    SizedBox(height: 6 * scale),
                    TextField(
                      controller: _ibanController,
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontSize: 14 * scale),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF221355),
                        hintText: 'PKXX MEZN ...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 * scale),
                        ),
                      ),
                    ),
                    SizedBox(height: 14 * scale),
                  ],

                  SizedBox(height: 16 * scale),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 48 * scale,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_titleController.text.trim().isEmpty ||
                            _numberController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please fill all required fields')),
                          );
                          return;
                        }

                        SoundService().playButtonClick();
                        final account = UserPaymentAccount(
                          id: widget.initialAccount?.id ??
                              'acc_${DateTime.now().millisecondsSinceEpoch}',
                          type: _type,
                          accountTitle: _titleController.text.trim(),
                          accountNumber: _numberController.text.trim(),
                          bankName: _type == PaymentMethodType.bank
                              ? _bankNameController.text.trim()
                              : null,
                          iban: _type == PaymentMethodType.bank
                              ? _ibanController.text.trim()
                              : null,
                        );

                        ref
                            .read(walletManagementProvider.notifier)
                            .savePaymentAccount(account);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4ADE80),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14 * scale),
                        ),
                      ),
                      child: Text(
                        'SAVE ACCOUNT DETAILS',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeRadio(
      PaymentMethodType type, String label, double scale) {
    final isSelected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          SoundService().playButtonClick();
          setState(() => _type = type);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8 * scale),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF7A5EC7) : const Color(0xFF221355),
            borderRadius: BorderRadius.circular(10 * scale),
            border: Border.all(
              color: isSelected ? const Color(0xFFFFD54F) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
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
    );
  }
}
