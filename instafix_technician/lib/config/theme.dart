import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Core Brand & Accent Colors ─────────────────────────────────────────
  static const Color primary     = Color(0xFF6C5CE7); // Deep vibrant violet
  static const Color primaryDark = Color(0xFF4834DF);
  static const Color accent      = Color(0xFF00E5FF); // Neon cyan glow
  static const Color accentGradient = Color(0xFF00B8D4);

  // ── Dark Surface Palette ────────────────────────────────────────────────
  static const Color darkBg      = Color(0xFF0A0D14);
  static const Color darkCard    = Color(0xFF131825);
  static const Color darkElevated= Color(0xFF1B2236);
  static const Color darkBorder  = Color(0xFF242C44);
  static const Color darkNav     = Color(0xFF0F1320);

  // ── Text Colors ─────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted     = Color(0xFF64748B);

  // ── Status Indicators ───────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error   = Color(0xFFEF4444); // Crimson
  static const Color info    = Color(0xFF3B82F6); // Electric Blue

  // ── Legacy Aliases ──────────────────────────────────────────────────────
  static const Color primaryLight = Color(0xFF1E1B4B);
  static const Color secondary    = Color(0xFF0F172A);
  static const Color background   = darkBg;
  static const Color surface      = darkCard;
  static const Color cardColor    = darkCard;
  static const Color border       = darkBorder;
  static const Color textDark     = textPrimary;
  static const Color darkSurface  = darkCard;

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: darkCard,
        error: error,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.inter(fontWeight: FontWeight.w800, color: textPrimary, fontSize: 32),
        titleLarge:   GoogleFonts.inter(fontWeight: FontWeight.w700, color: textPrimary, fontSize: 20),
        titleMedium:  GoogleFonts.inter(fontWeight: FontWeight.w600, color: textPrimary, fontSize: 16),
        bodyLarge:    GoogleFonts.inter(color: textPrimary, fontSize: 15),
        bodyMedium:   GoogleFonts.inter(color: textSecondary, fontSize: 13),
        labelSmall:   GoogleFonts.inter(color: textMuted, fontSize: 11, letterSpacing: 0.8),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkNav,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: primary.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: darkBorder),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: GoogleFonts.inter(color: textMuted, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: textSecondary, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: error, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkNav,
        indicatorColor: primary.withValues(alpha: 0.22),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: accent);
          }
          return GoogleFonts.inter(fontSize: 11, color: textMuted);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: accent, size: 22);
          }
          return const IconThemeData(color: textMuted, size: 22);
        }),
      ),
      dividerTheme: const DividerThemeData(color: darkBorder, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkElevated,
        contentTextStyle: GoogleFonts.inter(color: textPrimary, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Custom Gradients ────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFF4834DF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradientFill = LinearGradient(
    colors: [Color(0xFF00E5FF), Color(0xFF0099FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1B2236), Color(0xFF131825)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

