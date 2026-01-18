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
  
  // Helper for white/black based on theme
  Color get onSurface => Theme.of(this).brightness == Brightness.dark 
      ? Colors.white 
      : Colors.black;
  
  Color get onSurfaceSecondary => Theme.of(this).brightness == Brightness.dark 
      ? Colors.white.withOpacity(0.5) 
      : Colors.black.withOpacity(0.5);
  
  Color get surfaceOverlay => Theme.of(this).brightness == Brightness.dark 
      ? Colors.white.withOpacity(0.1) 
      : Colors.black.withOpacity(0.05);
}




