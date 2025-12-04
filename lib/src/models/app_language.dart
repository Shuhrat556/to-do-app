import 'dart:ui';

enum AppLanguage { english, russian, tajik, uzbek }

extension AppLanguageInfo on AppLanguage {
  String get storageKey => name;

  String get languageCode {
    switch (this) {
      case AppLanguage.english:
        return 'en';
      case AppLanguage.russian:
        return 'ru';
      case AppLanguage.tajik:
        return 'tg';
      case AppLanguage.uzbek:
        return 'uz';
    }
  }

  Locale get locale => Locale(languageCode);

  String get displayName {
    switch (this) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.russian:
        return 'Русский';
      case AppLanguage.tajik:
        return 'Тоҷикӣ';
      case AppLanguage.uzbek:
        return 'Uzbekcha';
    }
  }
}
