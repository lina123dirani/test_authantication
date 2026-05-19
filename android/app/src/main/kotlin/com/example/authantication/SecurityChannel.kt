package com.example.authantication

import android.os.Build
import android.os.Debug
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * فحوصات بيئة التشغيل — لا تعتمد على isPhysicalDevice وحدها (قابلة للتزييف بـ Magisk).
 */
object SecurityChannel {
    private const val CHANNEL = "com.example.authantication/security"

    fun register(engine: FlutterEngine) {
        MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scanRuntimeThreats" -> {
                    val threats = scanRuntimeThreats()
                    result.success(
                        mapOf(
                            "isCompromised" to threats.isNotEmpty(),
                            "reasons" to threats,
                        ),
                    )
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun scanRuntimeThreats(): List<String> {
        val reasons = mutableListOf<String>()

        if (isEmulator()) reasons.add("emulator_detected")
        if (hasTestKeys()) reasons.add("test_keys_build")
        if (isDebuggerAttached()) reasons.add("debugger_attached")
        if (hasKnownRootPaths()) reasons.add("root_paths")
        if (hasFridaIndicators()) reasons.add("frida_indicators")
        if (isTracerAttached()) reasons.add("debugger_tracer")
        if (isFridaPortOpen()) reasons.add("frida_port_open")

        return reasons
    }

    private fun isTracerAttached(): Boolean {
        return try {
            val status = File("/proc/self/status").readText()
            val tracerLine = status.lineSequence().firstOrNull { it.startsWith("TracerPid:") }
            val pid = tracerLine?.substringAfter(":")?.trim()?.toIntOrNull() ?: 0
            pid != 0
        } catch (_: Exception) {
            false
        }
    }

    private fun isFridaPortOpen(): Boolean {
        return try {
            java.net.Socket().use { socket ->
                socket.connect(java.net.InetSocketAddress("127.0.0.1", 27042), 300)
                true
            }
        } catch (_: Exception) {
            false
        }
    }

    private fun isEmulator(): Boolean {
        val fingerprint = Build.FINGERPRINT.lowercase()
        val model = Build.MODEL.lowercase()
        val manufacturer = Build.MANUFACTURER.lowercase()
        val hardware = Build.HARDWARE.lowercase()
        val product = Build.PRODUCT.lowercase()
        val brand = Build.BRAND.lowercase()
        val device = Build.DEVICE.lowercase()

        if (fingerprint.contains("generic") ||
            fingerprint.contains("unknown") ||
            fingerprint.contains("emulator") ||
            fingerprint.contains("vbox") ||
            fingerprint.contains("test-keys")
        ) {
            return true
        }

        val emulatorKeywords = listOf(
            "google_sdk", "sdk", "sdk_gphone", "emulator", "android sdk built for x86",
            "genymotion", "bluestacks", "nox", "andy", "memu",
        )

        if (emulatorKeywords.any { model.contains(it) || product.contains(it) || device.contains(it) }) {
            return true
        }

        if (manufacturer.contains("genymotion") ||
            manufacturer.contains("unknown") ||
            hardware.contains("goldfish") ||
            hardware.contains("ranchu") ||
            hardware.contains("vbox") ||
            brand.startsWith("generic")
        ) {
            return true
        }

        val emulatorFiles = listOf(
            "/dev/socket/qemud",
            "/dev/qemu_pipe",
            "/system/lib/libc_malloc_debug_qemu.so",
            "/sys/qemu_trace",
            "/system/bin/qemu-props",
        )
        if (emulatorFiles.any { File(it).exists() }) return true

        return false
    }

    private fun hasTestKeys(): Boolean {
        val tags = Build.TAGS?.lowercase() ?: return false
        return tags.contains("test-keys")
    }

    private fun isDebuggerAttached(): Boolean = Debug.isDebuggerConnected()

    private fun hasKnownRootPaths(): Boolean {
        val paths = listOf(
            "/system/app/Superuser.apk",
            "/system/xbin/su",
            "/system/bin/su",
            "/sbin/su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/data/local/su",
            "/system/bin/.ext/.su",
            "/system/usr/we-need-root",
            "/system/app/Kinguser.apk",
            "/data/adb/magisk",
            "/sbin/.magisk",
        )
        return paths.any { File(it).exists() }
    }

    private fun hasFridaIndicators(): Boolean {
        val fridaPaths = listOf(
            "/data/local/tmp/frida-server",
            "/data/local/tmp/re.frida.server",
            "/sdcard/frida-server",
        )
        if (fridaPaths.any { File(it).exists() }) return true

        return try {
            val maps = File("/proc/self/maps").readText().lowercase()
            maps.contains("frida") || maps.contains("gum-js") || maps.contains("xposed")
        } catch (_: Exception) {
            false
        }
    }
}
