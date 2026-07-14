import 'package:flutter/material.dart';

import 'colors.dart';

/// Base em size for letter-spacing calculations.
const double kEm = 1.0;

class AppTypography {
  // DM Sans - body text
  static const String bodyFontFamily = 'DM Sans';
  // JetBrains Mono - monospace labels/coordinates
  static const String monoFontFamily = 'JetBrains Mono';

  // Type scale definitions
  static TextStyle get labelSmall => const TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 9,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1 * kEm,
  );

  static TextStyle get labelMedium => const TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1 * kEm,
  );

  static TextStyle get bodySmall => const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get bodyMedium => const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get bodyMediumSemiBold => const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get headingSmall => const TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // Monospace variants for technical data
  static TextStyle get monoLabelSmall => const TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 9,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get monoLabelMedium => const TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get monoBodySmall => const TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 9,
    fontWeight: FontWeight.w400,
  );

  // Section header style (uppercase, tracking-widest)
  static TextStyle sectionHeader(BuildContext context) => const TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1 * kEm,
    color: AppColors.mutedForegroundLight,
  );

  // Field name in headers style
  static TextStyle fieldNameHeader(BuildContext context) => TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 9,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.08 * kEm,
    color: Theme.of(context).colorScheme.primary,
  );

  // Detected text value style
  static TextStyle detectedValue(BuildContext context) => TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Theme.of(context).colorScheme.onSurface,
  );

  // Coordinate display style
  static TextStyle coordinateDisplay(BuildContext context) => const TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 9,
    fontWeight: FontWeight.w400,
    color: AppColors.mutedForegroundLight,
  );

  // Timestamp style
  static TextStyle timestampStyle(BuildContext context) => const TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 9,
    fontWeight: FontWeight.w400,
    color: AppColors.mutedForegroundLight,
  );
}

class AppSpacing {
  // Horizontal padding
  static const double horizontalPadding = 16.0;
  static const double cardHorizontalPadding = 12.0;

  // Vertical gaps
  static const double gapSmall = 8.0;
  static const double gapMedium = 12.0;
  static const double gapLarge = 16.0;

  // Button padding
  static const EdgeInsets buttonPaddingVertical = EdgeInsets.symmetric(
    vertical: 8,
    horizontal: 16,
  );

  // Card internal padding
  static const EdgeInsets cardInternalPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 12,
  );

  // Border radius
  static const double borderRadiusSmall = 2.0;
  static const double borderRadiusFull = 9999.0;
}
