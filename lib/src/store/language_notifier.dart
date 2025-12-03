import 'package:flutter/material.dart';

import '../models/app_language.dart';
import '../services/language_service.dart';

class LanguageNotifier extends ChangeNotifier {
  final LanguageService _service;

  AppLanguage _language = AppLanguage.english;

  LanguageNotifier(this._service) {
    _initialize();
  }

  AppLanguage get current => _language;

  Future<void> _initialize() async {
    await _service.init();
    _language = _service.savedLanguage;
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    _language = language;
    notifyListeners();
    await _service.saveLanguage(language);
  }

  String translate(String key) {
    final map = _translations[_language] ?? {};
    return map[key] ?? key;
  }
}

const Map<AppLanguage, Map<String, String>> _translations = {
  AppLanguage.english: {
    'settings_title': 'Settings',
    'settings_description':
        'You can toggle reminder sounds here. Tap the switch to pick a new default for every reminder.',
    'toggle_title': 'Play reminder sound',
    'toggle_subtitle': 'Ring the alarm when a task is due',
    'toggle_info':
        'This preference affects all future reminders — change it anytime.',
    'lock_card_title': 'App lock',
    'lock_card_status_enabled': 'Enabled',
    'lock_card_status_disabled': 'Not set',
    'lock_card_description_enabled': 'Each launch requires your password.',
    'lock_card_description_disabled': 'Protect your tasks with a quick PIN.',
    'lock_card_button_primary': 'Set password',
    'lock_card_button_primary_update': 'Change password',
    'lock_card_button_secondary': 'Remove lock',
    'language_section_title': 'Interface language',
    'language_section_description':
        'English, Russian, Tajik, or Uzbek — pick the language you prefer.',
    'lock_dialog_title_new': 'App lock',
    'lock_dialog_title_update': 'Update password',
    'lock_dialog_password': 'Password',
    'lock_dialog_confirm': 'Confirm password',
    'lock_dialog_empty': 'Fill in both fields',
    'lock_dialog_mismatch': 'Passwords do not match',
    'lock_dialog_saved': 'Password saved',
    'lock_dialog_disable_title': 'Disable lock',
    'lock_dialog_disable_button': 'Remove',
    'lock_dialog_disable_success': 'Lock removed',
    'lock_dialog_disable_error': 'Incorrect password',
  },
  AppLanguage.russian: {
    'settings_title': 'Настройки',
    'settings_description':
        'Включайте или выключайте звук напоминаний здесь. Кнопка задаёт значение по умолчанию для всех новых напоминаний.',
    'toggle_title': 'Проигрывать звук напоминания',
    'toggle_subtitle': 'Сигнал прозвучит, когда задача станет просроченной',
    'toggle_info': 'Это изменение влияет на все будущие напоминания.',
    'lock_card_title': 'Блокировка',
    'lock_card_status_enabled': 'Включена',
    'lock_card_status_disabled': 'Не задана',
    'lock_card_description_enabled': 'Каждый запуск просит пароль.',
    'lock_card_description_disabled': 'Защитите задачи паролем.',
    'lock_card_button_primary': 'Установить пароль',
    'lock_card_button_primary_update': 'Изменить пароль',
    'lock_card_button_secondary': 'Снять блокировку',
    'language_section_title': 'Язык интерфейса',
    'language_section_description':
        'Выберите английский, русский, таджикский или узбекский для текста.',
    'lock_dialog_title_new': 'Блокировка',
    'lock_dialog_title_update': 'Обновить пароль',
    'lock_dialog_password': 'Пароль',
    'lock_dialog_confirm': 'Подтвердите пароль',
    'lock_dialog_empty': 'Заполните оба поля',
    'lock_dialog_mismatch': 'Пароли не совпадают',
    'lock_dialog_saved': 'Пароль сохранён',
    'lock_dialog_disable_title': 'Отключить блокировку',
    'lock_dialog_disable_button': 'Удалить',
    'lock_dialog_disable_success': 'Блокировка снята',
    'lock_dialog_disable_error': 'Неверный пароль',
  },
  AppLanguage.tajik: {
    'settings_title': 'Танзимотҳо',
    'settings_description':
        'Садои огоҳиномаҳоро ин ҷо фаъол/хомӯш кунед. Ин танзим дар тамоми огоҳиномаҳои нав татбиқ мешавад.',
    'toggle_title': 'Садо ҳангоми огоҳӣ',
    'toggle_subtitle': 'Ҳангоми расидани муҳлат сигнал бозӣ мекунад',
    'toggle_info': 'Ин танзим барои ҳамаи огоҳиномаҳои оянда амал мекунад.',
    'lock_card_title': 'Қулфи барнома',
    'lock_card_status_enabled': 'Фаъол',
    'lock_card_status_disabled': 'Мӯътабар нашудааст',
    'lock_card_description_enabled':
        'Ҳар бор кушода шудани барнома маълумоти паролӣ мехоҳад.',
    'lock_card_description_disabled': 'Барномаро бо парол ҳифз кунед.',
    'lock_card_button_primary': 'Парол гузоред',
    'lock_card_button_primary_update': 'Паролро навсозӣ кунед',
    'lock_card_button_secondary': 'Қулфро нест кунед',
    'language_section_title': 'Забони интерфейс',
    'language_section_description':
        'Англисӣ, русӣ, тоҷикӣ ё ӯзбекӣ — забони маъмулро интихоб кунед.',
    'lock_dialog_title_new': 'Қулфи барнома',
    'lock_dialog_title_update': 'Паролро навсозӣ кунед',
    'lock_dialog_password': 'Парол',
    'lock_dialog_confirm': 'Паролро тасдиқ кунед',
    'lock_dialog_empty': 'Ҳар ду майдонро пур кунед',
    'lock_dialog_mismatch': 'Паролҳо мувофиқат надоранд',
    'lock_dialog_saved': 'Парол сабт шуд',
    'lock_dialog_disable_title': 'Қулфро бекор кунед',
    'lock_dialog_disable_button': 'Нест кунед',
    'lock_dialog_disable_success': 'Қулф бекор шуд',
    'lock_dialog_disable_error': 'Парол нодуруст аст',
  },
  AppLanguage.uzbek: {
    'settings_title': 'Sozlamalar',
    'settings_description':
        "Bu yerda eslatma tovushini yoqib/o‘chirishingiz mumkin. Har bir yangi eslatma uchun tanlangan holat saqlanadi.",
    'toggle_title': 'Eslatma tovushini yoqing',
    'toggle_subtitle': 'Vazifa muddati kelganda signal yangraydi',
    'toggle_info': 'Bu sozlama barcha keyingi eslatmalarga taalluqli bo‘ladi.',
    'lock_card_title': 'Ilova qulfi',
    'lock_card_status_enabled': 'Faol',
    'lock_card_status_disabled': 'Belgilanmagan',
    'lock_card_description_enabled':
        'Har safar ilovaga kirish parolni talab qiladi.',
    'lock_card_description_disabled': 'Vazifalarni parol bilan himoya qiling.',
    'lock_card_button_primary': 'Parol o‘rnating',
    'lock_card_button_primary_update': 'Parolni yangilang',
    'lock_card_button_secondary': 'Qulfni olib tashlash',
    'language_section_title': 'Interfeys tili',
    'language_section_description':
        'Matnlarni ingliz, rus, tojik yoki o‘zbek tillarida ko‘ring.',
    'lock_dialog_title_new': 'Ilova qulfi',
    'lock_dialog_title_update': 'Parolni yangilang',
    'lock_dialog_password': 'Parol',
    'lock_dialog_confirm': 'Parolni tasdiqlang',
    'lock_dialog_empty': 'Ikkala maydonni to‘ldiring',
    'lock_dialog_mismatch': 'Parollar mos emas',
    'lock_dialog_saved': 'Parol saqlandi',
    'lock_dialog_disable_title': 'Qulfni o‘chirish',
    'lock_dialog_disable_button': 'O‘chirish',
    'lock_dialog_disable_success': 'Qulf pasaytirildi',
    'lock_dialog_disable_error': 'Parol noto‘g‘ri',
  },
};
