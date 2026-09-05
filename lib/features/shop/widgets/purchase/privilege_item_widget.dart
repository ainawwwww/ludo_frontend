import 'package:flutter/material.dart';
import 'package:ludo_vibe/features/shop/models/purchase_models.dart';

class PrivilegeItemWidget extends StatelessWidget {
  const PrivilegeItemWidget({
    super.key,
    required this.item,
    this.scale = 1.0,
  });

  final PrivilegeItem item;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 3D Privilege Icon with circular base pedestal
        Stack(
          alignment: Alignment.center,
          children: [
            // Circular base glow / podium
            Container(
              width: 38 * scale,
              height: 38 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF221155).withOpacity(0.85),
                border: Border.all(
                  color: const Color(0xFF533B9E).withOpacity(0.6),
                  width: 1.0 * scale,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6D28D9).withOpacity(0.3),
                    blurRadius: 6 * scale,
                    offset: Offset(0, 2 * scale),
                  ),
                ],
              ),
            ),

            // Base shadow under icon
            Positioned(
              bottom: 2 * scale,
              child: Container(
                width: 26 * scale,
                height: 8 * scale,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                      Radius.elliptical(26 * scale, 8 * scale)),
                  color: Colors.black.withOpacity(0.4),
                ),
              ),
            ),

            // Privilege Icon
            Image.asset(
              item.iconAsset,
              height: 36 * scale,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.star_rounded,
                size: 30 * scale,
                color: const Color(0xFFFFD369),
              ),
            ),
          ],
        ),

        SizedBox(height: 4 * scale),

        // Text label
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4 * scale),
          child: Text(
            item.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 8.5 * scale,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFD4C8FF),
              height: 1.15,
            ),
          ),
        ),
      ],
    );
  }
}
