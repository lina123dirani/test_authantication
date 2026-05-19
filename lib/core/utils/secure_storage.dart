import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// حمولة الجلسة (token + user) كـ JSON واحد.
class SessionPayload {
  final String token;
  final String userJson;

  const SessionPayload({required this.token, required this.userJson});

  Map<String, dynamic> toMap() => {
        'token': token,
        'user': jsonDecode(userJson),
      };

  factory SessionPayload.fromMap(Map<String, dynamic> map) {
    final token = map['token'];
    final user = map['user'];
    if (token is! String || user == null) {
      throw const FormatException('Invalid session payload');
    }
    return SessionPayload(
      token: token,
      userJson: jsonEncode(user),
    );
  }

  String encode() => jsonEncode(toMap());

  factory SessionPayload.decode(String raw) {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    if (_isLegacyCipherBundle(map)) {
      throw const FormatException('Legacy cipher bundle');
    }
    return SessionPayload.fromMap(map);
  }

  /// صيغة قديمة (AES iv/data) — أعد login بالإيميل.
  static bool _isLegacyCipherBundle(Map<String, dynamic> map) =>
      map.containsKey('iv') &&
      map.containsKey('data') &&
      !map.containsKey('token');
}

/// تخزين الجلسة عبر [FlutterSecureStorage] فقط:
/// - **standard**: Keystore / Keychain عبر المكتبة
/// - **biometricVault**: hardware-backed + بصمة
class SecureStorageHelper {
  final FlutterSecureStorage _standard;
  final FlutterSecureStorage _biometricVault;

  SecureStorageHelper({
    required FlutterSecureStorage standard,
    required FlutterSecureStorage biometricVault,
  })  : _standard = standard,
        _biometricVault = biometricVault;

  factory SecureStorageHelper.create() {
    return SecureStorageHelper(
      standard: const FlutterSecureStorage(
        aOptions: AndroidOptions(
          storageNamespace: 'auth_standard_vault',
        ),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.passcode,
        ),
      ),
      biometricVault: const FlutterSecureStorage(
        aOptions: AndroidOptions.biometric(
          enforceBiometrics: true,
          storageNamespace: 'auth_biometric_vault',
          biometricPromptTitle: 'فتح الجلسة المحمية',
          biometricPromptSubtitle: 'استخدم البصمة للمتابعة',
        ),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.passcode,
          accessControlFlags: [AccessControlFlag.biometryCurrentSet],
        ),
      ),
    );
  }

  static const String _sessionKey = 'session_payload';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _enrollmentMarkerKey = 'biometric_enrollment_marker';

  // ---------- Standard vault ----------

  Future<void> saveStandardSession(SessionPayload payload) =>
      _standard.write(key: _sessionKey, value: payload.encode());

  Future<SessionPayload?> readStandardSession() async {
    final raw = await _standard.read(key: _sessionKey);
    if (raw == null) return null;
    try {
      return SessionPayload.decode(raw);
    } on FormatException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> hasStandardSession() =>
      _standard.containsKey(key: _sessionKey);

  Future<void> clearStandardSession() =>
      _standard.delete(key: _sessionKey);

  // ---------- Biometric vault ----------

  Future<void> saveBiometricSession(SessionPayload payload) =>
      _biometricVault.write(key: _sessionKey, value: payload.encode());

  Future<SessionPayload?> readBiometricSession() async {
    final raw = await _biometricVault.read(key: _sessionKey);
    if (raw == null) return null;

    try {
      return SessionPayload.decode(raw);
    } on FormatException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> resetBiometricStorage() async {
    try {
      await clearBiometricSession();
    } catch (_) {}
    await clearBiometricEnrollmentMarker();
    await setBiometricEnabled(false);
  }

  Future<bool> hasBiometricSession() =>
      _biometricVault.containsKey(key: _sessionKey);

  Future<void> clearBiometricSession() =>
      _biometricVault.delete(key: _sessionKey);

  Future<void> migrateSessionToBiometricVault() async {
    final payload = await readStandardSession();
    if (payload == null) {
      throw StateError('No standard session to migrate');
    }
    await saveBiometricSession(payload);
    await clearStandardSession();
  }

  // ---------- Biometric enrollment marker ----------

  Future<void> saveBiometricEnrollmentMarker(String marker) =>
      _standard.write(key: _enrollmentMarkerKey, value: marker);

  Future<String?> readBiometricEnrollmentMarker() =>
      _standard.read(key: _enrollmentMarkerKey);

  Future<void> clearBiometricEnrollmentMarker() =>
      _standard.delete(key: _enrollmentMarkerKey);

  // ---------- Flags ----------

  Future<void> setBiometricEnabled(bool value) => _standard.write(
        key: _biometricEnabledKey,
        value: value.toString(),
      );

  Future<bool> isBiometricEnabled() async {
    final value = await _standard.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  Future<bool> hasSession() async {
    if (await isBiometricEnabled()) {
      return hasBiometricSession();
    }
    return hasStandardSession();
  }

  Future<void> clearAuthData() async {
    final biometricEnabled = await isBiometricEnabled();

    await clearStandardSession();
    await _standard.delete(key: _biometricEnabledKey);

    if (!biometricEnabled) return;

    try {
      await clearBiometricSession();
    } catch (_) {}
    await clearBiometricEnrollmentMarker();
  }
}
