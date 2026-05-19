import 'package:authantication/core/di/injection.dart';
import 'package:authantication/core/security/runtime_threat_detector.dart';
import 'package:authantication/core/theme/colors.dart';
import 'package:authantication/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:authantication/features/auth/presentation/page/compromised_device_page.dart';
import 'package:authantication/features/auth/presentation/page/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final threatReport = await RuntimeThreatDetector.scan();
  if (threatReport.isCompromised) {
    runApp(CompromisedDeviceApp(reasons: threatReport.reasons));
    return;
  }

  await configureDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>()..add(CheckSessionEvent()),
      child: MaterialApp(
        title: 'Authentication',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          useMaterial3: true,
        ),
        home: const LoginPage(),
      ),
    );
  }
}
