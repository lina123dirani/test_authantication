import 'package:authantication/core/theme/colors.dart';
import 'package:authantication/core/theme/styles.dart';
import 'package:flutter/material.dart';

class CompromisedDeviceApp extends StatelessWidget {
  const CompromisedDeviceApp({super.key, this.reasons = const []});

  final List<String> reasons;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.security,
                  size: 72,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'بيئة غير آمنة',
                  style: getBoldStyle(context, fontSize: 22),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Text(
                //   'لا يمكن تشغيل التطبيق على محاكي، جهاز معدّل (Root)، '
                //   'أو بيئة مشبوهة (Frida / Debug).',
                //   style: getRegularStyle(
                //     context,
                //     color: AppColors.softText,
                //   ),
                //   textAlign: TextAlign.center,
                // ),
                if (reasons.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    reasons.join(' • '),
                    style: getRegularStyle(
                      context,
                      color: AppColors.softText,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
