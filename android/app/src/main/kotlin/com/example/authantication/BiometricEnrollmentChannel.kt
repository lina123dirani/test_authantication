package com.example.authantication

import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyPermanentlyInvalidatedException
import android.security.keystore.KeyProperties
import android.security.keystore.UserNotAuthenticatedException
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey

/**
 * مفتاح Keystore يُبطل تلقائياً عند إضافة/حذف بصمة على الجهاز (Android).
 */
object BiometricEnrollmentChannel {
    private const val CHANNEL = "com.example.authantication/biometric_enrollment"
    private const val PROBE_ALIAS = "auth_biometric_enrollment_probe_v1"
    /** ثابت للتخزين فقط — الدليل الحقيقي هو مفتاح AndroidKeyStore وليس هذا النص. */
    const val KEYSTORE_BOUND_MARKER = "android_keystore_bound_v1"

    fun register(engine: FlutterEngine) {
        MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "captureEnrollmentMarker" -> {
                        installProbeKey()
                        result.success(KEYSTORE_BOUND_MARKER)
                    }
                    "isEnrollmentMarkerValid" -> {
                        val saved = call.argument<String>("savedMarker")
                        result.success(isMarkerValid(saved))
                    }
                    "clearEnrollmentProbe" -> {
                        deleteProbeKey()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("biometric_enrollment_error", e.message, null)
            }
        }
    }

    private fun installProbeKey() {
        val keyStore = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
        if (keyStore.containsAlias(PROBE_ALIAS)) {
            deleteProbeKey()
        }

        val keyGenerator = KeyGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_AES,
            "AndroidKeyStore",
        )

        val builder = KeyGenParameterSpec.Builder(
            PROBE_ALIAS,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT,
        )
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setUserAuthenticationRequired(true)
            .setInvalidatedByBiometricEnrollment(true)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            builder.setUserAuthenticationParameters(
                0,
                KeyProperties.AUTH_BIOMETRIC_STRONG,
            )
        } else {
            @Suppress("DEPRECATION")
            builder.setUserAuthenticationValidityDurationSeconds(-1)
        }

        keyGenerator.init(builder.build())
        keyGenerator.generateKey()
    }

    private fun deleteProbeKey() {
        val keyStore = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
        if (keyStore.containsAlias(PROBE_ALIAS)) {
            keyStore.deleteEntry(PROBE_ALIAS)
        }
    }

    private fun isMarkerValid(saved: String?): Boolean {
        // النص المخزّن metadata فقط — الدليل الحقيقي من Keystore وليس من قيمة الـ String.
        if (saved.isNullOrEmpty()) return false

        val keyStore = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
        if (!keyStore.containsAlias(PROBE_ALIAS)) return false

        return try {
            val secretKey = keyStore.getKey(PROBE_ALIAS, null) as SecretKey
            val transformation =
                "${KeyProperties.KEY_ALGORITHM_AES}/${KeyProperties.BLOCK_MODE_GCM}/${KeyProperties.ENCRYPTION_PADDING_NONE}"
            val cipher = Cipher.getInstance(transformation)
            cipher.init(Cipher.ENCRYPT_MODE, secretKey)
            true
        } catch (_: KeyPermanentlyInvalidatedException) {
            false
        } catch (_: UserNotAuthenticatedException) {
            // المفتاح موجود ولم يُبطَل — يحتاج مصادقة عند الاستخدام الفعلي.
            true
        } catch (_: Exception) {
            false
        }
    }
}
