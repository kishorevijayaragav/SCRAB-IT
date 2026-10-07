import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyToken = 'scrapit_token';
  static const String _keyRememberEmail = 'scrapit_remember_email';
  static const String _keyCustomBaseUrl = 'scrapit_custom_base_url';

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  StorageService({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences prefs,
  })  : _secureStorage = secureStorage,
        _prefs = prefs;

  static Future<StorageService> init() async {
    const secureStorage = FlutterSecureStorage();
    final prefs = await SharedPreferences.getInstance();
    return StorageService(secureStorage: secureStorage, prefs: prefs);
  }

  // Token (secure storage with fallback)
  Future<String?> getToken() async {
    try {
      final token = await _secureStorage.read(key: _keyToken);
      if (token != null) return token;
    } catch (_) {}
    return _prefs.getString(_keyToken);
  }

  Future<void> setToken(String? token) async {
    if (token == null || token.isEmpty) {
      try {
        await _secureStorage.delete(key: _keyToken);
      } catch (_) {}
      await _prefs.remove(_keyToken);
    } else {
      try {
        await _secureStorage.write(key: _keyToken, value: token);
      } catch (_) {}
      await _prefs.setString(_keyToken, token);
    }
  }

  // Remember Email
  String? getRememberedEmail() => _prefs.getString(_keyRememberEmail);

  Future<void> setRememberedEmail(String? email) async {
    if (email == null || email.isEmpty) {
      await _prefs.remove(_keyRememberEmail);
    } else {
      await _prefs.setString(_keyRememberEmail, email);
    }
  }

  // Custom Base URL
  String? getCustomBaseUrl() => _prefs.getString(_keyCustomBaseUrl);

  Future<void> setCustomBaseUrl(String? url) async {
    if (url == null || url.trim().isEmpty) {
      await _prefs.remove(_keyCustomBaseUrl);
    } else {
      await _prefs.setString(_keyCustomBaseUrl, url.trim());
    }
  }

  Future<void> clearSession() async {
    await setToken(null);
  }
}
