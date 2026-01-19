import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChefliTheme {
  // Dark theme colors
  static const Color bgMain = Color(0xFF0a0a0a);
  static const Color bgSurface = Color(0xFF181411);
  static const Color primary = Color(0xFFf48c25);
  static const Color secondary = Color(0xFF004E89);
  static const Color accent = Color(0xFF2ecc71);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA3A3A3);

  // Light theme colors - Warm cream/beige palette
  static const Color bgMainLight = Color(0xFFF5F3F0); // Warm cream background
  static const Color bgSurfaceLight = Color(0xFFFAF9F7); // Off-white cream surface
  static const Color bgCardLight = Color(0xFFFFFEFB); // Warm white for cards
  static const Color textPrimaryLight = Color(0xFF1F1F1F); // Soft dark charcoal
  static const Color textSecondaryLight = Color(0xFF6B6B6B); // Warm gray
  static const Color borderLight = Color(0xFFE8E6E3); // Light warm gray for borders
  static const Color surfaceOverlayLight = Color(0xFFF9F8F6); // Warm overlay

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgMain,
    primaryColor: primary,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: accent,
      surface: bgSurface,
      background: bgMain,
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    ),
    iconTheme: const IconThemeData(color: textPrimary),
  );

  static final ThemeData lightTheme = ThemeData.light().copyWith(
    brightness: Brightness.light,
    scaffoldBackgroundColor: bgMainLight,
    primaryColor: primary,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: accent,
      surface: bgSurfaceLight,
      background: bgMainLight,
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).apply(
      bodyColor: textPrimaryLight,
      displayColor: textPrimaryLight,
    ),
    iconTheme: const IconThemeData(color: textPrimaryLight),
  );
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFFd46b08)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
