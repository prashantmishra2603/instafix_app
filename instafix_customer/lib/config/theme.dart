import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Core Brand Colors ──────────────────────────────────────────────────────
  static const Color primary      = Color(0xFF6C63FF); // Vibrant purple
  static const Color primaryDark  = Color(0xFF4F46E5); // Deeper indigo
  static const Color primaryLight = Color(0xFF2D2A50); // Dark purple tint for cards/icons bg
  static const Color secondary    = Color(0xFF1E1B3A); // Dark card header bg

  // ── Background & Surface ───────────────────────────────────────────────────
  static const Color background   = Color(0xFF0F0D1F); // Deep dark background
  static const Color surface      = Color(0xFF1A1730); // Card / container surface
  static const Color surfaceHigh  = Color(0xFF242040); // Elevated surface

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color textDark     = Color(0xFFF1F5F9); // Primary text (near white)
  static const Color textMuted    = Color(0xFF94A3B8); // Secondary text
  static const Color textHint     = Color(0xFF64748B); // Hint / placeholder

  // ── Border ─────────────────────────────────────────────────────────────────
  static const Color border       = Color(0xFF2D2A45); // Subtle border

  // ── Status ─────────────────────────────────────────────────────────────────
  static const Color success      = Color(0xFF10B981);
  static const Color warning      = Color(0xFFF59E0B);
  static const Color info         = Color(0xFF3B82F6);
  static const Color error        = Color(0xFFEF4444);

  // ── Promo Banner ───────────────────────────────────────────────────────────
  static const Color promoBannerBg   = Color(0xFF0D2818);
  static const Color promoBannerText = Color(0xFF34D399);

  // ── Legacy aliases (keep for compatibility) ────────────────────────────────
  static const Color cardColor = surface;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.dark(
      primary: primary,
      secondary: primaryDark,
      surface: surface,
      error: error,
      onPrimary: Colors.white,
      onSurface: textDark,
      onSecondary: Colors.white,
    ),
    textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: const TextStyle(fontWeight: FontWeight.bold, color: textDark),
      titleLarge:   const TextStyle(fontWeight: FontWeight.w700, color: textDark),
      titleMedium:  const TextStyle(fontWeight: FontWeight.w600, color: textDark),
      bodyLarge:    const TextStyle(color: textDark),
      bodyMedium:   const TextStyle(color: textMuted),
      bodySmall:    const TextStyle(color: textMuted),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: textDark),
      titleTextStyle: GoogleFonts.dmSans(
        fontSize: 18, fontWeight: FontWeight.bold, color: textDark,
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: border, width: 1),
      ),
    ),
    dividerTheme: const DividerThemeData(color: border, thickness: 1),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textDark,
        side: const BorderSide(color: border, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceHigh,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: textHint),
      labelStyle: const TextStyle(color: textMuted),
      prefixIconColor: primary,
      suffixIconColor: textMuted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: error),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceHigh,
      contentTextStyle: const TextStyle(color: textDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: primary,
      unselectedItemColor: textMuted,
      elevation: 0,
    ),
  );
}
