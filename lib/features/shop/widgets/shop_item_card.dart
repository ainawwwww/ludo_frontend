import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/features/shop/models/shop_item_model.dart';
import 'package:ludo_vibe/features/shop/providers/shop_provider.dart';
import 'package:ludo_vibe/features/shop/widgets/item_preview_dialog.dart';

class ShopItemCard extends ConsumerWidget {
  final ShopItem item;
  final VoidCallback? onTap;

  const ShopItemCard({
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
              Color(0xFF351870),
              Color(0xFF1E0A44),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(14 * scale),
          border: Border.all(
            color: item.isEquipped
                ? const Color(0xFF56AB2F)
                : item.isRoyalOnly
                    ? const Color(0xFFFFD369)
                    : const Color(0xFF764BC0).withOpacity(0.55),
            width: item.isEquipped ? 1.8 * scale : 1 * scale,
          ),
          boxShadow: [
            BoxShadow(
              color: item.isEquipped
                  ? const Color(0x5556AB2F)
                  : item.glowColor != null
                      ? item.glowColor!.withOpacity(0.18)
                      : Colors.black.withOpacity(0.3),
              blurRadius: item.isEquipped ? 8 * scale : 4 * scale,
              offset: Offset(0, 3 * scale),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Internal Content
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8 * scale,
                vertical: 6 * scale,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Item Artwork Stage
                  Expanded(
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Soft glow circle
                          Container(
                            width: 44 * scale,
                            height: 44 * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  (item.glowColor ?? const Color(0xFF9E6BFF))
                                      .withOpacity(0.28),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          // Item artwork
                          Image.asset(
                            item.imageAsset,
                            height: 38 * scale,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.casino_rounded,
                              color: Colors.white54,
                              size: 26 * scale,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 4 * scale),

                  // Real Text Title in Poppins Font
                  Text(
                    item.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11 * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4 * scale),

                  // Bottom Action / Price Pill
                  _buildBottomPill(context, ref, scale),
                ],
              ),
            ),

            // Top-Right: Equipped Green Checkmark Badge
            if (item.isEquipped)
              Positioned(
                top: 5 * scale,
                right: 5 * scale,
                child: SizedBox(
                  width: 20 * scale,
                  height: 20 * scale,
                  child: Image.asset(
                    'assets/graphics/shop/badges_selection_indicators/Group 1261153273.png',
                    errorBuilder: (_, __, ___) => Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF56AB2F),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 13 * scale,
                      ),
                    ),
                  ),
                ),
              ),

            // Top-Left: Crown badge for Royal items
            if (item.isRoyalOnly)
              Positioned(
                top: 5 * scale,
                left: 5 * scale,
                child: Image.asset(
                  'assets/graphics/shop/badges_selection_indicators/Crown.png',
                  width: 16 * scale,
                  height: 16 * scale,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.star_rounded,
                    color: const Color(0xFFFFD369),
                    size: 14 * scale,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPill(BuildContext context, WidgetRef ref, double scale) {
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
            fontSize: 9 * scale,
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
              content: Text('${item.name} equipped!'),
              backgroundColor: const Color(0xFF56AB2F),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          height: 22 * scale,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6B2FD7), Color(0xFF43169E)],
            ),
            borderRadius: BorderRadius.circular(8 * scale),
            border: Border.all(
              color: const Color(0xFF9E6BFF),
              width: 0.8 * scale,
            ),
          ),
          child: Text(
            'EQUIP',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 9.5 * scale,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    // Unowned: Price pill
    return Container(
      width: double.infinity,
      height: 22 * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF110729).withOpacity(0.85),
        borderRadius: BorderRadius.circular(8 * scale),
        border: Border.all(
          color: const Color(0xFF836DDF).withOpacity(0.35),
          width: 0.8 * scale,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (item.currencyType.iconAsset.isNotEmpty) ...[
            Image.asset(
              item.currencyType.iconAsset,
              width: 12 * scale,
              height: 12 * scale,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 3 * scale),
          ],
          Text(
            item.price == 0 ? 'FREE' : '${item.price}',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10 * scale,
              fontWeight: FontWeight.bold,
              color: item.currencyType == CurrencyType.diamonds
                  ? const Color(0xFF00E5FF)
                  : const Color(0xFFFFD369),
            ),
          ),
        ],
      ),
    );
  }
}
