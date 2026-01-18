import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { english, hebrew }

class SettingsProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // Settings values
  bool _isDarkMode = true;
  bool _notificationsEnabled = true;
  bool _emailUpdatesEnabled = false;
  bool _autoSaveEnabled = true;
  AppLanguage _language = AppLanguage.english;

  // Getters
  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get emailUpdatesEnabled => _emailUpdatesEnabled;
  bool get autoSaveEnabled => _autoSaveEnabled;
  AppLanguage get language => _language;
  bool get isInitialized => _isInitialized;
  
  String get languageCode => _language == AppLanguage.english ? 'en' : 'he';
  String get languageName => _language == AppLanguage.english ? 'English' : 'עברית';
  TextDirection get textDirection => _language == AppLanguage.hebrew ? TextDirection.rtl : TextDirection.ltr;

  SettingsProvider() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    _isDarkMode = _prefs.getBool('isDarkMode') ?? true;
    _notificationsEnabled = _prefs.getBool('notificationsEnabled') ?? true;
    _emailUpdatesEnabled = _prefs.getBool('emailUpdatesEnabled') ?? false;
    _autoSaveEnabled = _prefs.getBool('autoSaveEnabled') ?? true;
    final langIndex = _prefs.getInt('language') ?? 0;
    _language = AppLanguage.values[langIndex];
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    await _prefs.setBool('notificationsEnabled', value);
    notifyListeners();
  }

  Future<void> setEmailUpdatesEnabled(bool value) async {
    _emailUpdatesEnabled = value;
    await _prefs.setBool('emailUpdatesEnabled', value);
    notifyListeners();
  }

  Future<void> setAutoSaveEnabled(bool value) async {
    _autoSaveEnabled = value;
    await _prefs.setBool('autoSaveEnabled', value);
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage lang) async {
    _language = lang;
    await _prefs.setInt('language', lang.index);
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    final newLang = _language == AppLanguage.english 
        ? AppLanguage.hebrew 
        : AppLanguage.english;
    await setLanguage(newLang);
  }
}




