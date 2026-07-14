import 'package:flutter/material.dart';

class AppColors {
  // Light theme colors
  static const Color backgroundLight = Color(0xFFF2F2EE);
  static const Color foregroundLight = Color(0xFF111218);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0x1E111218); // rgba(17,18,24,0.12)
  static const Color primaryLight = Color(0xFF0047CC);
  static const Color primaryForegroundLight = Color(0xFFFFFFFF);
  static const Color mutedLight = Color(0xFFE2E2DC);
  static const Color mutedForegroundLight = Color(0xFF6B6B72);
  static const Color accentLight = Color(0xFF0047CC);
  static const Color ringLight = Color(0xFF0047CC);
  static const Color destructiveLight = Color(0xFFCC2200);

  // Dark theme colors (oklch approximations)
  static const Color backgroundDark = Color(0xFF252525);
  static const Color foregroundDark = Color(0xFFF9FAFB);
  static const Color cardDark = Color(0xFF252525);
  static const Color borderDark = Color(0xFF454545);
  static const Color primaryDark = Color(0xFFF9FAFB);
  static const Color mutedDark = Color(0xFF454545);
  static const Color mutedForegroundDark = Color(0xFFB3B3B3);

  // Confidence pill colors
  static const Color emerald100 = Color(0xFFD1FAE5);
  static const Color emerald700 = Color(0xFF047857);
  static const Color amber100 = Color(0xFFFFF3C7);
  static const Color amber700 = Color(0xFFB45309);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red700 = Color(0xFFDC2626);

  // Template-specific colors
  static const Map<String, Color> templateColors = {
    'Produit laitier': Color(0xFFE8F0FE),
    'Conserves alimentaires': Color(0xFFFEF3E8),
    'Surgelés': Color(0xFFE8F8FE),
    'Cosmétiques': Color(0xFFF5E8FE),
    'Médicaments OTC': Color(0xFFFEE8E8),
  };

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryLight,
      onPrimary: primaryForegroundLight,
      surface: cardLight,
      onSurface: foregroundLight,
      outline: borderLight,
      outlineVariant: borderLight,
      secondary: mutedLight,
      onSecondary: mutedForegroundLight,
    ),
    scaffoldBackgroundColor: backgroundLight,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontFamily: 'DM Sans', fontSize: 16),
      bodyMedium: TextStyle(fontFamily: 'DM Sans', fontSize: 14),
      bodySmall: TextStyle(fontFamily: 'DM Sans', fontSize: 12),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryDark,
      onPrimary: backgroundDark,
      surface: cardDark,
      onSurface: foregroundDark,
      outline: borderDark,
      outlineVariant: borderDark,
      secondary: mutedDark,
      onSecondary: mutedForegroundDark,
    ),
    scaffoldBackgroundColor: backgroundDark,
  );

  static Color getCardColor(BuildContext context) =>
      Theme.of(context).colorScheme.surface;
  static Color getBorderColor(BuildContext context) =>
      Theme.of(context).colorScheme.outline;
  static Color getMutedForeground(BuildContext context) =>
      Theme.of(context).colorScheme.onSecondary;
}
