import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/features/shop/models/shop_item_model.dart';
import 'package:ludo_vibe/features/shop/providers/shop_provider.dart';
import 'package:ludo_vibe/features/shop/widgets/item_preview_dialog.dart';

class RoyalItemCard extends ConsumerWidget {
  final ShopItem item;
  final VoidCallback? onTap;

  const RoyalItemCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final scale = (size.width / AppConstants.designWidth).clamp(0.75, 1.25);

    return GestureDetector(
      onTap: () {
        SoundService().playButtonClick();
        if (onTap != null) {
          onTap!();
        } else {
          showItemPreviewDialog(context, item);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF43167A),
              Color(0xFF280B52),
              Color(0xFF1B0538),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14 * scale),
          border: Border.all(
            color: item.isEquipped
                ? const Color(0xFF56AB2F)
                : const Color(0xFFFFD369),
            width: 1.5 * scale,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x44FFD369),
              blurRadius: 6 * scale,
              offset: Offset(0, 3 * scale),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main card content
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8 * scale,
                vertical: 6 * scale,
              ),
              child: Column(
                children: [
                  // VIP Ribbon
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6 * scale,
                      vertical: 2 * scale,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD369), Color(0xFFFFA000)],
                      ),
                      borderRadius: BorderRadius.circular(6 * scale),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/graphics/shop/badges_selection_indicators/Crown.png',
                          width: 10 * scale,
                          height: 10 * scale,
                        ),
                        SizedBox(width: 3 * scale),
                        Text(
                          'ROYAL VIP',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 8 * scale,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1B0538),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4 * scale),

                  // Graphic Stage
                  Expanded(
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 48 * scale,
                            height: 48 * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  (item.glowColor ?? const Color(0xFFFFD369))
                                      .withOpacity(0.32),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          Image.asset(
                            item.imageAsset,
                            height: 38 * scale,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.auto_awesome_rounded,
                              color: const Color(0xFFFFD369),
                              size: 26 * scale,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 4 * scale),

                  // Real Item Name in Poppins
                  Text(
                    item.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10.5 * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4 * scale),

                  // Bottom Action Button
                  _buildBottomButton(context, ref, scale),
                ],
              ),
            ),

            // Top-Right: Equipped Checkmark
            if (item.isEquipped)
              Positioned(
                top: 5 * scale,
                right: 5 * scale,
                child: SizedBox(
                  width: 20 * scale,
                  height: 20 * scale,
                  child: Image.asset(
                    'assets/graphics/shop/badges_selection_indicators/Group 1261153273.png',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, WidgetRef ref, double scale) {
    if (item.isEquipped) {
      return Container(
        width: double.infinity,
        height: 22 * scale,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF56AB2F).withOpacity(0.22),
          borderRadius: BorderRadius.circular(8 * scale),
          border: Border.all(
            color: const Color(0xFF56AB2F),
            width: 0.8 * scale,
          ),
        ),
        child: Text(
          'EQUIPPED',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 8.5 * scale,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF76D94A),
          ),
        ),
      );
    }

    if (item.isOwned) {
      return GestureDetector(
        onTap: () {
          SoundService().playButtonClick();
          ref.read(shopProvider.notifier).equipItem(item);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item.name} equipped as royal vehicle!'),
              backgroundColor: const Color(0xFF56AB2F),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          height: 22 * scale,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD369), Color(0xFFFFA000)],
            ),
            borderRadius: BorderRadius.circular(8 * scale),
          ),
          child: Text(
            'EQUIP',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 9 * scale,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1B0538),
            ),
          ),
        ),
      );
    }

    // Price Capsule
    return Container(
      width: double.infinity,
      height: 22 * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF0C021E).withOpacity(0.75),
        borderRadius: BorderRadius.circular(8 * scale),
        border: Border.all(
          color: const Color(0xFFFFD369).withOpacity(0.6),
          width: 0.8 * scale,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/graphics/icon_diamond.png',
            width: 11 * scale,
            height: 11 * scale,
          ),
          SizedBox(width: 3 * scale),
          Text(
            '${item.price}',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 9.5 * scale,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFD369),
            ),
          ),
        ],
      ),
    );
  }
}
