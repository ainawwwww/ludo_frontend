import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/features/shop/models/shop_item_model.dart';
import 'package:ludo_vibe/features/shop/providers/shop_provider.dart';
import 'package:ludo_vibe/features/shop/widgets/item_preview_dialog.dart';

class StickerPackCard extends ConsumerWidget {
  final ShopItem item;
  final VoidCallback? onTap;

  const StickerPackCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final scale = (size.width / AppConstants.designWidth).clamp(0.75, 1.25);
    final isPack = item.stickerType == StickerType.pack;

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
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(
            color: item.isEquipped
                ? const Color(0xFF56AB2F)
                : const Color(0xFF9662EA).withOpacity(0.45),
            width: item.isEquipped ? 1.5 * scale : 1 * scale,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4 * scale,
              offset: Offset(0, 2 * scale),
            ),
          ],
        ),
        child: Column(
          children: [
            // Preview Artwork
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(6 * scale),
                child: isPack && (item.previewAssets?.isNotEmpty ?? false)
                    ? _buildPackStickersGrid(scale)
                    : Center(
                        child: Image.asset(
                          item.imageAsset,
                          height: 42 * scale,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.sticky_note_2_rounded,
                            color: Colors.white54,
                            size: 28 * scale,
                          ),
                        ),
                      ),
              ),
            ),

            // Item Name
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4 * scale),
              child: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 4 * scale),

            // Buy / Owned Button at Bottom
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 6 * scale,
                vertical: 4 * scale,
              ),
              child: _buildActionButton(context, ref, scale),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackStickersGrid(double scale) {
    final previews = item.previewAssets ?? [];
    return Container(
      padding: EdgeInsets.all(3 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF13072D).withOpacity(0.6),
        borderRadius: BorderRadius.circular(8 * scale),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: previews.take(4).length,
        itemBuilder: (context, idx) {
          return Image.asset(
            previews[idx],
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.emoji_emotions_rounded,
              color: Colors.white30,
              size: 16,
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, WidgetRef ref, double scale) {
    if (item.isOwned) {
      return Container(
        width: double.infinity,
        height: 22 * scale,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF56AB2F).withOpacity(0.2),
          borderRadius: BorderRadius.circular(6 * scale),
          border:
              Border.all(color: const Color(0xFF56AB2F), width: 0.8 * scale),
        ),
        child: Text(
          'UNLOCKED',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 8.5 * scale,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF76D94A),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        SoundService().playButtonClick();
        final success = ref.read(shopProvider.notifier).buyItem(item);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unlocked ${item.name}!'),
              backgroundColor: const Color(0xFF56AB2F),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Not enough ${item.currencyType.label}!'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        height: 22 * scale,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF9B63), Color(0xFFF97023)],
          ),
          borderRadius: BorderRadius.circular(6 * scale),
        ),
        child: Row(
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
              '${item.price}',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 9.5 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
