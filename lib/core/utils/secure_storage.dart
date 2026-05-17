import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// تخزين مشفّر للـ token والجلسة وإعداد البصمة (بديل SharedPreferences).
class SecureStorageHelper {
  final FlutterSecureStorage _storage;

  SecureStorageHelper(this._storage);

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';
  static const String _biometricEnabledKey = 'biometric_enabled';

  Future<void> setToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> setUserJson(String json) =>
      _storage.write(key: _userKey, value: json);

  Future<String?> getUserJson() => _storage.read(key: _userKey);

  Future<void> setBiometricEnabled(bool value) => _storage.write(
        key: _biometricEnabledKey,
        value: value.toString(),
      );

  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  Future<bool> hasSession() async {
    final token = await getToken();
    final user = await getUserJson();
    return token != null && user != null;
  }

  Future<void> clearAuthData() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
    await _storage.delete(key: _biometricEnabledKey);
  }
}
