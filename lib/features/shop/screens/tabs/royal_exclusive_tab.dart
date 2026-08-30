import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/features/shop/providers/shop_provider.dart';
import 'package:ludo_vibe/features/shop/widgets/royal_item_card.dart';

class RoyalExclusiveTab extends ConsumerWidget {
  const RoyalExclusiveTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final scale = (size.width / AppConstants.designWidth).clamp(0.75, 1.25);
    final shopState = ref.watch(shopProvider);
    final royalItems = shopState.royalExclusives;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4 * scale),
      child: Column(
        children: [
          // Royal VIP Header Banner
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: 10 * scale, vertical: 8 * scale),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5E17EB), Color(0xFF280B52)],
              ),
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(
                color: const Color(0xFFFFD369),
                width: 1.2 * scale,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x44FFD369),
                  blurRadius: 6 * scale,
                  offset: Offset(0, 2 * scale),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6 * scale),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/graphics/shop/badges_selection_indicators/Crown.png',
                    width: 18 * scale,
                    height: 18 * scale,
                  ),
                ),
                SizedBox(width: 8 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Exclusive Royal Privileges',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11.5 * scale,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFD369),
                        ),
                      ),
                      Text(
                        'Vehicles & Supreme Avatar effects for VIP Lords.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9.5 * scale,
                          color: const Color(0xFFE2C4FF),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8 * scale),

          // 2-Column Grid with AlwaysScrollableScrollPhysics
          Expanded(
            child: GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8 * scale,
                mainAxisSpacing: 8 * scale,
                childAspectRatio: 0.80,
              ),
              itemCount: royalItems.length,
              itemBuilder: (context, index) {
                return RoyalItemCard(item: royalItems[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
