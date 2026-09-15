import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // AetherSchedule Cyber Palette (Stitch design tokens)
  static const Color background = Color(0xFF101320);
  static const Color surface = Color(0xFF101320);
  static const Color surfaceDim = Color(0xFF0B0D1B);
  static const Color surfaceContainerLowest = Color(0xFF0B0D1B);
  static const Color surfaceContainerLow = Color(0xFF181B29);
  static const Color surfaceContainer = Color(0xFF1C1F2D);
  static const Color surfaceContainerHigh = Color(0xFF272938);
  static const Color surfaceContainerHighest = Color(0xFF323443);
  static const Color surfaceBright = Color(0xFF363848);

  // Bioluminescent Accents
  static const Color primary = Color(0xFFC0C1FF); // Holographic Indigo
  static const Color primaryContainer = Color(0xFF8083FF);
  static const Color primaryFixed = Color(0xFFE1E0FF);
  static const Color onPrimary = Color(0xFF1000A9);

  static const Color secondary = Color(0xFFC7FFF0); // Neon Mint
  static const Color secondaryContainer = Color(0xFF00F2D1); // Electric Cyan
  static const Color secondaryFixed = Color(0xFF26FEDC);
  static const Color secondaryFixedDim = Color(0xFF00DFC1);
  static const Color onSecondary = Color(0xFF00382F);
  static const Color onSecondaryContainer = Color(0xFF00382F);

  static const Color tertiary = Color(0xFFFBABFF); // Laser Rose
  static const Color tertiaryContainer = Color(0xFFE14EF6);
  static const Color tertiaryFixed = Color(0xFFFFD6FD);
  static const Color tertiaryFixedDim = Color(0xFFFBABFF);
  static const Color onTertiary = Color(0xFF580065);

  // Functional Neutrals
  static const Color onSurface = Color(0xFFE0E1F5);
  static const Color onSurfaceVariant = Color(0xFFC7C4D7);
  static const Color outline = Color(0xFF908FA0);
  static const Color outlineVariant = Color(0xFF464554);
  static const Color error = Color(0xFFFFB4AB);

  // Legacy mappings for backwards-compatibility
  static const Color primaryTeal = secondaryContainer;
  static const Color primaryTealDark = onSecondary;
  static const Color primaryTealLight = secondaryFixed;
  static const Color accentCyan = secondaryContainer;
  static const Color coralAccent = tertiary;
  static const Color groupAllColor = primary;
  static const Color groupD1Color = secondaryContainer;
  static const Color groupD2Color = tertiary;
  static const Color labTagColor = tertiary;
  static const Color theoryTagColor = secondaryContainer;

  // Glass Container Box Decoration Helper
  static BoxDecoration glassDecoration({
    Color? color,
    double opacity = 0.75,
    BorderRadius? borderRadius,
    Color? borderColor,
    double borderWidth = 1.0,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: (color ?? surfaceContainerLow).withAlpha((opacity * 255).round()),
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      border: Border.all(
        color: borderColor ?? outlineVariant.withAlpha(60),
        width: borderWidth,
      ),
      boxShadow: shadows ??
          [
            BoxShadow(
              color: Colors.black.withAlpha(120),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
    );
  }

  // Neon Specular Border Decoration
  static BoxDecoration neonGlassDecoration({
    required Color glowColor,
    BorderRadius? borderRadius,
    double blurRadius = 24,
    double glowAlpha = 0.35,
  }) {
    return BoxDecoration(
      color: surfaceContainerLow.withAlpha(200),
      borderRadius: borderRadius ?? BorderRadius.circular(24),
      border: Border.all(
        color: glowColor.withAlpha(80),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: glowColor.withAlpha((glowAlpha * 255).round()),
          blurRadius: blurRadius,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withAlpha(140),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // Dark Theme (AetherSchedule default)
  static ThemeData darkTheme() {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
      bodyColor: onSurface,
      displayColor: onSurface,
    );

    return base.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        secondary: secondaryContainer,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        error: error,
        onError: Colors.black,
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: outlineVariant.withAlpha(60)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerHigh.withAlpha(180),
        hintStyle: const TextStyle(color: outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: outlineVariant.withAlpha(80)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: secondaryContainer, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    );
  }

  // Light Theme fallback
  static ThemeData lightTheme() => darkTheme(); // AetherSchedule is dark-first
}
