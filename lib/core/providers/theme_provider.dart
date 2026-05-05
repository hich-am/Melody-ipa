import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  bool get isDarkMode => AppColors.isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? true;
    AppColors.isDarkMode = isDark;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    AppColors.isDarkMode = !AppColors.isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', AppColors.isDarkMode);
    notifyListeners();
  }
}
