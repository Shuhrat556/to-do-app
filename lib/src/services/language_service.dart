import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_language.dart';

class LanguageService {
  static const _languageKey = 'app_language';

  SharedPreferences? _prefs;
  bool _platformAvailable = true;

  Future<void> init() async {
    if (_prefs != null || !_platformAvailable) return;
    try {
      _prefs = await SharedPreferences.getInstance();
    } on PlatformException {
      _platformAvailable = false;
    }
  }

  AppLanguage get savedLanguage {
    if (_prefs != null) {
      final raw = _prefs!.getString(_languageKey);
      if (raw != null) {
        return AppLanguage.values.firstWhere(
          (lang) => lang.storageKey == raw,
          orElse: () => AppLanguage.english,
        );
      }
    }
    return AppLanguage.english;
  }

  Future<void> saveLanguage(AppLanguage language) async {
    await init();
    if (_prefs != null) {
      await _prefs!.setString(_languageKey, language.storageKey);
    }
  }
}
