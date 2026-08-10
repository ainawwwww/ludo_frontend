import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/theme/app_colors.dart';
import 'package:ludo_vibe/core/theme/app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get darkTheme {
    final colorScheme = const ColorScheme.dark(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.textPrimary,
      primaryContainer: AppColors.primaryDark,
      onPrimaryContainer: AppColors.textPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.textPrimary,
      secondaryContainer: AppColors.primaryLight,
      onSecondaryContainer: AppColors.textPrimary,
      tertiary: AppColors.actionOrange,
      onTertiary: AppColors.actionOrangeText,
      error: AppColors.error,
      onError: AppColors.textPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceCard,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.primaryBorderSoft,
      shadow: AppColors.shadowDark,
      scrim: AppColors.surfaceOverlay,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      colorScheme: colorScheme,
      textTheme: _textTheme,
      appBarTheme: _appBarTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      filledButtonTheme: _filledButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      cardTheme: _cardTheme,
      dividerTheme: _dividerTheme,
      bottomNavigationBarTheme: _bottomNavigationBarTheme,
      tabBarTheme: _tabBarTheme,
      dialogTheme: _dialogTheme,
      snackBarTheme: _snackBarTheme,
      progressIndicatorTheme: _progressIndicatorTheme,
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
    );
  }

  static TextTheme get _textTheme {
    return const TextTheme(
      displayLarge: AppTextStyles.h1,
      displayMedium: AppTextStyles.h2,
      displaySmall: AppTextStyles.h3,
      headlineLarge: AppTextStyles.h1,
      headlineMedium: AppTextStyles.h2,
      headlineSmall: AppTextStyles.h3,
      titleLarge: AppTextStyles.h4,
      titleMedium: AppTextStyles.bodyLarge,
      titleSmall: AppTextStyles.bodyMedium,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.buttonPrimary,
      labelMedium: AppTextStyles.label,
      labelSmall: AppTextStyles.captionSmall,
    );
  }

  static AppBarTheme get _appBarTheme {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.transparent,
      foregroundColor: AppColors.textPrimary,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: AppTextStyles.h4,
      toolbarHeight: AppConstants.headerHeight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
    );
  }

  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.actionOrange,
        foregroundColor: AppColors.actionOrangeText,
        disabledBackgroundColor: AppColors.cancelButton,
        disabledForegroundColor: AppColors.cancelText,
        textStyle: AppTextStyles.buttonPrimary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing24,
          vertical: AppConstants.spacing12,
        ),
        minimumSize: const Size(0, AppConstants.buttonHeightMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radius9),
        ),
        shadowColor: AppColors.actionOrangeShadow,
      ),
    );
  }

  static FilledButtonThemeData get _filledButtonTheme {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.primaryBright,
        foregroundColor: AppColors.textPrimary,
        textStyle: AppTextStyles.buttonSecondary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing16,
          vertical: AppConstants.spacing10,
        ),
        minimumSize: const Size(0, AppConstants.buttonHeightSmall),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radius6),
        ),
      ),
    );
  }

  static OutlinedButtonThemeData get _outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        side: const BorderSide(color: AppColors.primaryBorderSoft),
        textStyle: AppTextStyles.bodyMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing16,
          vertical: AppConstants.spacing10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radius9),
        ),
      ),
    );
  }

  static TextButtonThemeData get _textButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.secondaryMuted,
        textStyle: AppTextStyles.sectionLink,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing8,
          vertical: AppConstants.spacing4,
        ),
      ),
    );
  }

  static InputDecorationTheme get _inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceInput,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing16,
        vertical: AppConstants.spacing12,
      ),
      hintStyle: AppTextStyles.h3.copyWith(color: AppColors.textMuted),
      labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textOnPrimary),
      errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radius8),
        borderSide: const BorderSide(color: AppColors.modalAccent, width: 0.4),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radius8),
        borderSide: const BorderSide(color: AppColors.modalAccent, width: 0.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radius8),
        borderSide: const BorderSide(color: AppColors.secondary, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radius8),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radius8),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }

  static CardThemeData get _cardTheme {
    return CardThemeData(
      color: AppColors.surfaceCard,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radius14),
        side: const BorderSide(color: AppColors.primaryBorderSoft),
      ),
      shadowColor: AppColors.shadowDark,
    );
  }

  static DividerThemeData get _dividerTheme {
    return const DividerThemeData(
      color: AppColors.primaryBorderSoft,
      thickness: 1,
      space: 1,
    );
  }

  static BottomNavigationBarThemeData get _bottomNavigationBarTheme {
    return const BottomNavigationBarThemeData(
      backgroundColor: AppColors.transparent,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.textPrimary,
      unselectedItemColor: AppColors.textSecondary,
      selectedLabelStyle: AppTextStyles.navLabel,
      unselectedLabelStyle: AppTextStyles.navLabel,
      showUnselectedLabels: true,
    );
  }

  static TabBarThemeData get _tabBarTheme {
    return TabBarThemeData(
      labelColor: AppColors.textPrimary,
      unselectedLabelColor: AppColors.textSecondary,
      labelStyle: AppTextStyles.tabLabelActive,
      unselectedLabelStyle: AppTextStyles.tabLabel,
      indicator: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppConstants.radius6),
          topRight: Radius.circular(AppConstants.radius6),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.secondary,
            offset: Offset(0, 3),
            blurRadius: 4,
            spreadRadius: 0,
            blurStyle: BlurStyle.inner,
          ),
        ],
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: AppColors.transparent,
      overlayColor: WidgetStateProperty.all(AppColors.transparent),
    );
  }

  static DialogThemeData get _dialogTheme {
    return DialogThemeData(
      backgroundColor: AppColors.surfaceModal,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radius19),
        side: const BorderSide(color: AppColors.modalBorder, width: 4),
      ),
      titleTextStyle: AppTextStyles.h1,
      contentTextStyle: AppTextStyles.bodyMedium,
    );
  }

  static SnackBarThemeData get _snackBarTheme {
    return SnackBarThemeData(
      backgroundColor: AppColors.surfaceCard,
      contentTextStyle: AppTextStyles.bodySmall,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radius9),
      ),
    );
  }

  static ProgressIndicatorThemeData get _progressIndicatorTheme {
    return const ProgressIndicatorThemeData(
      color: AppColors.secondary,
      linearTrackColor: AppColors.progressTrack,
      circularTrackColor: AppColors.progressTrack,
    );
  }

  /// Orange glossy action button decoration from Figma.
  static BoxDecoration orangeButtonDecoration({double borderRadius = AppConstants.radius9}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: AppColors.actionOrange,
      boxShadow: const [
        BoxShadow(
          color: Color(0x24000000),
          offset: Offset(0, 5),
          blurRadius: 2,
        ),
        BoxShadow(
          color: AppColors.actionOrangeShadow,
          offset: Offset(0, 3),
          blurRadius: 0,
        ),
      ],
    );
  }

  /// Inset glow used on active tabs and cards.
  static List<BoxShadow> get purpleInsetGlow => const [
        BoxShadow(
          color: AppColors.secondary,
          offset: Offset(0, 1),
          blurRadius: 1,
          spreadRadius: 0,
          blurStyle: BlurStyle.inner,
        ),
      ];

  /// Header bar decoration with Figma gradient and shadow.
  static BoxDecoration get headerDecoration => const BoxDecoration(
        gradient: AppColors.headerGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      );
}
