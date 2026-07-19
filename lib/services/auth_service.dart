import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';

class AuthService {
  static const _kUser = 'current_user';

  Future<AppUser?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUser);
    if (raw == null) return null;
    return AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<AppUser> register({
    required String username,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final user = AppUser(
      id: const Uuid().v4(),
      username: username,
      email: email,
      createdAt: DateTime.now(),
    );
    await prefs.setString(_kUser, jsonEncode(user.toJson()));
    return user;
  }

  Future<void> update(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUser, jsonEncode(user.toJson()));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUser);
  }
}
