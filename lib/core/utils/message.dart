import 'package:authantication/services/biometric/biometric_status.dart';

class ErrorMessages {
  ErrorMessages._();

  static const String unKnownError = 'حدث خطأ غير متوقع';
  static const String generalError = 'حدث خطأ، حاول مرة أخرى';
  static const String networkError = 'تحقق من اتصال الإنترنت';
  static const String invalidCredentials = 'إيميل أو كلمة مرور خاطئة';
  static const String noSavedSession =
      'سجّل دخول بالإيميل أولاً لتفعيل البصمة';
  static const String biometricNotEnabled =
      'فعّل خيار الدخول بالبصمة من التطبيق أولاً';

  // ---------- Biometric (مركّزة وواضحة) ----------
  static const String biometricDeviceNotSupported =
      'جهازك لا يدعم التحقق بالبصمة';

  static const String biometricNotEnrolled =
      'البصمة غير مفعّلة على هاتفك. من الإعدادات > الأمان فعّلي بصمة الإصبع أو التعرف على الوجه ثم حاولي مجدداً';

  static const String biometricNotAvailable =
      'التحقق بالبصمة غير متاح حالياً. تأكدي من تفعيل قفل الشاشة (PIN أو نمط)';

  static const String biometricAuthFailed =
      'لم يتم التحقق بالبصمة. حاولي مرة أخرى';

  static const String biometricCancelled =
      'ألغيتِ عملية التحقق بالبصمة';

  static const String biometricUiUnavailable =
      'تعذر فتح نافذة البصمة. أوقفي التطبيق وشغّليه من جديد';

  static const String biometricLocked =
      'البصمة مقفلة مؤقتاً بسبب محاولات خاطئة. انتظري قليلاً أو استخدمي قفل الشاشة';

  static String forBiometricStatus(BiometricStatus status) {
    switch (status) {
      case BiometricStatus.ready:
        return '';
      case BiometricStatus.deviceNotSupported:
        return biometricDeviceNotSupported;
      case BiometricStatus.notEnrolled:
        return biometricNotEnrolled;
      case BiometricStatus.notAvailable:
        return biometricNotAvailable;
      case BiometricStatus.locked:
        return biometricLocked;
    }
  }
}
