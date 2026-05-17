import 'package:authantication/core/theme/colors.dart';
import 'package:authantication/core/theme/styles.dart';
import 'package:authantication/features/auth/domain/entity/login_response_entity.dart';
import 'package:authantication/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:authantication/features/auth/presentation/page/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  final LoginResponseEntity session;

  const HomePage({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الرئيسية'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutEvent());
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is LogoutSuccessState) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (_) => false,
            );
          }
          if (state is LogoutErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مرحباً، ${session.user.name}',
                style: getBoldStyle(context, fontSize: 22),
              ),
              const SizedBox(height: 8),
              Text(
                session.user.email,
                style: getRegularStyle(
                  context,
                  color: AppColors.softText,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.orangeLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                // child: Text(
                //   'تم تسجيل الدخول بنجاح (Mock — بدون API)',
                //   style: getMediumStyle(context),
                // ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
