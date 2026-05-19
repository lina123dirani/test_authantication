import 'package:authantication/core/error/exception.dart';
import 'package:authantication/core/utils/message.dart';
import 'package:authantication/services/biometric/biometric_service.dart';
import 'package:authantication/services/biometric/biometric_status.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

class LocalAuthBiometricService implements BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  static const _strictAuthMessages = <AuthMessages>[
    AndroidAuthMessages(
      signInTitle: 'التحقق بالبصمة',
      signInHint: 'المسّ المستشعر بالإصبع أو الوجه',
      cancelButton: 'إلغاء',
    ),
    IOSAuthMessages(
      cancelButton: 'إلغاء',
      localizedFallbackTitle: '',
    ),
  ];

  @override
  Future<BiometricCheckResult> checkReadiness() async {
    try {
      if (!await _auth.isDeviceSupported()) {
        return const BiometricCheckResult(BiometricStatus.deviceNotSupported);
      }

      final enrolledTypes = await _auth.getAvailableBiometrics();
      if (enrolledTypes.isEmpty) {
        return const BiometricCheckResult(BiometricStatus.notEnrolled);
      }

      if (!await _auth.canCheckBiometrics) {
        return const BiometricCheckResult(BiometricStatus.notAvailable);
      }

      return const BiometricCheckResult(BiometricStatus.ready);
    } on LocalAuthException catch (e) {
      return BiometricCheckResult(_statusFromException(e));
    }
  }

  @override
  Future<void> authenticate({required String reason}) async {
    final readiness = await checkReadiness();
    if (!readiness.isReady) {
      throw BiometricException(readiness.message);
    }

    try {
      final success = await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        sensitiveTransaction: true,
        authMessages: _strictAuthMessages,
      );

      if (!success) {
        final afterFail = await checkReadiness();
        if (!afterFail.isReady) {
          throw BiometricException(afterFail.message);
        }
        throw BiometricException(ErrorMessages.biometricAuthFailed);
      }
    } on LocalAuthException catch (e) {
      throw BiometricException(_messageFromException(e));
    }
  }

  BiometricStatus _statusFromException(LocalAuthException exception) {
    switch (exception.code) {
      case LocalAuthExceptionCode.noBiometricsEnrolled:
      case LocalAuthExceptionCode.noCredentialsSet:
        return BiometricStatus.notEnrolled;
      case LocalAuthExceptionCode.noBiometricHardware:
        return BiometricStatus.deviceNotSupported;
      case LocalAuthExceptionCode.temporaryLockout:
      case LocalAuthExceptionCode.biometricLockout:
        return BiometricStatus.locked;
      case LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable:
        return BiometricStatus.notAvailable;
      default:
        return BiometricStatus.notAvailable;
    }
  }

  String _messageFromException(LocalAuthException exception) {
    switch (exception.code) {
      case LocalAuthExceptionCode.userCanceled:
      case LocalAuthExceptionCode.systemCanceled:
        return ErrorMessages.biometricCancelled;
      case LocalAuthExceptionCode.noBiometricsEnrolled:
      case LocalAuthExceptionCode.noCredentialsSet:
        return ErrorMessages.biometricNotEnrolled;
      case LocalAuthExceptionCode.noBiometricHardware:
        return ErrorMessages.biometricDeviceNotSupported;
      case LocalAuthExceptionCode.uiUnavailable:
        return ErrorMessages.biometricUiUnavailable;
      case LocalAuthExceptionCode.temporaryLockout:
      case LocalAuthExceptionCode.biometricLockout:
        return ErrorMessages.biometricLocked;
      case LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable:
        return ErrorMessages.biometricNotAvailable;
      default:
        return exception.description ?? ErrorMessages.biometricAuthFailed;
    }
  }
}
