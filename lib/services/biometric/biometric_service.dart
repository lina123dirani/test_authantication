import 'package:authantication/services/biometric/biometric_status.dart';

abstract class BiometricService {
  /// فحص الجهاز قبل طلب البصمة (بدون فتح نافذة النظام).
  Future<BiometricCheckResult> checkReadiness();

  /// ينجح بدون قيمة، أو يرمي [BiometricException] برسالة واضحة.
  Future<void> authenticate({required String reason});
}
