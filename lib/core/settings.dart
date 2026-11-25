import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final preferencesProvider = Provider<SharedPreferences>(
  (ref) => throw StateError('Preferences not initialized'),
);

class Settings {
  const Settings({this.language, this.theme = ThemeMode.system});
  final String? language;
  final ThemeMode theme;
}

class SettingsController extends Notifier<Settings> {
  @override
  Settings build() {
    final p = ref.read(preferencesProvider);
    final saved = p.getString('theme');
    return Settings(
      language: p.getString('language'),
      theme: ThemeMode.values.firstWhere(
        (t) => t.name == saved,
        orElse: () => ThemeMode.system,
      ),
    );
  }

  Future<void> setLanguage(String? code) async {
    final p = ref.read(preferencesProvider);
    if (code == null) {
      await p.remove('language');
    } else {
      await p.setString('language', code);
    }
    state = Settings(language: code, theme: state.theme);
  }

  Future<void> setTheme(ThemeMode theme) async {
    await ref.read(preferencesProvider).setString('theme', theme.name);
    state = Settings(language: state.language, theme: theme);
  }
}

final settingsProvider = NotifierProvider<SettingsController, Settings>(
  SettingsController.new,
);
