import 'package:flutter/services.dart';

/// كشف تغيّر مجموعة البصمات — الدليل من النظام وليس من نص عادي.
///
/// - Android: مفتاح [AndroidKeyStore] + [setInvalidatedByBiometricEnrollment]
/// - iOS: [evaluatedPolicyDomainState] (بصمة مجموعة البصمات)
abstract class BiometricEnrollmentMarker {
  Future<String> captureEnrollmentMarker();

  Future<bool> isEnrollmentMarkerValid(String? savedMarker);

  Future<void> clearEnrollmentProbe();
}

class PlatformBiometricEnrollmentMarker implements BiometricEnrollmentMarker {
  static const _channel = MethodChannel(
    'com.example.authantication/biometric_enrollment',
  );

  /// Android — ثابت؛ التحقق الحقيقي في Keystore.
  static const androidKeystoreBoundMarker = 'android_keystore_bound_v1';

  /// iOS — بادئة + domain state مشفّر base64 (دليل تشفيري).
  static const iosDomainPrefix = 'ios_domain:';

  @override
  Future<String> captureEnrollmentMarker() async {
    final marker = await _channel.invokeMethod<String>('captureEnrollmentMarker');
    if (!_isCryptographicMarker(marker)) {
      throw PlatformException(
        code: 'invalid_marker',
        message: 'Enrollment marker is not keystore-bound',
      );
    }
    return marker!;
  }

  @override
  Future<bool> isEnrollmentMarkerValid(String? savedMarker) async {
    if (!_isCryptographicMarker(savedMarker)) return false;

    final valid = await _channel.invokeMethod<bool>(
      'isEnrollmentMarkerValid',
      {'savedMarker': savedMarker},
    );
    return valid ?? false;
  }

  @override
  Future<void> clearEnrollmentProbe() async {
    await _channel.invokeMethod<void>('clearEnrollmentProbe');
  }

  /// يرفض أي marker فارغ أو نص عادي غير مربوط بالنظام.
  static bool _isCryptographicMarker(String? marker) {
    if (marker == null || marker.isEmpty) return false;
    if (marker == androidKeystoreBoundMarker) return true;
    if (marker.startsWith('android_keystore:')) return true;
    if (!marker.startsWith(iosDomainPrefix)) return false;
    final payload = marker.substring(iosDomainPrefix.length);
    return payload.isNotEmpty && payload.length >= 16;
  }
}
