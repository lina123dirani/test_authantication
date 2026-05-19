import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// يمنع تشغيل التطبيق على محاكي (Emulator / Simulator).
class DeviceGuard {
  DeviceGuard._();

  static Future<bool> isRunningOnEmulator() async {
    if (kIsWeb) return false;

    final plugin = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        final info = await plugin.androidInfo;
        return !info.isPhysicalDevice;
      }

      if (Platform.isIOS) {
        final info = await plugin.iosInfo;
        return !info.isPhysicalDevice;
      }
    } catch (_) {
      return false;
    }

    return false;
  }
}
