/// إعدادات الشبكة — جاهزة لما يصير عندك API حقيقي.
///
/// **بدون backend اليوم:**
/// - [networkSecurityConfigXml] يمنع HTTP العادي (cleartext) على Android
/// - [pinnedHttpClientFactory] يُفعَّل لاحقاً مع Dio + بصمة الشهادة
///
/// **SSL Pinning الكامل** يحتاج:
/// 1. HTTPS API
/// 2. hash شهادة السيرفر في التطبيق
/// 3. (أفضل) تقرير Play Integrity على السيرفر مع كل طلب
class NetworkSecurity {
  NetworkSecurity._();

  /// مسار ملف Android — يُربط من AndroidManifest.
  static const String networkSecurityConfigXml =
      '@xml/network_security_config';

  /// عند ربط API: استبدل Mock بـ Dio من [createPinnedDio].
  static const bool pinningEnabled = false;

  // static Dio createPinnedDio() { ... }
}
