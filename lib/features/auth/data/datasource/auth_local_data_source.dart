import 'dart:convert';

import 'package:authantication/core/error/exception.dart';
import 'package:authantication/core/utils/message.dart';
import 'package:authantication/core/utils/secure_storage.dart';
import 'package:authantication/features/auth/data/model/user_model.dart';
import 'package:authantication/services/biometric/biometric_enrollment_marker.dart';
import 'package:flutter/services.dart';

abstract class AuthLocalDataSource {
  Future<void> saveSession({required String token, required UserModel user});

  Future<({UserModel user, String token})?> readBiometricProtectedSession();

  /// قراءة الجلسة من التخزين الآمن (standard أو biometric حسب الإعداد).
  Future<({UserModel user, String token})?> readStoredSession();

  Future<void> migrateSessionToBiometricVault();

  Future<void> installBiometricEnrollmentMarker();

  Future<bool> hasBiometricEnrollmentChanged();

  Future<void> setBiometricEnabled(bool value);

  Future<bool> isBiometricEnabled();

  Future<bool> hasSession();

  Future<void> clear();

  Future<void> resetBiometricAfterCorruptStorage();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageHelper secureStorage;
  final BiometricEnrollmentMarker enrollmentMarker;

  AuthLocalDataSourceImpl(this.secureStorage, this.enrollmentMarker);

  @override
  Future<void> saveSession({
    required String token,
    required UserModel user,
  }) async {
    await secureStorage.saveStandardSession(
      SessionPayload(
        token: token,
        userJson: jsonEncode(user.toJson()),
      ),
    );
  }

  @override
  Future<({UserModel user, String token})?> readBiometricProtectedSession() async {
    try {
      final payload = await secureStorage.readBiometricSession();
      if (payload == null) return null;

      final user = UserModel.fromJson(
        jsonDecode(payload.userJson) as Map<String, dynamic>,
      );
      return (user: user, token: payload.token);
    } on PlatformException catch (e) {
      if (_isEnrollmentInvalidated(e)) {
        await clear();
        throw BiometricException(ErrorMessages.biometricEnrollmentChanged);
      }
      throw BiometricException(_mapPlatformException(e));
    }
  }

  @override
  Future<({UserModel user, String token})?> readStoredSession() async {
    if (await isBiometricEnabled()) {
      return readBiometricProtectedSession();
    }

    final payload = await secureStorage.readStandardSession();
    if (payload == null) return null;

    final user = UserModel.fromJson(
      jsonDecode(payload.userJson) as Map<String, dynamic>,
    );
    return (user: user, token: payload.token);
  }

  @override
  Future<void> migrateSessionToBiometricVault() async {
    try {
      await secureStorage.migrateSessionToBiometricVault();
    } on PlatformException catch (e) {
      if (_isEnrollmentInvalidated(e)) {
        await clear();
        throw BiometricException(ErrorMessages.biometricEnrollmentChanged);
      }
      throw BiometricException(_mapPlatformException(e));
    } on StateError {
      throw CacheException(ErrorMessages.noSavedSession);
    }
  }

  @override
  Future<void> installBiometricEnrollmentMarker() async {
    final marker = await enrollmentMarker.captureEnrollmentMarker();
    await secureStorage.saveBiometricEnrollmentMarker(marker);
  }

  @override
  Future<bool> hasBiometricEnrollmentChanged() async {
    if (!await isBiometricEnabled()) return false;

    final saved = await secureStorage.readBiometricEnrollmentMarker();
    final hasBioSession = await secureStorage.hasBiometricSession();

    if ((saved == null || saved.isEmpty) && hasBioSession) {
      // ترقية أو marker ناقص — أعد التثبيت بدل مسح الجلسة.
      await installBiometricEnrollmentMarker();
      return false;
    }

    if (saved == null || saved.isEmpty) return true;

    final valid = await enrollmentMarker.isEnrollmentMarkerValid(saved);
    if (!valid && hasBioSession) {
      // marker قديم بصيغة سابقة — جرّب إصلاحاً قبل اعتبار التغيّر فعلياً.
      await installBiometricEnrollmentMarker();
      final repaired = await enrollmentMarker.isEnrollmentMarkerValid(
        await secureStorage.readBiometricEnrollmentMarker(),
      );
      if (repaired) return false;
    }

    return !valid;
  }

  bool _isEnrollmentInvalidated(PlatformException e) {
    final code = e.code.toLowerCase();
    final message = (e.message ?? '').toLowerCase();

    return code.contains('invalidat') ||
        code.contains('key_permanently_invalidated') ||
        message.contains('invalidat') ||
        message.contains('biometric enrollment') ||
        message.contains('biometry changed');
  }

  String _mapPlatformException(PlatformException e) {
    if (_isEnrollmentInvalidated(e)) {
      return ErrorMessages.biometricEnrollmentChanged;
    }

    final code = e.code.toLowerCase();
    final message = (e.message ?? '').toLowerCase();

    if (code.contains('cancel') || message.contains('cancel')) {
      return ErrorMessages.biometricCancelled;
    }
    if (message.contains('not available') ||
        message.contains('not enrolled') ||
        code.contains('not_available')) {
      return ErrorMessages.biometricNotEnrolled;
    }
    if (message.contains('lockout') || code.contains('lockout')) {
      return ErrorMessages.biometricLocked;
    }
    return ErrorMessages.biometricAuthFailed;
  }

  @override
  Future<void> setBiometricEnabled(bool value) =>
      secureStorage.setBiometricEnabled(value);

  @override
  Future<bool> isBiometricEnabled() => secureStorage.isBiometricEnabled();

  @override
  Future<bool> hasSession() => secureStorage.hasSession();

  @override
  Future<void> clear() async {
    final hadBiometric = await isBiometricEnabled();
    await secureStorage.clearAuthData();
    if (hadBiometric) {
      await enrollmentMarker.clearEnrollmentProbe();
    }
  }

  @override
  Future<void> resetBiometricAfterCorruptStorage() async {
    await enrollmentMarker.clearEnrollmentProbe();
    await secureStorage.resetBiometricStorage();
  }
}
