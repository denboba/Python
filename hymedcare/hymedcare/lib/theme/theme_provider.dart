import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _darkModeKey = 'darkMode';
  static const String _useSystemThemeKey = 'useSystemTheme';
  final SharedPreferences _prefs;

  ThemeProvider(this._prefs) {
    _loadThemePreference();
  }

  bool _isDarkMode = false;
  bool _useSystemTheme = true;

  bool get isDarkMode => _isDarkMode;
  bool get useSystemTheme => _useSystemTheme;

  CupertinoThemeData get theme {
    if (_useSystemTheme) {
      // Use system theme
      return WidgetsBinding.instance.window.platformBrightness == Brightness.dark
          ? HymedCareTheme.darkTheme
          : HymedCareTheme.lightTheme;
    }
    // Use user preference
    return _isDarkMode ? HymedCareTheme.darkTheme : HymedCareTheme.lightTheme;
  }

  void _loadThemePreference() {
    _isDarkMode = _prefs.getBool(_darkModeKey) ?? false;
    _useSystemTheme = _prefs.getBool(_useSystemThemeKey) ?? true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool(_darkModeKey, _isDarkMode);
    notifyListeners();
  }

  Future<void> setUseSystemTheme(bool value) async {
    _useSystemTheme = value;
    await _prefs.setBool(_useSystemThemeKey, value);
    notifyListeners();
  }
}
