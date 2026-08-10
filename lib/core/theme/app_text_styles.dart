import 'package:flutter/material.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';

/// Typography tokens mapped from Figma (Artegra Sans family → Poppins).
abstract final class AppTextStyles {
  static const String _fontFamily = 'Poppins';

  // ── Headings ─────────────────────────────────────────────────────────────
  static const TextStyle h1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 0.96,
    color: AppColors.textPrimary,
  );

  static TextStyle get headingLarge => h1;
  static TextStyle get headingMedium => h2;
  static TextStyle get bodyMediumBold => bodyMedium;

  static const TextStyle h2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 0.8,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 0.72,
    color: AppColors.textPrimary,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 0.64,
    color: AppColors.textPrimary,
  );

  // ── Body ─────────────────────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.008,
    letterSpacing: 0.6,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    height: 1.008,
    letterSpacing: 0.52,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.008,
    letterSpacing: 0.48,
    color: AppColors.textPrimary,
  );

  // ── Caption & label ──────────────────────────────────────────────────────
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 0.44,
    color: AppColors.textPrimary,
  );

  static const TextStyle captionSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 0.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle micro = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 9,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 0.36,
    color: AppColors.textPrimary,
  );

  static const TextStyle badge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 5,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelActive = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0.0,
    color: AppColors.textPrimary,
    shadows: [
      Shadow(
        color: Color(0x82FFFFFF),
        blurRadius: 6.2,
      ),
    ],
  );

  // ── Navigation ───────────────────────────────────────────────────────────
  static const TextStyle navLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0.0,
    color: AppColors.textPrimary,
  );

  static const TextStyle tabLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    height: 1.008,
    letterSpacing: 0.0,
    color: AppColors.textSecondary,
  );

  static const TextStyle tabLabelActive = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    height: 1.008,
    letterSpacing: 0.0,
    color: AppColors.textPrimary,
  );

  static const TextStyle sectionHeader = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w800,
    height: 1.0,
    letterSpacing: 0.6,
    color: AppColors.textPrimary,
  );

  static const TextStyle sectionLink = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w800,
    height: 1.0,
    letterSpacing: 0.48,
    color: AppColors.secondaryMuted,
  );

  // ── Button text ──────────────────────────────────────────────────────────
  static const TextStyle buttonPrimary = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 0.6,
    color: AppColors.actionOrangeText,
  );

  static const TextStyle buttonSecondary = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 0.6,
    color: AppColors.textPrimary,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 0.52,
    color: AppColors.actionOrangeText,
  );

  static const TextStyle buttonCancel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 0.72,
    color: AppColors.cancelText,
  );

  // ── Splash & special ─────────────────────────────────────────────────────
  static const TextStyle splashTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 0.96,
    color: AppColors.textPrimary,
  );

  static const TextStyle splashBrand = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 1.6,
    color: AppColors.textPrimary,
    shadows: [
      Shadow(
        color: Color(0x665641F8),
        blurRadius: 24,
        offset: Offset(0, 4),
      ),
      Shadow(
        color: Color(0x82FFFFFF),
        blurRadius: 8,
      ),
    ],
  );

  static const TextStyle splashTip = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 0.0,
    color: AppColors.textSecondary,
  );

  static const TextStyle emptyState = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.008,
    letterSpacing: 0.0,
    color: AppColors.textDark,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.008,
    letterSpacing: 0.0,
    color: AppColors.textTertiary,
  );

  static const TextStyle resourceValue = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 0.64,
    color: AppColors.textPrimary,
  );

  static const TextStyle playerName = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 0.4,
    color: AppColors.textPrimary,
  );

  static TextStyle withShadow(TextStyle style) {
    return style.copyWith(
      shadows: const [
        Shadow(
          color: Color(0x21000000),
          blurRadius: 1.9,
          offset: Offset(0, 1),
        ),
      ],
    );
  }
}
