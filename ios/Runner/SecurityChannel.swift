import Flutter
import UIKit

final class SecurityChannel {
  private static let channelName = "com.example.authantication/security"

  static func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)

    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "scanRuntimeThreats":
        let threats = scanRuntimeThreats()
        result([
          "isCompromised": !threats.isEmpty,
          "reasons": threats,
        ])
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private static func scanRuntimeThreats() -> [String] {
    var reasons: [String] = []

    #if targetEnvironment(simulator)
    reasons.append("simulator_detected")
    #endif

    if isJailbroken() {
      reasons.append("jailbreak_detected")
    }

    return reasons
  }

  private static func isJailbroken() -> Bool {
    let paths = [
      "/Applications/Cydia.app",
      "/Library/MobileSubstrate/MobileSubstrate.dylib",
      "/bin/bash",
      "/usr/sbin/sshd",
      "/etc/apt",
      "/private/var/lib/apt/",
    ]

    for path in paths where FileManager.default.fileExists(atPath: path) {
      return true
    }

    let testPath = "/private/jailbreak_test_\(UUID().uuidString)"
    do {
      try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
      try FileManager.default.removeItem(atPath: testPath)
      return true
    } catch {
      return false
    }
  }
}
