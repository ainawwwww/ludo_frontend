import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';
import 'package:ludo_vibe/features/shop/models/shop_item_model.dart';
import 'package:ludo_vibe/features/shop/providers/shop_provider.dart';

void showItemPreviewDialog(BuildContext context, ShopItem item) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => ItemPreviewDialog(item: item),
  );
}

class ItemPreviewDialog extends ConsumerWidget {
  final ShopItem item;

  const ItemPreviewDialog({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final scale = (size.width / AppConstants.designWidth).clamp(0.8, 1.3);

    // Watch current state to reflect real-time changes
    final shopState = ref.watch(shopProvider);
    final currentItem = shopState.items.firstWhere(
      (i) => i.id == item.id,
      orElse: () => item,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24 * scale),
      child: Container(
        padding: EdgeInsets.all(18 * scale),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF381577),
              Color(0xFF200A49),
              Color(0xFF13042E),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(24 * scale),
          border: Border.all(
            color: currentItem.isRoyalOnly
                ? const Color(0xFFFFD369)
                : const Color(0xFF9E6BFF),
            width: 2 * scale,
          ),
          boxShadow: [
            BoxShadow(
              color: currentItem.isRoyalOnly
                  ? const Color(0x66FFD369)
                  : const Color(0x666B2FD7),
              blurRadius: 20 * scale,
              offset: Offset(0, 8 * scale),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Header with Category Badge & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10 * scale,
                    vertical: 4 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B2FD7).withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12 * scale),
                    border: Border.all(
                      color: const Color(0xFFCCA3FF),
                      width: 1 * scale,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        currentItem.category.icon,
                        color: const Color(0xFFCCA3FF),
                        size: 14 * scale,
                      ),
                      SizedBox(width: 4 * scale),
                      Text(
                        currentItem.category.label.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10 * scale,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    SoundService().playButtonClick();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.all(6 * scale),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 18 * scale,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14 * scale),

            // Main Preview Stage with Glow
            Container(
              width: double.infinity,
              height: 160 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFF0C0320).withOpacity(0.5),
                borderRadius: BorderRadius.circular(18 * scale),
                border: Border.all(
                  color: const Color(0xFF5641F8).withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow radial
                    Container(
                      width: 120 * scale,
                      height: 120 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            (currentItem.glowColor ?? const Color(0xFF9E6BFF))
                                .withOpacity(0.45),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Image.asset(
                      currentItem.imageAsset,
                      height: 125 * scale,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.image_outlined,
                        color: Colors.white30,
                        size: 60 * scale,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 14 * scale),

            // Item Name
            Text(
              currentItem.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 6 * scale),

            // Description
            if (currentItem.description.isNotEmpty)
              Text(
                currentItem.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12 * scale,
                  color: const Color(0xFFD4C1FF),
                  height: 1.3,
                ),
              ),
            SizedBox(height: 18 * scale),

            // Action Buttons
            _buildActionButtons(context, ref, currentItem, scale),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, WidgetRef ref, ShopItem currentItem, double scale) {
    if (currentItem.isEquipped) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12 * scale),
        decoration: BoxDecoration(
          color: const Color(0xFF56AB2F).withOpacity(0.2),
          borderRadius: BorderRadius.circular(14 * scale),
          border:
              Border.all(color: const Color(0xFF56AB2F), width: 1.5 * scale),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded,
                color: const Color(0xFF76D94A), size: 20 * scale),
            SizedBox(width: 6 * scale),
            Text(
              'CURRENTLY EQUIPPED',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13 * scale,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF76D94A),
              ),
            ),
          ],
        ),
      );
    }

    if (currentItem.isOwned) {
      return GestureDetector(
        onTap: () {
          SoundService().playButtonClick();
          ref.read(shopProvider.notifier).equipItem(currentItem);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${currentItem.name} equipped successfully!'),
              backgroundColor: const Color(0xFF56AB2F),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12 * scale),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6B2FD7), Color(0xFF43169E)],
            ),
            borderRadius: BorderRadius.circular(14 * scale),
            border: Border.all(
              color: const Color(0xFFB173FF),
              width: 1.5 * scale,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0x666B2FD7),
                blurRadius: 8 * scale,
                offset: Offset(0, 4 * scale),
              ),
            ],
          ),
          child: Text(
            'EQUIP NOW',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14 * scale,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
    }

    // Buy Action
    return GestureDetector(
      onTap: () {
        SoundService().playButtonClick();
        final success = ref.read(shopProvider.notifier).buyItem(currentItem);
        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Successfully purchased and equipped ${currentItem.name}!'),
              backgroundColor: const Color(0xFF56AB2F),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Not enough ${currentItem.currencyType.label}! Please top up.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12 * scale),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF9B63), Color(0xFFF97023)],
          ),
          borderRadius: BorderRadius.circular(14 * scale),
          border: Border.all(
            color: const Color(0xFFFF833D),
            width: 1.5 * scale,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x66F97023),
              blurRadius: 8 * scale,
              offset: Offset(0, 4 * scale),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (currentItem.currencyType.iconAsset.isNotEmpty) ...[
              Image.asset(
                currentItem.currencyType.iconAsset,
                width: 20 * scale,
                height: 20 * scale,
              ),
              SizedBox(width: 8 * scale),
            ],
            Text(
              currentItem.price == 0
                  ? 'UNLOCK FOR FREE'
                  : 'BUY FOR ${currentItem.price} ${currentItem.currencyType.label.toUpperCase()}',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
