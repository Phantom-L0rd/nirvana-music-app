import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  static const _colorKey = 'accentColor';
  Color _seedColor = Colors.deepPurple;

  ThemeNotifier() {
    _loadSeedColor(); // Load on init
  }

  Color get seedColor => _seedColor;

  Future<void> _loadSeedColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_colorKey);

    if (colorValue != null) {
      _seedColor = Color(colorValue);
      notifyListeners();
    }
  }

  Future<void> setSeedColor(Color color) async {
    _seedColor = color;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_colorKey, color.value);
  }
}
