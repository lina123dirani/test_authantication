import 'package:authantication/core/utils/message.dart';

/// حالة جهاز المستخدم قبل أو أثناء التحقق بالبصمة.
enum BiometricStatus {
  /// الجهاز جاهز وبصمة/وجه مسجّل.
  ready,

  /// لا يوجد hardware أو نظام قديم.
  deviceNotSupported,

  /// لا توجد بصمة أو وجه مسجّل في إعدادات الجهاز.
  notEnrolled,

  /// الجهاز يدعم البصمة لكن غير متاحة الآن (مثلاً بدون قفل شاشة).
  notAvailable,

  /// مقفلة مؤقتاً بعد محاولات فاشلة.
  locked,
}

class BiometricCheckResult {
  final BiometricStatus status;

  const BiometricCheckResult(this.status);

  bool get isReady => status == BiometricStatus.ready;

  String get message => ErrorMessages.forBiometricStatus(status);
}
