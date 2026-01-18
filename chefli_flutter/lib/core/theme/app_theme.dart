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

  // Light theme colors
  static const Color bgMainLight = Color(0xFFF8F7F5);
  static const Color bgSurfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF6B6B6B);

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
