import 'package:authantication/core/theme/colors.dart';
import 'package:authantication/core/theme/styles.dart';
import 'package:authantication/core/utils/auth_validator.dart';
import 'package:authantication/core/utils/validation_messages.dart';
import 'package:authantication/features/auth/data/datasource/auth_mock_data_source.dart';
import 'package:authantication/features/auth/domain/entity/login_entity.dart';
import 'package:authantication/features/auth/domain/entity/login_response_entity.dart';
import 'package:authantication/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:authantication/features/auth/presentation/page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(
    text: AuthMockDataSource.demoEmail,
  );
  final _passwordController = TextEditingController(
    text: AuthMockDataSource.demoPassword,
  );

  bool _canUseBiometric = false;
  LoginResponseEntity? _pendingSession;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
          LoginEvent(
            request: LoginEntity(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          ),
        );
  }

  void _showEnableBiometricDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تفعيل البصمة'),
        content: const Text(
          'هل تريد استخدام البصمة لتسجيل الدخول في المرات القادمة؟',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _goHome();
            },
            child: const Text('لاحقاً'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(EnableBiometricEvent());
            },
            child: const Text('تفعيل'),
          ),
        ],
      ),
    );
  }

  void _goHome({LoginResponseEntity? session}) {
    final resolved = session ?? _pendingSession;

    if (resolved == null) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomePage(session: resolved)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is CheckSessionSuccessState) {
            setState(() {
              _canUseBiometric = state.sessionInfo.canUseBiometric;
            });
          }

          if (state is LoginSuccessState) {
            _pendingSession = state.user;
            _showEnableBiometricDialog();
          }

          if (state is BiometricLoginSuccessState) {
            _goHome(session: state.user);
          }

          if (state is EnableBiometricSuccessState) {
            setState(() => _canUseBiometric = true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم تفعيل البصمة')),
            );
            _goHome();
          }

          if (state is LoginErrorState ||
              state is BiometricLoginErrorState ||
              state is EnableBiometricErrorState) {
            final message = switch (state) {
              LoginErrorState s => s.message,
              BiometricLoginErrorState s => s.message,
              EnableBiometricErrorState s => s.message,
              _ => '',
            };
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is LoginLoadingState ||
              state is BiometricLoginLoadingState ||
              state is EnableBiometricLoadingState;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      'تسجيل الدخول',
                      style: getBoldStyle(context, fontSize: 28),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'test@test.com / 123456',
                      style: getRegularStyle(
                        context,
                        color: AppColors.softText,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) {
                        final key = Validator.validatorEmail(v);
                        return key == null
                            ? null
                            : ValidationMessages.translate(key);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'كلمة المرور',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (v) {
                        final key = Validator.validatorPassword(v);
                        return key == null
                            ? null
                            : ValidationMessages.translate(key);
                      },
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: isLoading ? null : _submitLogin,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: isLoading && state is LoginLoadingState
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'دخول',
                              style: getBoldStyle(
                                context,
                                color: AppColors.white,
                              ),
                            ),
                    ),
                    if (_canUseBiometric) ...[
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: isLoading
                            ? null
                            : () => context
                                .read<AuthBloc>()
                                .add(BiometricLoginEvent()),
                        icon: const Icon(Icons.fingerprint, size: 28),
                        label: const Text('الدخول بالبصمة'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
