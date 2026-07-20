import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String _storageKeyUserId = 'user_id';
  static const String _storageKeyNickname = 'nickname';
  static const String _storageKeyToken = 'token';
  static const String _storageKeySystemUserId = 'system_user_id';

  static Future<String> getSystemUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString(_storageKeySystemUserId);
    if (id == null || id.isEmpty) {
      id = _generateUuid();
      await prefs.setString(_storageKeySystemUserId, id);
    }
    return id;
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_storageKeyToken) != null;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_storageKeyToken);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_storageKeyUserId);
  }

  static Future<String?> getNickname() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_storageKeyNickname);
  }

  static Future<void> login({
    required String userId,
    required String nickname,
    required String token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKeyUserId, userId);
    await prefs.setString(_storageKeyNickname, nickname);
    await prefs.setString(_storageKeyToken, token);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKeyUserId);
    await prefs.remove(_storageKeyNickname);
    await prefs.remove(_storageKeyToken);
  }

  static String _generateUuid() {
    return '${DateTime.now().millisecondsSinceEpoch}-${Random.secure().nextInt(999999)}';
  }
}
