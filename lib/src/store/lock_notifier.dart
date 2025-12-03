import 'package:flutter/material.dart';

import '../services/lock_service.dart';

class LockNotifier extends ChangeNotifier {
  final LockService _service;

  bool _lockEnabled = false;
  bool _authenticated = false;

  LockNotifier(this._service) {
    _initialize();
  }

  bool get lockEnabled => _lockEnabled;
  bool get isAuthenticated => _authenticated;

  Future<void> _initialize() async {
    await _service.init();
    _lockEnabled = _service.isEnabled;
    _authenticated = !_lockEnabled;
    notifyListeners();
  }

  Future<bool> authenticate(String password) async {
    final valid = await _service.validate(password);
    if (valid) {
      _authenticated = true;
      notifyListeners();
    }
    return valid;
  }

  void resetAuthentication() {
    if (!_lockEnabled) return;
    _authenticated = false;
    notifyListeners();
  }

  Future<void> enableLock(String password) async {
    await _service.enableLock(password);
    _lockEnabled = true;
    _authenticated = true;
    notifyListeners();
  }

  Future<bool> disableLock(String password) async {
    final valid = await _service.validate(password);
    if (!valid) return false;
    await _service.disableLock();
    _lockEnabled = false;
    _authenticated = true;
    notifyListeners();
    return true;
  }
}
