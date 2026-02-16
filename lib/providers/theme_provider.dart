import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return await SharedPreferences.getInstance();
});

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const String _key = 'theme_mode';

  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(_key);
    if (modeString != null) {
      state = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == modeString,
        orElse: () => ThemeMode.light,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.toString());
    state = mode;
  }
}

final themeColorProvider = StateNotifierProvider<ThemeColorNotifier, Color>((
  ref,
) {
  return ThemeColorNotifier();
});

class ThemeColorNotifier extends StateNotifier<Color> {
  static const String _key = 'theme_color';

  ThemeColorNotifier() : super(const Color(0xFF7C3AED)) {
    _loadThemeColor();
  }

  Future<void> _loadThemeColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_key);
    if (colorValue != null) {
      state = Color(colorValue);
    }
  }

  Future<void> setThemeColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, color.toARGB32());
    state = color;
  }
}

final availableColors = [
  Colors.blue,
  Colors.purple,
  Colors.indigo,
  Colors.teal,
  Colors.green,
  Colors.orange,
  Colors.pink,
  Colors.red,
];

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale?> {
  static const String _key = 'app_locale';

  LocaleNotifier() : super(null) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeString = prefs.getString(_key);
    if (localeString != null) {
      final parts = localeString.split('_');
      if (parts.length == 2) {
        state = Locale(parts[0], parts[1]);
      } else {
        state = Locale(parts[0]);
      }
    }
  }

  Future<void> setLocale(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale != null) {
      final localeString = locale.scriptCode != null
          ? '${locale.languageCode}_${locale.scriptCode}'
          : locale.countryCode != null
          ? '${locale.languageCode}_${locale.countryCode}'
          : locale.languageCode;
      await prefs.setString(_key, localeString);
    } else {
      await prefs.remove(_key);
    }
    state = locale;
  }
}

final supportedLocales = <Locale>[
  const Locale('zh'),
  const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  const Locale('en'),
  const Locale('ja'),
  const Locale('ko'),
  const Locale('fr'),
  const Locale('es'),
  const Locale('ru'),
];

final localeNames = <Locale, String>{
  const Locale('zh'): '简体中文',
  const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'): '繁體中文',
  const Locale('en'): 'English',
  const Locale('ja'): '日本語',
  const Locale('ko'): '한국어',
  const Locale('fr'): 'Français',
  const Locale('es'): 'Español',
  const Locale('ru'): 'Русский',
};
