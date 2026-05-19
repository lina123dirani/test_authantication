import 'dart:io';

import 'package:authantication/core/security/device_guard.dart';
import 'package:authantication/core/security/security_platform_channel.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:jailbreak_root_detection/jailbreak_root_detection.dart';

/// تقرير فحص بيئة التشغيل — عدة إشارات، ليس فحصاً واحداً.
class RuntimeThreatReport {
  final bool isCompromised;
  final List<String> reasons;

  const RuntimeThreatReport({
    required this.isCompromised,
    required this.reasons,
  });
}

class RuntimeThreatDetector {
  RuntimeThreatDetector._();

  /// في [kDebugMode] لا نحجب التطوير — في release نفحص كل الطبقات.
  static Future<RuntimeThreatReport> scan({bool enforceInDebug = false}) async {
    if (kIsWeb) {
      return const RuntimeThreatReport(isCompromised: false, reasons: []);
    }

    if (kDebugMode && !enforceInDebug) {
      return const RuntimeThreatReport(isCompromised: false, reasons: []);
    }

    final reasons = <String>{};

    if (await DeviceGuard.isRunningOnEmulator()) {
      reasons.add('device_info_emulator');
    }

    final native = await SecurityPlatformChannel.scanRuntimeThreats();
    reasons.addAll(native.reasons);

    try {
      if (await JailbreakRootDetection.instance.isNotTrust) {
        reasons.add('jailbreak_root_not_trust');
      }
      if (!await JailbreakRootDetection.instance.isRealDevice) {
        reasons.add('not_real_device');
      }
      if (Platform.isAndroid &&
          await JailbreakRootDetection.instance.isJailBroken) {
        reasons.add('root_detected');
      }
    } catch (_) {
      // لا نوقف التطبيق إذا فشل الباكج — نعتمد على native
    }

  if (Platform.isAndroid) {
      reasons.addAll(await _androidExtraSignals());
    }

    return RuntimeThreatReport(
      isCompromised: reasons.isNotEmpty,
      reasons: reasons.toList(),
    );
  }

  static Future<List<String>> _androidExtraSignals() async {
    final extra = <String>[];
    try {
      final info = await DeviceInfoPlugin().androidInfo;
      final fingerprint = info.fingerprint.toLowerCase();
      final model = info.model.toLowerCase();

      if (fingerprint.contains('generic') ||
          fingerprint.contains('unknown') ||
          model.contains('sdk') ||
          model.contains('emulator')) {
        extra.add('android_build_emulator');
      }
    } catch (_) {}

    return extra;
  }
}
