import 'package:flutter/material.dart';
import 'package:plastik60_app/services/storage_service.dart';

class ThemeProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    _isDarkMode = await _storageService.getBool('dark_mode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _storageService.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
}
