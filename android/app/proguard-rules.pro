# Flutter / local_auth
-keep class io.flutter.** { *; }
-keep class androidx.biometric.** { *; }

# Flutter deferred components — Play Core (اختياري على الجهاز، R8 يطلبها في release)
-dontwarn com.google.android.play.core.**
