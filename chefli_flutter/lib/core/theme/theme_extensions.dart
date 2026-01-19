import 'package:flutter/material.dart';
import 'app_theme.dart';

extension ThemeExtension on BuildContext {
  // Background colors
  Color get bgMain => Theme.of(this).brightness == Brightness.dark 
      ? ChefliTheme.bgMain 
      : ChefliTheme.bgMainLight;
  
  Color get bgSurface => Theme.of(this).brightness == Brightness.dark 
      ? ChefliTheme.bgSurface 
      : ChefliTheme.bgSurfaceLight;
  
  // Text colors
  Color get textPrimary => Theme.of(this).brightness == Brightness.dark 
      ? ChefliTheme.textPrimary 
      : ChefliTheme.textPrimaryLight;
  
  Color get textSecondary => Theme.of(this).brightness == Brightness.dark 
      ? ChefliTheme.textSecondary 
      : ChefliTheme.textSecondaryLight;
  
  // Card/Container background
  Color get bgCard => Theme.of(this).brightness == Brightness.dark 
      ? ChefliTheme.bgSurface 
      : ChefliTheme.bgCardLight;
  
  // Border colors
  Color get borderColor => Theme.of(this).brightness == Brightness.dark 
      ? Colors.white.withOpacity(0.1) 
      : ChefliTheme.borderLight;
  
  // Helper for white/black based on theme
  Color get onSurface => Theme.of(this).brightness == Brightness.dark 
      ? Colors.white 
      : ChefliTheme.textPrimaryLight;
  
  Color get onSurfaceSecondary => Theme.of(this).brightness == Brightness.dark 
      ? Colors.white.withOpacity(0.5) 
      : ChefliTheme.textSecondaryLight;
  
  Color get surfaceOverlay => Theme.of(this).brightness == Brightness.dark 
      ? Colors.white.withOpacity(0.1) 
      : ChefliTheme.surfaceOverlayLight;
  
  // Convenience helper for checking theme
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  
  // Card overlay color (subtle background for cards)
  Color get cardOverlay => Theme.of(this).brightness == Brightness.dark 
      ? Colors.white.withOpacity(0.05)
      : Colors.black.withOpacity(0.03);
  
  // Card border color
  Color get cardBorder => Theme.of(this).brightness == Brightness.dark 
      ? Colors.white.withOpacity(0.05)
      : ChefliTheme.borderLight;
  
  // Checkbox/input border color
  Color get inputBorder => Theme.of(this).brightness == Brightness.dark 
      ? Colors.white.withOpacity(0.2)
      : ChefliTheme.borderLight;
  
  // Muted text (for hints, placeholders)
  Color get textMuted => Theme.of(this).brightness == Brightness.dark 
      ? Colors.white.withOpacity(0.6)
      : ChefliTheme.textSecondaryLight;
}




