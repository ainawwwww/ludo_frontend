import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/features/shop/models/shop_item_model.dart';
import 'package:ludo_vibe/features/shop/providers/shop_provider.dart';
import 'package:ludo_vibe/features/shop/widgets/item_preview_dialog.dart';

class ThemeWallpaperCard extends ConsumerWidget {
  final ShopItem item;
  final VoidCallback? onTap;

  const ThemeWallpaperCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final scale = (size.width / AppConstants.designWidth).clamp(0.75, 1.25);
    final isRoyal = item.themeType == ThemeType.royal;

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
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(
            color: item.isEquipped
                ? const Color(0xFF56AB2F)
                : isRoyal
                    ? const Color(0xFFFFD369)
                    : const Color(0xFF764BC0).withOpacity(0.5),
            width: isRoyal || item.isEquipped ? 1.5 * scale : 1 * scale,
          ),
          boxShadow: [
            BoxShadow(
              color: isRoyal
                  ? const Color(0x55FFD369)
                  : item.isEquipped
                      ? const Color(0x5556AB2F)
                      : Colors.black.withOpacity(0.3),
              blurRadius: 6 * scale,
              offset: Offset(0, 3 * scale),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11 * scale),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Wallpaper Image
              Image.asset(
                item.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF2B124C),
                  child: Center(
                    child: Icon(
                      Icons.wallpaper_rounded,
                      color: Colors.white38,
                      size: 28 * scale,
                    ),
                  ),
                ),
              ),

              // Bottom gradient
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 44 * scale,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Color(0xD90C0524),
                        Color(0xF508021A),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // Bottom Title & Status
              Positioned(
                bottom: 6 * scale,
                left: 6 * scale,
                right: 6 * scale,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10 * scale,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 4 * scale),
                    _buildPill(scale),
                  ],
                ),
              ),

              // Top-Left Crown
              if (isRoyal)
                Positioned(
                  top: 5 * scale,
                  left: 5 * scale,
                  child: Image.asset(
                    'assets/graphics/shop/badges_selection_indicators/Crown.png',
                    width: 15 * scale,
                    height: 15 * scale,
                    fit: BoxFit.contain,
                  ),
                ),

              // Top-Right Checkmark
              if (item.isEquipped)
                Positioned(
                  top: 5 * scale,
                  right: 5 * scale,
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
      ),
    );
  }

  Widget _buildPill(double scale) {
    if (item.isEquipped) {
      return Container(
        padding:
            EdgeInsets.symmetric(horizontal: 5 * scale, vertical: 1.5 * scale),
        decoration: BoxDecoration(
          color: const Color(0xFF56AB2F),
          borderRadius: BorderRadius.circular(6 * scale),
        ),
        child: Text(
          'IN USE',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 8 * scale,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    if (item.isOwned) {
      return Container(
        padding:
            EdgeInsets.symmetric(horizontal: 5 * scale, vertical: 1.5 * scale),
        decoration: BoxDecoration(
          color: const Color(0xFF6B2FD7),
          borderRadius: BorderRadius.circular(6 * scale),
        ),
        child: Text(
          'EQUIP',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 8 * scale,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 4 * scale, vertical: 1.5 * scale),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(6 * scale),
        border: Border.all(
          color: item.currencyType == CurrencyType.diamonds
              ? const Color(0xFF00E5FF)
              : const Color(0xFFFFD369),
          width: 0.6 * scale,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
              fontSize: 8.5 * scale,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
