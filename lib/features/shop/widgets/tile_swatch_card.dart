import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/features/shop/models/shop_item_model.dart';
import 'package:ludo_vibe/features/shop/providers/shop_provider.dart';
import 'package:ludo_vibe/features/shop/widgets/item_preview_dialog.dart';

class TileSwatchCard extends ConsumerWidget {
  final ShopItem item;
  final VoidCallback? onTap;

  const TileSwatchCard({
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
          color: const Color(0xFF231049),
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(
            color: item.isEquipped
                ? const Color(0xFF56AB2F)
                : const Color(0xFF764BC0).withOpacity(0.5),
            width: item.isEquipped ? 1.8 * scale : 1 * scale,
          ),
          boxShadow: [
            BoxShadow(
              color: item.isEquipped
                  ? const Color(0x5556AB2F)
                  : Colors.black.withOpacity(0.25),
              blurRadius: 4 * scale,
              offset: Offset(0, 2 * scale),
            ),
          ],
        ),
        child: Column(
          children: [
            // Swatch Texture
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(11 * scale),
                      ),
                      child: Image.asset(
                        item.imageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF381577),
                          child: Center(
                            child: Icon(
                              Icons.grid_on_rounded,
                              color: Colors.white30,
                              size: 24 * scale,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Equipped Badge
                  if (item.isEquipped)
                    Positioned(
                      top: 4 * scale,
                      right: 4 * scale,
                      child: SizedBox(
                        width: 18 * scale,
                        height: 18 * scale,
                        child: Image.asset(
                          'assets/graphics/shop/badges_selection_indicators/Group 1261153273.png',
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Info Bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 4 * scale,
                vertical: 4 * scale,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9.5 * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2 * scale),
                  _buildStatusPill(scale),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(double scale) {
    if (item.isEquipped) {
      return Text(
        'IN USE',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 8.5 * scale,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF76D94A),
        ),
      );
    }

    if (item.isOwned) {
      return Text(
        'OWNED',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 8.5 * scale,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFCCA3FF),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (item.currencyType.iconAsset.isNotEmpty) ...[
          Image.asset(
            item.currencyType.iconAsset,
            width: 10 * scale,
            height: 10 * scale,
          ),
          SizedBox(width: 2 * scale),
        ],
        Text(
          item.price == 0 ? 'FREE' : '${item.price}',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 9 * scale,
            fontWeight: FontWeight.bold,
            color: item.currencyType == CurrencyType.diamonds
                ? const Color(0xFF00E5FF)
                : const Color(0xFFFFD369),
          ),
        ),
      ],
    );
  }
}
