import 'package:flutter/material.dart';

/// Color tokens extracted from the LudoVibe Figma design file.
abstract final class AppColors {
  // ── Primary & brand ──────────────────────────────────────────────────────
  static const Color primary = Color(0xFF5641F8);
  static const Color primaryDark = Color(0xFF3C00A5);
  static const Color primaryLight = Color(0xFF7B4BCD);
  static const Color primaryBright = Color(0xFF554ACA);
  static const Color primarySurface = Color(0xFF4A38D7);
  static const Color primaryBorder = Color(0xFF9985F9);
  static const Color primaryBorderSoft = Color(0xFF969FFA);

  // ── Secondary & accent ───────────────────────────────────────────────────
  static const Color secondary = Color(0xFFB173FF);
  static const Color secondaryLight = Color(0xFFCCA3FF);
  static const Color secondaryMuted = Color(0xFFDFA5FF);
  static const Color accentPurple = Color(0xFF836DDF);
  static const Color accentGlow = Color(0xFFB173FF);

  // ── Background & surface ─────────────────────────────────────────────────
  static const Color background = Color(0xFF0A0022);
  static const Color backgroundDeep = Color(0xFF1C0D2D);
  static const Color backgroundGame = Color(0xFF2B124C);
  static const Color scaffoldBackground = Color(0xFF120A2E);
  static const Color surface = Color(0xFF221793);
  static const Color surfaceElevated = Color(0xFF3B3281);
  static const Color surfaceCard = Color(0xFF554ACA);
  static const Color surfaceModal = Color(0xFF3F349F);
  static const Color surfaceModalDark = Color(0xFF3A2F9F);
  static const Color surfaceOverlay = Color(0xAD000000);
  static const Color surfaceOverlayLight = Color(0x6E000000);
  static const Color surfaceInput = Color(0xFFFFFFFF);
  static const Color surfaceDisabled = Color(0xFFD9D9D9);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB173FF);
  static const Color textTertiary = Color(0xFFCCA3FF);
  static const Color textMuted = Color(0xFF666666);
  static const Color textDisabled = Color(0xFF707070);
  static const Color textDark = Color(0xFF0C0064);
  static const Color textOnPrimary = Color(0xFF3C00A5);
  static const Color textGradientEnd = Color(0xFFDBDBDB);

  // ── Orange action buttons ──────────────────────────────────────────────────
  static const Color actionOrange = Color(0xFFF97023);
  static const Color actionOrangeHighlight = Color(0xFFFF833D);
  static const Color actionOrangeGlow = Color(0xFFFFA06B);
  static const Color actionOrangeGradientStart = Color(0xFFFF9B63);
  static const Color actionOrangeGradientEnd = Color(0xFFFD9256);
  static const Color actionOrangeShadow = Color(0xFFC24906);
  static const Color actionOrangeText = Color(0xFFAD4308);
  static const Color actionOrangeBorder = Color(0xFFF75F01);
  static const Color actionOrangeSelection = Color(0x66ECA800);

  // ── Status ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF56AB2F);
  static const Color warning = Color(0xFFFFD200);
  static const Color error = Color(0xFFE31E24);
  static const Color info = Color(0xFF0072BC);

  // ── Game board colors ────────────────────────────────────────────────────
  static const Color ludoGreen = Color(0xFF00A859);
  static const Color ludoYellow = Color(0xFFFFD200);
  static const Color ludoRed = Color(0xFFE31E24);
  static const Color ludoBlue = Color(0xFF0072BC);

  // ── Neutral & utility ────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);
  static const Color shadowDark = Color(0xFF190D74);
  static const Color shadowPurple = Color(0xFF230343);
  static const Color shadowGold = Color(0xFF6C5515);
  static const Color goldHighlight = Color(0xFFFDD369);
  static const Color modalBorder = Color(0xFF362A76);
  static const Color modalAccent = Color(0xFF7B65EF);
  static const Color progressTrack = Color(0xFF765ADD);
  static const Color cancelButton = Color(0xFFAFAEAE);
  static const Color cancelButtonHighlight = Color(0xFFC8C9CD);
  static const Color cancelGradientStart = Color(0xFFBAB9B9);
  static const Color cancelGradientEnd = Color(0xFFCBCACA);
  static const Color cancelShadow = Color(0xFF7A7A7A);
  static const Color cancelText = Color(0xFF707070);
  static const Color paginationActive = Color(0xFFF97023);
  static const Color paginationInactive = Color(0xFF836DDF);

  // ── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF3A327F), Color(0xFF5356C9)],
    stops: [0.0259, 0.9741],
  );

  static const LinearGradient headerGradientDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF3A327F), Color(0xFF1C0D2D)],
    stops: [0.0259, 0.9741],
  );

  static const LinearGradient headerGradientAlt = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF3A327F), Color(0xFF5356C9)],
    stops: [0.7736, 0.9741],
  );

  static const LinearGradient bottomNavGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF5641F8), Color(0xFF36289E)],
  );

  static const LinearGradient leagueCardGradient = LinearGradient(
    begin: Alignment(-0.12, -0.99),
    end: Alignment(0.12, 0.99),
    colors: [Color(0xFF5641F8), Color(0xFF36289E)],
    stops: [0.1409, 0.8591],
  );

  static const LinearGradient listItemGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF3F31CD), Color(0xCCB173FF)],
    stops: [0.3579, 0.9926],
  );

  static const LinearGradient modalGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF806AF5), Color(0xFF36299F)],
  );

  static const LinearGradient modalInnerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF3F349F), Color(0xFF3A2F9F)],
  );

  static const LinearGradient rewardCardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF6D55D0), Color(0xFF6D54CF)],
  );

  static const LinearGradient tabActiveHighlightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF3C3586), Color(0xFFB173FF)],
    stops: [0.5193, 1.0],
  );

  static const LinearGradient titleTextGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFDBDBDB)],
  );

  static const LinearGradient orangeButtonTopGradient = LinearGradient(
    begin: Alignment(0.0, -1.0),
    end: Alignment(0.0, 1.0),
    colors: [Color(0xFFFF9B63), Color(0x4DFD9256)],
    stops: [0.1513, 0.8778],
  );

  static const LinearGradient orangeButtonBodyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF97023), Color(0xFFF97023)],
  );

  static const LinearGradient cancelButtonTopGradient = LinearGradient(
    begin: Alignment(0.0, -1.0),
    end: Alignment(0.0, 1.0),
    colors: [Color(0xFFBAB9B9), Color(0xFFCBCACA)],
    stops: [0.1222, 0.8778],
  );

  static const RadialGradient splashBackgroundGradient = RadialGradient(
    center: Alignment(0.0, -0.2),
    radius: 1.2,
    colors: [Color(0xFF5E17EB), Color(0xFF3D00A5)],
  );

  static const LinearGradient gameScreenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2F124A), Color(0xFF2E124C)],
  );

  static LinearGradient orangeButtonGradient({double angleDegrees = 177.39}) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color(0xFFFF9B63),
        Color(0x4DFD9256),
      ],
      stops: const [0.1513, 0.8778],
      transform: GradientRotation(angleDegrees * 3.141592653589793 / 180),
    );
  }
}
