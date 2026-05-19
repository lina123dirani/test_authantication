package com.example.authantication

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        BiometricEnrollmentChannel.register(flutterEngine)
        SecurityChannel.register(flutterEngine)
    }
}
