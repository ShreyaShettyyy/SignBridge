import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _voiceFeedback = true;
  String _signLanguage = 'ISL';
  String _spokenLanguage = 'en-US';

  bool get isDarkMode => _isDarkMode;
  bool get voiceFeedback => _voiceFeedback;
  String get signLanguage => _signLanguage;
  String get spokenLanguage => _spokenLanguage;

  late final Future<void> initialization;

  SettingsProvider() {
    initialization = _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _voiceFeedback = prefs.getBool('voiceFeedback') ?? true;
    _signLanguage = prefs.getString('signLanguage') ?? 'ISL';
    _spokenLanguage = prefs.getString('spokenLanguage') ?? 'en-US';
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  Future<void> toggleVoiceFeedback(bool value) async {
    _voiceFeedback = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('voiceFeedback', value);
  }

  Future<void> setSignLanguage(String value) async {
    _signLanguage = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('signLanguage', value);
  }

  Future<void> setSpokenLanguage(String value) async {
    _spokenLanguage = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('spokenLanguage', value);
  }
}
