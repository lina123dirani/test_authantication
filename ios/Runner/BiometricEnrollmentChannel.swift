import Flutter
import LocalAuthentication
import UIKit

final class BiometricEnrollmentChannel {
  private static let channelName = "com.example.authantication/biometric_enrollment"
  private static let markerPrefix = "ios_domain:"

  static func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)

    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "captureEnrollmentMarker":
        captureEnrollmentMarker(result: result)
      case "isEnrollmentMarkerValid":
        let args = call.arguments as? [String: Any]
        let saved = args?["savedMarker"] as? String
        isEnrollmentMarkerValid(savedMarker: saved, result: result)
      case "clearEnrollmentProbe":
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private static func captureEnrollmentMarker(result: @escaping FlutterResult) {
    let context = LAContext()
    var error: NSError?

    guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
      result(
        FlutterError(
          code: "biometric_unavailable",
          message: error?.localizedDescription ?? "Biometrics unavailable",
          details: nil
        )
      )
      return
    }

    guard let domainState = context.evaluatedPolicyDomainState else {
      result(
        FlutterError(
          code: "domain_state_unavailable",
          message: "evaluatedPolicyDomainState unavailable",
          details: nil
        )
      )
      return
    }

    result("\(markerPrefix)\(domainState.base64EncodedString())")
  }

  private static func isEnrollmentMarkerValid(
    savedMarker: String?,
    result: @escaping FlutterResult
  ) {
    guard let savedMarker,
          savedMarker.hasPrefix(markerPrefix),
          let savedData = Data(
            base64Encoded: String(savedMarker.dropFirst(markerPrefix.count))
          )
    else {
      result(false)
      return
    }

    let context = LAContext()
    var error: NSError?

    guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error),
          let currentState = context.evaluatedPolicyDomainState
    else {
      result(false)
      return
    }

    result(currentState == savedData)
  }
}
