import 'package:authantication/core/error/exception.dart';
import 'package:authantication/core/security/runtime_threat_detector.dart';
import 'package:authantication/core/utils/message.dart';

/// بوابة أمان — تُستدعى قبل كل عملية حساسة (ليس فقط في main).
///
/// لا تمنع Frida 100% (يمكن hook هذه الدالة)، لكنها تقلل نافذة الهجوم
/// وتجبر المهاجم على hook عدة مسارات + native.
class SecurityGate {
  SecurityGate._();

  static Future<void> assertSafeRuntime() async {
    final report = await RuntimeThreatDetector.scan();
    if (report.isCompromised) {
      throw SecurityException(ErrorMessages.compromisedRuntime);
    }
  }
}
