enum AppLanguage { english, russian, tajik, uzbek }

extension AppLanguageInfo on AppLanguage {
  String get storageKey => name;

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
