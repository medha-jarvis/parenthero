import 'package:flutter/material.dart';

/// Design system colors for ParentHero.
///
/// Kid-friendly, vibrant color palette with subject-specific colors.
class AppColors {
  AppColors._();

  // ==================================================================
  // Primary Brand Colors
  // ==================================================================

  /// Primary brand color — vibrant blue
  static const Color primary = Color(0xFF1CB0F6);
  static const Color primaryLight = Color(0xFF7DD4F9);
  static const Color primaryDark = Color(0xFF0E7BA8);

  /// Secondary brand color — energetic green
  static const Color secondary = Color(0xFF58CC02);
  static const Color secondaryLight = Color(0xFF89E359);
  static const Color secondaryDark = Color(0xFF3A8A01);

  /// Accent color — warm coral
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentLight = Color(0xFFFF9E9E);
  static const Color accentDark = Color(0xFFCC4444);

  // ==================================================================
  // Subject Colors
  // ==================================================================

  /// Mathematics — Blue
  static const Color mathBlue = Color(0xFF1CB0F6);
  static const Color mathBlueLight = Color(0xFF7DD4F9);
  static const Color mathBlueDark = Color(0xFF0E7BA8);

  /// English — Coral / Red
  static const Color englishCoral = Color(0xFFFF6B6B);
  static const Color englishCoralLight = Color(0xFFFF9E9E);
  static const Color englishCoralDark = Color(0xFFCC4444);

  /// Science / EVS — Green
  static const Color scienceGreen = Color(0xFF58CC02);
  static const Color scienceGreenLight = Color(0xFF89E359);
  static const Color scienceGreenDark = Color(0xFF3A8A01);

  // ==================================================================
  // Background Colors
  // ==================================================================

  /// Main app background — very light gray
  static const Color background = Color(0xFFF7F7F7);

  /// Card background — pure white
  static const Color cardBackground = Color(0xFFFFFFFF);

  /// Surface color — light gray for elevated surfaces
  static const Color surface = Color(0xFFF0F0F0);

  /// Dark background for dark mode
  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color darkSurface = Color(0xFF16213E);
  static const Color darkCard = Color(0xFF0F3460);

  // ==================================================================
  // Text Colors
  // ==================================================================

  /// Primary text — near black
  static const Color textPrimary = Color(0xFF2B2B2B);

  /// Secondary text — medium gray
  static const Color textSecondary = Color(0xFF777777);

  /// Tertiary text — light gray
  static const Color textTertiary = Color(0xFFAAAAAA);

  /// Text on dark backgrounds — white
  static const Color textOnDark = Color(0xFFFFFFFF);

  /// Text on colored backgrounds — white
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// Link text — primary blue
  static const Color textLink = Color(0xFF1CB0F6);

  // ==================================================================
  // Status Colors
  // ==================================================================

  /// Success — green
  static const Color success = Color(0xFF58CC02);

  /// Error — red
  static const Color error = Color(0xFFFF4B4B);

  /// Warning — amber
  static const Color warning = Color(0xFFFFC107);

  /// Info — blue
  static const Color info = Color(0xFF1CB0F6);

  // ==================================================================
  // UI Element Colors
  // ==================================================================

  /// Divider / border color
  static const Color divider = Color(0xFFE0E0E0);

  /// Disabled state
  static const Color disabled = Color(0xFFCCCCCC);

  /// Overlay / scrim
  static const Color overlay = Color(0x80000000);

  /// Shimmer / skeleton loading base
  static const Color shimmerBase = Color(0xFFE0E0E0);

  /// Shimmer / skeleton loading highlight
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // ==================================================================
  // Grade Colors (for visual differentiation)
  // ==================================================================

  static const Color grade1 = Color(0xFFFF6B6B);
  static const Color grade2 = Color(0xFFFF9F43);
  static const Color grade3 = Color(0xFFFECA57);
  static const Color grade4 = Color(0xFF48DBFB);
  static const Color grade5 = Color(0xFFA29BFE);

  // ==================================================================
  // Avatar Colors
  // ==================================================================

  static const List<Color> avatarColors = [
    Color(0xFF1CB0F6),
    Color(0xFFFF6B6B),
    Color(0xFF58CC02),
    Color(0xFFFF9F43),
    Color(0xFFA29BFE),
    Color(0xFFFECA57),
    Color(0xFFFF8A5C),
    Color(0xFF45B7D1),
  ];

  // ==================================================================
  // Gradient Definitions
  // ==================================================================

  /// Primary gradient (blue to green)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  /// Sunset gradient (coral to amber)
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, Color(0xFFFF9F43)],
  );

  /// Cool gradient (blue to purple)
  static const LinearGradient coolGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFFA29BFE)],
  );

  /// Warm gradient (coral to pink)
  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, Color(0xFFFF6B9D)],
  );

  /// Green gradient (for science)
  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, Color(0xFF89E359)],
  );

  // ==================================================================
  // Helper Methods
  // ==================================================================

  /// Returns the subject color for a given subject name.
  static Color subjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'math':
      case 'mathematics':
        return mathBlue;
      case 'english':
        return englishCoral;
      case 'science':
      case 'evs':
        return scienceGreen;
      default:
        return primary;
    }
  }

  /// Returns a lighter version of the subject color.
  static Color subjectColorLight(String subject) {
    switch (subject.toLowerCase()) {
      case 'math':
      case 'mathematics':
        return mathBlueLight;
      case 'english':
        return englishCoralLight;
      case 'science':
      case 'evs':
        return scienceGreenLight;
      default:
        return primaryLight;
    }
  }

  /// Returns the grade color for a given grade (1-5).
  static Color gradeColor(int grade) {
    switch (grade) {
      case 1:
        return grade1;
      case 2:
        return grade2;
      case 3:
        return grade3;
      case 4:
        return grade4;
      case 5:
        return grade5;
      default:
        return primary;
    }
  }

  /// Returns an avatar color by index.
  static Color avatarColor(int index) {
    return avatarColors[index % avatarColors.length];
  }
}