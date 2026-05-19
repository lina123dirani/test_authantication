import 'package:authantication/core/di/injection.dart';
import 'package:authantication/core/theme/colors.dart';
import 'package:authantication/core/theme/styles.dart';
import 'package:authantication/core/utils/message.dart';
import 'package:authantication/features/auth/domain/entity/user_display_entity.dart';
import 'package:authantication/features/auth/domain/usecase/auth_usecase.dart';
import 'package:authantication/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:authantication/features/auth/presentation/page/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthUseCase _useCase = getIt<AuthUseCase>();

  AuthBloc? _authBloc;
  bool _didEnterHome = false;
  bool _skipLeaveHomeOnDispose = false;

  UserDisplayEntity? _profile;
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authBloc ??= context.read<AuthBloc>();
    if (!_didEnterHome) {
      _didEnterHome = true;
      _authBloc!.add(EnterHomeEvent());
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final result = await _useCase.getStoredUserProfile();
    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              failure.message ?? ErrorMessages.noSavedSession;
        });
      },
      (profile) {
        setState(() {
          _isLoading = false;
          _profile = profile;
        });
      },
    );
  }

  void _clearLocalProfile() {
    _profile = null;
    _errorMessage = null;
  }

  @override
  void dispose() {
    _clearLocalProfile();
    if (!_skipLeaveHomeOnDispose) {
      _authBloc?.add(LeaveHomeEvent());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LogoutSuccessState) {
          _clearLocalProfile();
          _skipLeaveHomeOnDispose = true;
          _authBloc?.add(LeaveHomeEvent());
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (_) => false,
          );
        }
      },
      builder: (context, state) {
        if (_isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (_errorMessage != null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final profile = _profile;
        if (profile == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('الرئيسية'),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            actions: [
              IconButton(
                onPressed: state is LogoutLoadingState
                    ? null
                    : () => _authBloc?.add(LogoutEvent()),
                icon: state is LogoutLoadingState
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.logout),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً، ${profile.name}',
                  style: getBoldStyle(context, fontSize: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  profile.email,
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
                  child: Text(
                    'تم تسجيل الدخول بنجاح',
                    style: getMediumStyle(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
