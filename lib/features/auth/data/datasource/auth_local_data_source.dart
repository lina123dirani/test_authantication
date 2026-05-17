import 'dart:convert';

import 'package:authantication/core/utils/secure_storage.dart';
import 'package:authantication/features/auth/data/model/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveSession({required String token, required UserModel user});

  Future<UserModel?> getSavedUser();

  Future<void> setBiometricEnabled(bool value);

  Future<bool> isBiometricEnabled();

  Future<bool> hasSession();

  Future<void> clear();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageHelper secureStorage;

  AuthLocalDataSourceImpl(this.secureStorage);

  @override
  Future<void> saveSession({
    required String token,
    required UserModel user,
  }) async {
    await secureStorage.setToken(token);
    await secureStorage.setUserJson(jsonEncode(user.toJson()));
  }

  @override
  Future<UserModel?> getSavedUser() async {
    final raw = await secureStorage.getUserJson();
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> setBiometricEnabled(bool value) =>
      secureStorage.setBiometricEnabled(value);

  @override
  Future<bool> isBiometricEnabled() => secureStorage.isBiometricEnabled();

  @override
  Future<bool> hasSession() => secureStorage.hasSession();

  @override
  Future<void> clear() => secureStorage.clearAuthData();
}
