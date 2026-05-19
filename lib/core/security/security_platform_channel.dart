import 'package:flutter/services.dart';

/// فحوصات native (emulator / root / frida) — لا تعتمد على حقل واحد قابل للتزييف.
class SecurityPlatformChannel {
  SecurityPlatformChannel._();
  // هاد قناة اتصال مع:Kotlin ,Swift
  static const _channel = MethodChannel('com.example.authantication/security');

  static Future<({bool isCompromised, List<String> reasons})>
  scanRuntimeThreats() async {
    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>(
        'scanRuntimeThreats',
      );
      if (result == null) {
        return (isCompromised: false, reasons: <String>[]);
      }

      final isCompromised = result['isCompromised'] == true;
      final rawReasons = result['reasons'];
      final reasons = rawReasons is List
          ? rawReasons.map((e) => e.toString()).toList()
          : <String>[];

      return (isCompromised: isCompromised, reasons: reasons);
    } on PlatformException {
      return (isCompromised: false, reasons: <String>[]);
    }
  }
}
