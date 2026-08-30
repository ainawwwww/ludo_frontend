import 'package:flutter/material.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';

class TierToggleButton extends StatelessWidget {
  const TierToggleButton({
    super.key,
    required this.selectedTierIndex,
    required this.onTierChanged,
    this.scale = 1.0,
  });

  final int selectedTierIndex; // 0 = Knight, 1 = Baron
  final ValueChanged<int> onTierChanged;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 4 * scale),
      height: 38 * scale,
      decoration: BoxDecoration(
        color: const Color(0xFF140D3E),
        borderRadius: BorderRadius.circular(19 * scale),
        border: Border.all(color: const Color(0xFF38297A), width: 1.2 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: Row(
        children: [
          // Knight Option
          Expanded(
            child: _buildTierPill(
              title: 'KNIGHT',
              shieldAsset:
                  'assets/graphics/purchase_screen/subscription_tab/icon_knight_shield_small.png',
              isSelected: selectedTierIndex == 0,
              activeGradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
              ),
              activeBorderColor: const Color(0xFF93C5FD),
              index: 0,
            ),
          ),

          // Baron Option
          Expanded(
            child: _buildTierPill(
              title: 'BARON',
              shieldAsset:
                  'assets/graphics/purchase_screen/subscription_tab/icon_baron_shield_small.png',
              isSelected: selectedTierIndex == 1,
              activeGradient: const LinearGradient(
                colors: [Color(0xFFA855F7), Color(0xFF7E22CE)],
              ),
              activeBorderColor: const Color(0xFFE9D5FF),
              index: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierPill({
    required String title,
    required String shieldAsset,
    required bool isSelected,
    required LinearGradient activeGradient,
    required Color activeBorderColor,
    required int index,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        SoundService().playButtonClick();
        onTierChanged(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: EdgeInsets.all(2.5 * scale),
        decoration: BoxDecoration(
          gradient: isSelected ? activeGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(16 * scale),
          border: isSelected
              ? Border.all(color: activeBorderColor, width: 1.2 * scale)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (index == 0
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFFA855F7))
                        .withOpacity(0.4),
                    blurRadius: 6 * scale,
                    offset: Offset(0, 1 * scale),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              shieldAsset,
              width: 18 * scale,
              height: 18 * scale,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.shield_rounded,
                size: 16 * scale,
                color: isSelected ? Colors.white : const Color(0xFF8B7BC4),
              ),
            ),
            SizedBox(width: 6 * scale),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12 * scale,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF8B7BC4),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
