import 'package:flutter/material.dart';

import '../constants/colors.dart';

/// ParentHero Material 3 theme.
///
/// Kid-friendly, colorful design system with:
/// - Custom text styles with rounded, playful feel
/// - Rounded button themes
/// - Card themes with subtle shadows
/// - Input decoration themes
/// - Subject-specific color schemes
class AppTheme {
  AppTheme._();

  // ==================================================================
  // Typography
  // ==================================================================

  /// Base text style with the app's font family.
  static const String _fontFamily = 'Nunito';

  /// Light theme text theme.
  static TextTheme get _lightTextTheme {
    return const TextTheme(
      // Display styles (large headers)
      displayLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.25,
        height: 1.25,
      ),
      displaySmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.3,
      ),

      // Headline styles
      headlineLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.3,
      ),
      headlineMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.35,
      ),
      headlineSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      ),

      // Title styles
      titleLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.45,
      ),
      titleSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.5,
      ),

      // Body styles
      bodyLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.55,
      ),
      bodySmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      ),

      // Label styles
      labelLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.4,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Dark theme text theme (lighter text on dark backgrounds).
  static TextTheme get _darkTextTheme {
    return TextTheme(
      displayLarge: _lightTextTheme.displayLarge!.copyWith(
        color: AppColors.textOnDark,
      ),
      displayMedium: _lightTextTheme.displayMedium!.copyWith(
        color: AppColors.textOnDark,
      ),
      displaySmall: _lightTextTheme.displaySmall!.copyWith(
        color: AppColors.textOnDark,
      ),
      headlineLarge: _lightTextTheme.headlineLarge!.copyWith(
        color: AppColors.textOnDark,
      ),
      headlineMedium: _lightTextTheme.headlineMedium!.copyWith(
        color: AppColors.textOnDark,
      ),
      headlineSmall: _lightTextTheme.headlineSmall!.copyWith(
        color: AppColors.textOnDark,
      ),
      titleLarge: _lightTextTheme.titleLarge!.copyWith(
        color: AppColors.textOnDark,
      ),
      titleMedium: _lightTextTheme.titleMedium!.copyWith(
        color: AppColors.textOnDark,
      ),
      titleSmall: _lightTextTheme.titleSmall!.copyWith(
        color: AppColors.textOnDark,
      ),
      bodyLarge: _lightTextTheme.bodyLarge!.copyWith(
        color: AppColors.textOnDark,
      ),
      bodyMedium: _lightTextTheme.bodyMedium!.copyWith(
        color: AppColors.textOnDark,
      ),
      bodySmall: _lightTextTheme.bodySmall!.copyWith(
        color: AppColors.textTertiary,
      ),
      labelLarge: _lightTextTheme.labelLarge!.copyWith(
        color: AppColors.textOnDark,
      ),
      labelMedium: _lightTextTheme.labelMedium!.copyWith(
        color: AppColors.textOnDark,
      ),
      labelSmall: _lightTextTheme.labelSmall!.copyWith(
        color: AppColors.textTertiary,
      ),
    );
  }

  // ==================================================================
  // Color Schemes
  // ==================================================================

  /// Light theme color scheme.
  static ColorScheme get _lightColorScheme {
    return ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.secondary,
      onSecondary: AppColors.textOnPrimary,
      secondaryContainer: AppColors.secondaryLight,
      onSecondaryContainer: AppColors.secondaryDark,
      tertiary: AppColors.accent,
      onTertiary: AppColors.textOnPrimary,
      tertiaryContainer: AppColors.accentLight,
      onTertiaryContainer: AppColors.accentDark,
      error: AppColors.error,
      onError: AppColors.textOnPrimary,
      surface: AppColors.cardBackground,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surface,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.divider,
      outlineVariant: AppColors.divider,
      shadow: Colors.black26,
      scrim: AppColors.overlay,
      inverseSurface: AppColors.darkSurface,
      onInverseSurface: AppColors.textOnDark,
      inversePrimary: AppColors.primaryLight,
    );
  }

  /// Dark theme color scheme.
  static ColorScheme get _darkColorScheme {
    return ColorScheme.dark(
      primary: AppColors.primaryLight,
      onPrimary: AppColors.primaryDark,
      primaryContainer: AppColors.primary,
      onPrimaryContainer: AppColors.textOnPrimary,
      secondary: AppColors.secondaryLight,
      onSecondary: AppColors.secondaryDark,
      secondaryContainer: AppColors.secondary,
      onSecondaryContainer: AppColors.textOnPrimary,
      tertiary: AppColors.accentLight,
      onTertiary: AppColors.accentDark,
      tertiaryContainer: AppColors.accent,
      onTertiaryContainer: AppColors.textOnPrimary,
      error: AppColors.error,
      onError: AppColors.textOnPrimary,
      surface: AppColors.darkSurface,
      onSurface: AppColors.textOnDark,
      surfaceContainerHighest: AppColors.darkCard,
      onSurfaceVariant: AppColors.textTertiary,
      outline: AppColors.darkCard,
      outlineVariant: AppColors.darkCard,
      shadow: Colors.black54,
      scrim: AppColors.overlay,
      inverseSurface: AppColors.cardBackground,
      onInverseSurface: AppColors.textPrimary,
      inversePrimary: AppColors.primary,
    );
  }

  // ==================================================================
  // Component Themes
  // ==================================================================

  /// Light theme elevated button theme.
  static ElevatedButtonThemeData get _lightElevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        disabledBackgroundColor: AppColors.disabled,
        disabledForegroundColor: AppColors.textTertiary,
        elevation: 2,
        shadowColor: AppColors.primary.withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Dark theme elevated button theme.
  static ElevatedButtonThemeData get _darkElevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.primaryDark,
        disabledBackgroundColor: AppColors.disabled,
        disabledForegroundColor: AppColors.textTertiary,
        elevation: 2,
        shadowColor: AppColors.primaryLight.withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Light theme outlined button theme.
  static OutlinedButtonThemeData get _lightOutlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 2),
        disabledForegroundColor: AppColors.disabled,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Dark theme outlined button theme.
  static OutlinedButtonThemeData get _darkOutlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        side: const BorderSide(color: AppColors.primaryLight, width: 2),
        disabledForegroundColor: AppColors.disabled,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Light theme text button theme.
  static TextButtonThemeData get _lightTextButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        disabledForegroundColor: AppColors.disabled,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Dark theme text button theme.
  static TextButtonThemeData get _darkTextButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        disabledForegroundColor: AppColors.disabled,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Card theme.
  static CardThemeData get _cardTheme {
    return CardThemeData(
      color: AppColors.cardBackground,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
    );
  }

  /// Dark card theme.
  static CardThemeData get _darkCardTheme {
    return CardThemeData(
      color: AppColors.darkCard,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
    );
  }

  /// Input decoration theme (light).
  static InputDecorationTheme get _lightInputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.disabled),
      ),
      labelStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      hintStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiary,
      ),
      errorStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.error,
      ),
      prefixIconColor: AppColors.textSecondary,
      suffixIconColor: AppColors.textSecondary,
    );
  }

  /// Input decoration theme (dark).
  static InputDecorationTheme get _darkInputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkCard,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.darkCard),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.darkCard),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.disabled),
      ),
      labelStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiary,
      ),
      hintStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiary,
      ),
      errorStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.error,
      ),
      prefixIconColor: AppColors.textTertiary,
      suffixIconColor: AppColors.textTertiary,
    );
  }

  /// AppBar theme (light).
  static AppBarTheme get _lightAppBarTheme {
    return AppBarTheme(
      backgroundColor: AppColors.cardBackground,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),
      actionsIconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),
    );
  }

  /// AppBar theme (dark).
  static AppBarTheme get _darkAppBarTheme {
    return AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.textOnDark,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textOnDark,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textOnDark,
        size: 24,
      ),
      actionsIconTheme: const IconThemeData(
        color: AppColors.textOnDark,
        size: 24,
      ),
    );
  }

  /// Bottom navigation bar theme (light).
  static BottomNavigationBarThemeData get _lightBottomNavTheme {
    return BottomNavigationBarThemeData(
      backgroundColor: AppColors.cardBackground,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Bottom navigation bar theme (dark).
  static BottomNavigationBarThemeData get _darkBottomNavTheme {
    return BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: AppColors.textTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Chip theme (light).
  static ChipThemeData get _lightChipTheme {
    return ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      disabledColor: AppColors.disabled,
      labelStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      secondaryLabelStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      side: BorderSide.none,
    );
  }

  /// Chip theme (dark).
  static ChipThemeData get _darkChipTheme {
    return ChipThemeData(
      backgroundColor: AppColors.darkCard,
      selectedColor: AppColors.primaryLight.withValues(alpha: 0.2),
      disabledColor: AppColors.disabled,
      labelStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textOnDark,
      ),
      secondaryLabelStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      side: BorderSide.none,
    );
  }

  /// Floating action button theme.
  static FloatingActionButtonThemeData get _fabTheme {
    return FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  /// Dark floating action button theme.
  static FloatingActionButtonThemeData get _darkFabTheme {
    return FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: AppColors.primaryDark,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  /// Dialog theme.
  static DialogThemeData get _dialogTheme {
    return DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
    );
  }

  /// Snackbar theme.
  static SnackBarThemeData get _snackBarTheme {
    return SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textOnDark,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
      actionTextColor: AppColors.primaryLight,
    );
  }

  /// Dark snackbar theme.
  static SnackBarThemeData get _darkSnackBarTheme {
    return SnackBarThemeData(
      backgroundColor: AppColors.textOnDark,
      contentTextStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
      actionTextColor: AppColors.primary,
    );
  }

  /// Progress indicator theme.
  static ProgressIndicatorThemeData get _progressIndicatorTheme {
    return ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.surface,
      circularTrackColor: AppColors.surface,
    );
  }

  /// Dark progress indicator theme.
  static ProgressIndicatorThemeData get _darkProgressIndicatorTheme {
    return ProgressIndicatorThemeData(
      color: AppColors.primaryLight,
      linearTrackColor: AppColors.darkCard,
      circularTrackColor: AppColors.darkCard,
    );
  }

  /// Divider theme.
  static DividerThemeData get _dividerTheme {
    return const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    );
  }

  // ==================================================================
  // Theme Data
  // ==================================================================

  /// Light theme.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _lightColorScheme,
      textTheme: _lightTextTheme,
      primaryTextTheme: _lightTextTheme,

      // Component themes
      elevatedButtonTheme: _lightElevatedButtonTheme,
      outlinedButtonTheme: _lightOutlinedButtonTheme,
      textButtonTheme: _lightTextButtonTheme,
      cardTheme: _cardTheme,
      inputDecorationTheme: _lightInputDecorationTheme,
      appBarTheme: _lightAppBarTheme,
      bottomNavigationBarTheme: _lightBottomNavTheme,
      chipTheme: _lightChipTheme,
      floatingActionButtonTheme: _fabTheme,
      dialogTheme: _dialogTheme,
      snackBarTheme: _snackBarTheme,
      progressIndicatorTheme: _progressIndicatorTheme,
      dividerTheme: _dividerTheme,

      // Visual properties
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      cardColor: AppColors.cardBackground,
      dividerColor: AppColors.divider,
      disabledColor: AppColors.disabled,
      highlightColor: AppColors.primary.withValues(alpha: 0.08),
      splashColor: AppColors.primary.withValues(alpha: 0.12),
      focusColor: AppColors.primary.withValues(alpha: 0.12),
      hoverColor: AppColors.primary.withValues(alpha: 0.04),

      // Animation
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // Material 3
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.comfortable,
    );
  }

  /// Dark theme.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _darkColorScheme,
      textTheme: _darkTextTheme,
      primaryTextTheme: _darkTextTheme,

      // Component themes
      elevatedButtonTheme: _darkElevatedButtonTheme,
      outlinedButtonTheme: _darkOutlinedButtonTheme,
      textButtonTheme: _darkTextButtonTheme,
      cardTheme: _darkCardTheme,
      inputDecorationTheme: _darkInputDecorationTheme,
      appBarTheme: _darkAppBarTheme,
      bottomNavigationBarTheme: _darkBottomNavTheme,
      chipTheme: _darkChipTheme,
      floatingActionButtonTheme: _darkFabTheme,
      dialogTheme: _dialogTheme,
      snackBarTheme: _darkSnackBarTheme,
      progressIndicatorTheme: _darkProgressIndicatorTheme,
      dividerTheme: _dividerTheme,

      // Visual properties
      scaffoldBackgroundColor: AppColors.darkBackground,
      canvasColor: AppColors.darkBackground,
      cardColor: AppColors.darkCard,
      dividerColor: AppColors.darkCard,
      disabledColor: AppColors.disabled,
      highlightColor: AppColors.primaryLight.withValues(alpha: 0.08),
      splashColor: AppColors.primaryLight.withValues(alpha: 0.12),
      focusColor: AppColors.primaryLight.withValues(alpha: 0.12),
      hoverColor: AppColors.primaryLight.withValues(alpha: 0.04),

      // Animation
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // Material 3
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.comfortable,
    );
  }
}