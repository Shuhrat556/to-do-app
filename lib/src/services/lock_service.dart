import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LockService {
  static const _enabledKey = 'lock_enabled';
  static const _passwordKey = 'lock_password';

  SharedPreferences? _prefs;
  final Map<String, Object> _memory = {};
  File? _fallbackFile;
  bool _platformAvailable = true;

  Future<void> init() async {
    if (_prefs != null || !_platformAvailable) return;
    try {
      _prefs = await SharedPreferences.getInstance();
    } on PlatformException {
      _platformAvailable = false;
      await _loadFallback();
    }
  }

  Future<void> _loadFallback() async {
    try {
      final file = await _ensureFallbackFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        if (contents.isNotEmpty) {
          final Map<String, dynamic> decoded = json.decode(contents);
          _memory
            ..clear()
            ..addAll(decoded.map((key, value) => MapEntry(key, value)));
        }
      }
    } catch (_) {
      // ignore
    }
  }

  Future<File> _ensureFallbackFile() async {
    if (_fallbackFile != null) return _fallbackFile!;
    final dir = await getApplicationSupportDirectory();
    final file = File(path.join(dir.path, 'lock_store.json'));
    _fallbackFile = file;
    return file;
  }

  bool get isEnabled => _getBool(_enabledKey);

  Future<void> enableLock(String password) async {
    await init();
    await _setBool(_enabledKey, true);
    await _setString(_passwordKey, _hashPassword(password));
  }

  Future<void> disableLock() async {
    await init();
    await _setBool(_enabledKey, false);
    await _remove(_passwordKey);
  }

  Future<bool> validate(String password) async {
    await init();
    if (!isEnabled) return false;
    final stored = _getString(_passwordKey);
    if (stored == null) return false;
    return stored == _hashPassword(password);
  }

  bool _getBool(String key) {
    if (_prefs != null) {
      return _prefs!.getBool(key) ?? false;
    }
    return (_memory[key] as bool?) ?? false;
  }

  String? _getString(String key) {
    if (_prefs != null) {
      return _prefs!.getString(key);
    }
    return _memory[key] as String?;
  }

  Future<void> _setBool(String key, bool value) async {
    if (_prefs != null) {
      await _prefs!.setBool(key, value);
      return;
    }
    _memory[key] = value;
    await _persistFallback();
  }

  Future<void> _setString(String key, String value) async {
    if (_prefs != null) {
      await _prefs!.setString(key, value);
      return;
    }
    _memory[key] = value;
    await _persistFallback();
  }

  Future<void> _remove(String key) async {
    if (_prefs != null) {
      await _prefs!.remove(key);
      return;
    }
    _memory.remove(key);
    await _persistFallback();
  }

  Future<void> _persistFallback() async {
    try {
      final file = await _ensureFallbackFile();
      await file.writeAsString(json.encode(_memory));
    } catch (_) {
      // ignore
    }
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
}
