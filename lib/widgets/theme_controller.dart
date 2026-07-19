import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class ThemeController extends ChangeNotifier {
  final AuthService _auth;
  AppUser? _user;
  ThemeMode _mode = ThemeMode.light;
  Color? _seed;

  ThemeController(this._auth) {
    load();
  }

  AppUser? get user => _user;
  ThemeMode get mode => _mode;
  Color? get seed => _seed;

  Future<void> load() async {
    _user = await _auth.currentUser();
    if (_user != null) {
      _mode = _user!.themeMode == 'dark'
          ? ThemeMode.dark
          : _user!.themeMode == 'custom'
              ? ThemeMode.system
              : ThemeMode.light;
      _seed = _user!.customColorValue != null
          ? Color(_user!.customColorValue!)
          : null;
    }
    notifyListeners();
  }

  Future<void> setMode(ThemeMode m) async {
    _mode = m;
    notifyListeners();
    await _persist();
  }

  Future<void> setSeedColor(Color c) async {
    _seed = c;
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    if (_user == null) return;
    final updated = _user!.copyWith(
      themeMode: _mode == ThemeMode.dark
          ? 'dark'
          : _mode == ThemeMode.light
              ? 'light'
              : 'custom',
      customColorValue: _seed?.value,
    );
    _user = updated;
    await _auth.update(updated);
  }

  ThemeData get lightTheme => AppTheme.light(seed: _seed);
  ThemeData get darkTheme => AppTheme.dark(seed: _seed);
}
