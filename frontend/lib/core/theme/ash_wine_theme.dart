import 'package:flutter/material.dart';

/// Bespoke "Ash Wine" Color Palette and Dynamic Theme System
///
/// Exact color specifications provided:
/// - CMYK: 0, 18, 6, 80
/// - RGB: 50, 41, 47
/// - HEX: #32292F
class AshWineTheme {
  // Exact Anchor Color (CMYK: 0, 18, 6, 80 | RGB: 50, 41, 47 | #32292F)
  static const Color exactAshWine = Color(0xFF32292F);
  static const Color primary = Color(0xFF32292F);
  static const Color primaryLight = Color(0xFF4C3E47);
  static const Color primaryDark = Color(0xFF1E171C);
  static const Color primaryTint = Color(0xFF6B5A65);

  // Soft accents & railway highlights
  static const Color mauve = Color(0xFF8F6B7B);
  static const Color rose = Color(0xFFB58D9E);
  static const Color champagne = Color(0xFFD4A373); // Railway Champagne Gold
  static const Color entityAmber = Color(0xFFD97736); // Proper Noun / Name Highlight
  static const Color alertRed = Color(0xFFC04B54); // Missing child / urgent alert

  // LIGHT THEME CANVASES & SURFACES (Clean, airy, comfortable)
  static const Color bgLight = Color(0xFFFAF7F8); // Clean light linen canvas
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure white header / surface
  static const Color cardLight = Color(0xFFFFFFFF); // Pure white elevated card
  static const Color cardBorderLight = Color(0xFFEADBDF); // Subtle Ash Wine hairline border
  static const Color cardBgSecondaryLight = Color(0xFFF3ECEF); // Light ash tint container

  static const Color textPrimaryLight = Color(0xFF32292F); // Exact Ash Wine typography
  static const Color textSecondaryLight = Color(0xFF5E4F57); // Medium ash wine
  static const Color textMutedLight = Color(0xFF8C7A83); // Soft muted

  // DARK THEME CANVASES & SURFACES (Deep velvet ash wine)
  static const Color bgDark = Color(0xFF1B1518);
  static const Color surfaceDark = Color(0xFF261E23);
  static const Color cardDark = Color(0xFF2E242A);
  static const Color cardBorderDark = Color(0xFF473942);
  static const Color cardBgSecondaryDark = Color(0xFF3B2F36);

  static const Color textPrimaryDark = Color(0xFFFBF8FA);
  static const Color textSecondaryDark = Color(0xFFD4C7CD);
  static const Color textMutedDark = Color(0xFF9E8F96);

  // Dynamic Theme Helpers based on BuildContext
  static bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
  static Color bg(BuildContext context) => isDark(context) ? bgDark : bgLight;
  static Color surface(BuildContext context) => isDark(context) ? surfaceDark : surfaceLight;
  static Color card(BuildContext context) => isDark(context) ? cardDark : cardLight;
  static Color cardBorder(BuildContext context) => isDark(context) ? cardBorderDark : cardBorderLight;
  static Color cardBgSecondary(BuildContext context) => isDark(context) ? cardBgSecondaryDark : cardBgSecondaryLight;
  static Color textPrimary(BuildContext context) => isDark(context) ? textPrimaryDark : textPrimaryLight;
  static Color textSecondary(BuildContext context) => isDark(context) ? textSecondaryDark : textSecondaryLight;
  static Color textMuted(BuildContext context) => isDark(context) ? textMutedDark : textMutedLight;

  // Gradients
  static const LinearGradient ashWineGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4C3E47),
      Color(0xFF32292F),
      Color(0xFF1E171C),
    ],
  );

  static const LinearGradient wineHeroGradient = ashWineGradient;

  static const LinearGradient ashWineLightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF8F2F5),
      Color(0xFFEADBDF),
    ],
  );

  static const LinearGradient goldAccentGradient = LinearGradient(
    colors: [
      Color(0xFFE2B788),
      Color(0xFFC7925B),
    ],
  );

  static const LinearGradient properNounGradient = LinearGradient(
    colors: [
      Color(0xFFE88A4C),
      Color(0xFFD97736),
    ],
  );

  /// Light Theme (Default: light, clean, human-designed, elegant)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgLight,
      canvasColor: surfaceLight,
      cardColor: cardLight,
      colorScheme: const ColorScheme.light(
        primary: exactAshWine,
        onPrimary: Colors.white,
        secondary: mauve,
        onSecondary: Colors.white,
        surface: surfaceLight,
        onSurface: textPrimaryLight,
        surfaceContainerHighest: cardBgSecondaryLight,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: exactAshWine),
      ),
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 1,
        shadowColor: const Color(0x1432292F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: cardBorderLight, width: 1.2),
        ),
      ),
    );
  }

  /// Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      canvasColor: surfaceDark,
      cardColor: cardDark,
      colorScheme: const ColorScheme.dark(
        primary: rose,
        onPrimary: Colors.white,
        secondary: mauve,
        onSecondary: Colors.white,
        surface: surfaceDark,
        onSurface: textPrimaryDark,
        surfaceContainerHighest: cardDark,
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
}
