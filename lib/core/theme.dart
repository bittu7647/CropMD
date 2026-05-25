import 'package:flutter/material.dart';

class AppTheme {
  // ── Legacy Color Palette (kept for compatibility) ──
  static const Color primaryGreen = Color(0xFF10B981); // Vibrant Emerald Green
  static const Color secondaryGreen = Color(0xFF047857); // Deep Forest Green
  static const Color slateDark = Color(0xFF0F172A); // Dark Slate (Background/Text)
  static const Color slateMedium = Color(0xFF334155); // Slate Medium
  static const Color slateLight = Color(0xFF64748B); // Slate Light for secondary text
  static const Color cleanWhite = Color(0xFFF8FAFC); // Clean White/Off-white
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color accentGreen = Color(0xFF34D399); // Light accent green
  static const Color alertRed = Color(0xFFEF4444); // Alert / Warning Red

  // ── Dark Glassmorphism Palette ──
  static const Color bgDark = Color(0xFF0A0E1A);
  static const Color bgCard = Color(0xFF141927);
  static const Color bgSurface = Color(0xFF1A1F2E);
  static const Color bgElevated = Color(0xFF1E2435);
  static const Color textPrimary = Color(0xFFE8ECF4);
  static const Color textSecondary = Color(0xFFA0AABE);
  static const Color textMuted = Color(0xFF6B7590);
  static const Color warningOrange = Color(0xFFFB923C);
  static const Color glassBorder = Color(0x3310B981); // ~20% opacity green

  // ── Gradients ──
  static const LinearGradient greenGradient = LinearGradient(
    colors: [primaryGreen, secondaryGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [bgDark, Color(0xFF0F1520), bgDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Glow Helpers ──
  static List<BoxShadow> greenGlow({double opacity = 0.3, double blur = 20}) {
    return [
      BoxShadow(
        color: primaryGreen.withOpacity(opacity),
        blurRadius: blur,
        spreadRadius: 0,
      ),
    ];
  }

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: bgDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        secondary: secondaryGreen,
        surface: bgSurface,
        error: alertRed,
        onPrimary: bgDark,
        onSecondary: pureWhite,
        onSurface: textPrimary,
        onError: pureWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Outfit',
        ),
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: glassBorder),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary),
        bodyLarge: TextStyle(fontSize: 16, color: textSecondary),
        bodyMedium: TextStyle(fontSize: 14, color: textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: bgDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: alertRed),
        ),
        labelStyle: const TextStyle(color: textMuted),
        hintStyle: const TextStyle(color: textMuted),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: bgElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Outfit',
        ),
        contentTextStyle: const TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontFamily: 'Outfit',
        ),
      ),
    );
  }
}
