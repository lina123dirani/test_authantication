import 'package:authantication/core/theme/colors.dart';
import 'package:authantication/core/theme/styles.dart';
import 'package:flutter/material.dart';

class EmulatorBlockedApp extends StatelessWidget {
  const EmulatorBlockedApp({super.key});

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
                  'غير مسموح على المحاكي',
                  style: getBoldStyle(context, fontSize: 22),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'لأسباب أمنية، هذا التطبيق يعمل على جهاز حقيقي فقط.',
                  style: getRegularStyle(
                    context,
                    color: AppColors.softText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
