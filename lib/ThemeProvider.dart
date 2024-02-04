import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = ThemeData.dark(); // Установка значения по умолчанию

  ThemeProvider({required bool isDarkMode}) {
    _themeData = isDarkMode ? ThemeData.dark() : ThemeData.light();
  }

  ThemeData get themeData => _themeData;

  void toggleTheme() async {
    _themeData = _themeData.brightness == Brightness.dark ? ThemeData.light() : ThemeData.dark();
    notifyListeners();
    await _saveToPrefs();
  }

  void _loadFromPrefs() {
    final isDarkMode = prefs.getBool('darkMode') ?? false;
    _themeData = isDarkMode ? ThemeData.dark() : ThemeData.light();
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _themeData.brightness == Brightness.dark);
  }
}

