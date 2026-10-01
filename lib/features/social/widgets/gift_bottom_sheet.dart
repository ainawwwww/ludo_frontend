import 'package:flutter/material.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/features/social/models/gift_model.dart';

class GiftBottomSheet extends StatefulWidget {
  final List<String> recipients;
  final String selectedRecipient;
  final Function(GiftModel gift, String recipient) onSendGift;

  const GiftBottomSheet({
    super.key,
    required this.recipients,
    required this.selectedRecipient,
    required this.onSendGift,
  });

  static void show(
    BuildContext context, {
    required List<String> recipients,
    required String initialRecipient,
    required Function(GiftModel gift, String recipient) onSendGift,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GiftBottomSheet(
        recipients: recipients,
        selectedRecipient: initialRecipient,
        onSendGift: onSendGift,
      ),
    );
  }

  @override
  State<GiftBottomSheet> createState() => _GiftBottomSheetState();
}

class _GiftBottomSheetState extends State<GiftBottomSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  GiftModel? _selectedGift;
  late String _activeRecipient;
  final int _userCoins = 28500;

  final List<String> _tabs = ['All', 'Popular', 'Luxury', 'Special'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _activeRecipient = widget.selectedRecipient;
    _selectedGift = GiftModel.defaultGifts.first;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<GiftModel> _getFilteredGifts(int tabIndex) {
    if (tabIndex == 0) return GiftModel.defaultGifts;
    final cat = _tabs[tabIndex].toLowerCase();
    return GiftModel.defaultGifts.where((g) => g.category == cat).toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / AppConstants.designWidth;

    return Container(
      height: 480 * scale,
      decoration: BoxDecoration(
        color: const Color(0xFF140B44),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24 * scale)),
        border: Border(
          top: BorderSide(color: const Color(0xFF8E2DE2).withOpacity(0.6), width: 1.5 * scale),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 20 * scale,
            offset: Offset(0, -5 * scale),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 8 * scale, bottom: 6 * scale),
                width: 36 * scale,
                height: 4 * scale,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2 * scale),
                ),
              ),
            ),

            // Top Bar: Recipient Selector & Tabs
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * scale),
              child: Row(
                children: [
                  // Send to selector
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
                    decoration: BoxDecoration(
                      color: const Color(0xFF23166D),
                      borderRadius: BorderRadius.circular(16 * scale),
                      border: Border.all(color: const Color(0xFFFFD200).withOpacity(0.5), width: 1 * scale),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'To: ',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11 * scale,
                            color: Colors.white70,
                          ),
                        ),
                        DropdownButton<String>(
                          value: widget.recipients.contains(_activeRecipient)
                              ? _activeRecipient
                              : widget.recipients.first,
                          dropdownColor: const Color(0xFF1E135A),
                          underline: const SizedBox.shrink(),
                          icon: Icon(Icons.arrow_drop_down, color: const Color(0xFFFFD200), size: 18 * scale),
                          isDense: true,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11.5 * scale,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFD200),
                          ),
                          onChanged: (val) {
                            if (val != null) setState(() => _activeRecipient = val);
                          },
                          items: widget.recipients.map((r) {
                            return DropdownMenuItem<String>(
                              value: r,
                              child: Text(r),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8 * scale),

                  // Category Tabs (Expanded to prevent overflow)
                  Expanded(
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelColor: const Color(0xFFFFD200),
                      unselectedLabelColor: Colors.white60,
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(color: const Color(0xFFFFD200), width: 2.5 * scale),
                        insets: EdgeInsets.symmetric(horizontal: 4 * scale),
                      ),
                      indicatorSize: TabBarIndicatorSize.label,
                      labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 12 * scale, fontWeight: FontWeight.bold),
                      unselectedLabelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 12 * scale),
                      dividerColor: Colors.transparent,
                      tabs: _tabs.map((t) => Tab(text: t)).toList(),
                      onTap: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 6 * scale),

            // Gifts Grid View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _tabs.asMap().entries.map((entry) {
                  final gifts = _getFilteredGifts(entry.key);
                  return GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 8 * scale),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10 * scale,
                      mainAxisSpacing: 10 * scale,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: gifts.length,
                    itemBuilder: (context, index) {
                      final gift = gifts[index];
                      final isSelected = _selectedGift?.id == gift.id;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedGift = gift;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF3B1E87).withOpacity(0.8)
                                : const Color(0xFF1B1052).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12 * scale),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFFFD200) : const Color(0xFF4C3EC8).withOpacity(0.3),
                              width: isSelected ? 2 * scale : 1 * scale,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFFFD200).withOpacity(0.35),
                                      blurRadius: 8 * scale,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Gift Image
                              SizedBox(
                                width: 44 * scale,
                                height: 44 * scale,
                                child: Image.asset(
                                  gift.assetPath,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.card_giftcard,
                                    color: Color(0xFFFFD200),
                                  ),
                                ),
                              ),
                              SizedBox(height: 4 * scale),
                              // Name
                              Text(
                                gift.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10 * scale,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 2 * scale),
                              // Coins Cost
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/graphics/icon_coins.png',
                                    width: 12 * scale,
                                    height: 12 * scale,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.monetization_on,
                                      size: 11 * scale,
                                      color: const Color(0xFFFFD200),
                                    ),
                                  ),
                                  SizedBox(width: 3 * scale),
                                  Text(
                                    gift.cost.toString(),
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 10 * scale,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFFFD200),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),

            // Bottom bar: Coins balance & Send Button
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 10 * scale),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0734),
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.08)),
                ),
              ),
              child: Row(
                children: [
                  // Coins Balance
                  Row(
                    children: [
                      Image.asset(
                        'assets/graphics/icon_coins.png',
                        width: 22 * scale,
                        height: 22 * scale,
                        errorBuilder: (_, __, ___) => const Icon(Icons.monetization_on, color: Color(0xFFFFD200)),
                      ),
                      SizedBox(width: 6 * scale),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Balance',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 9.5 * scale,
                              color: Colors.white54,
                            ),
                          ),
                          Text(
                            _userCoins.toString(),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13 * scale,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Send Gift Button
                  Container(
                    width: 130 * scale,
                    height: 40 * scale,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20 * scale),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9000), Color(0xFFF05A00)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.4),
                          blurRadius: 8 * scale,
                          offset: Offset(0, 3 * scale),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (_selectedGift != null) {
                            Navigator.pop(context);
                            widget.onSendGift(_selectedGift!, _activeRecipient);
                          }
                        },
                        borderRadius: BorderRadius.circular(20 * scale),
                        child: Center(
                          child: Text(
                            'Send Gift',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13 * scale,
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
          ],
        ),
      ),
    );
  }
}
