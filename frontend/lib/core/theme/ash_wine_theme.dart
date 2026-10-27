import 'package:flutter/material.dart';

/// Bespoke "Ash Wine" Color Palette and Theme System
/// Crafted specifically for the Railway Announcements & Indian Sign Language system.
class AshWineTheme {
  // Primary Wine Palette
  static const Color primary = Color(0xFF6E2841); // Deep Ash Wine
  static const Color primaryLight = Color(0xFF8F3958); // Vivid Ash Wine
  static const Color primaryDark = Color(0xFF4C192C); // Midnight Wine

  // Accents & Highlights
  static const Color mauve = Color(0xFFA85B78); // Dusty Mauve
  static const Color rose = Color(0xFFC97D98); // Soft Rose Accent
  static const Color champagne = Color(0xFFE5B887); // Warm Railway Gold
  static const Color entityAmber = Color(0xFFF28B50); // Radiant Proper Noun Highlight

  // Dark Canvas & Surfaces
  static const Color bgDark = Color(0xFF160C12); // Velvet Midnight Ash Wine
  static const Color surfaceDark = Color(0xFF22121B); // Rich Dark Surface
  static const Color cardDark = Color(0xFF2A1622); // Elevated Card Surface
  static const Color cardBorderDark = Color(0x38A85B78); // Subtle Glassmorphic Border

  // Light Canvas & Surfaces
  static const Color bgLight = Color(0xFFFAF4F6); // Soft Chalk Rose White
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFF5EBF0);
  static const Color cardBorderLight = Color(0x1EA85B78);

  // Typography Colors
  static const Color textPrimaryDark = Color(0xFFFCF6F8);
  static const Color textSecondaryDark = Color(0xFFC4ACB6);
  static const Color textMutedDark = Color(0xFF8B727D);

  static const Color textPrimaryLight = Color(0xFF25121B);
  static const Color textSecondaryLight = Color(0xFF644350);
  static const Color textMutedLight = Color(0xFF9E7B89);

  // Gradients
  static const LinearGradient wineHeroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7A2A47),
      Color(0xFF52192F),
      Color(0xFF330E1D),
    ],
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF321A28),
      Color(0xFF24131D),
    ],
  );

  static const LinearGradient goldAccentGradient = LinearGradient(
    colors: [
      Color(0xFFF2C89A),
      Color(0xFFD69A58),
    ],
  );

  static const LinearGradient properNounGradient = LinearGradient(
    colors: [
      Color(0xFFF59E6B),
      Color(0xFFE86A38),
    ],
  );

  /// Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      canvasColor: surfaceDark,
      cardColor: cardDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryLight,
        secondary: mauve,
        surface: surfaceDark,
        surfaceContainerHighest: cardDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryDark,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: textPrimaryDark),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: cardBorderDark, width: 1),
        ),
      ),
    );
  }

  /// Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgLight,
      canvasColor: surfaceLight,
      cardColor: cardLight,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: mauve,
        surface: surfaceLight,
        surfaceContainerHighest: cardLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryLight,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: bgLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: textPrimaryLight),
      ),
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: cardBorderLight, width: 1),
        ),
      ),
    );
  }
}
