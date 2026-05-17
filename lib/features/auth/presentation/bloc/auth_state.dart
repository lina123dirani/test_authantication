part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

// ---------------------- check session ------------------
class CheckSessionLoadingState extends AuthState {}

class CheckSessionSuccessState extends AuthState {
  final SessionInfoEntity sessionInfo;

  const CheckSessionSuccessState({required this.sessionInfo});

  @override
  List<Object?> get props => [sessionInfo];
}

class CheckSessionErrorState extends AuthState {
  final String message;

  const CheckSessionErrorState({required this.message});
}

// ---------------------- login ------------------
class LoginLoadingState extends AuthState {}

class LoginSuccessState extends AuthState {
  final LoginResponseEntity user;

  const LoginSuccessState({required this.user});

  @override
  List<Object?> get props => [user];
}

class LoginErrorState extends AuthState {
  final String message;

  const LoginErrorState({required this.message});
}

// ---------------------- biometric login ------------------
class BiometricLoginLoadingState extends AuthState {}

class BiometricLoginSuccessState extends AuthState {
  final LoginResponseEntity user;

  const BiometricLoginSuccessState({required this.user});
}

class BiometricLoginErrorState extends AuthState {
  final String message;

  const BiometricLoginErrorState({required this.message});
}

// ---------------------- enable biometric ------------------
class EnableBiometricLoadingState extends AuthState {}

class EnableBiometricSuccessState extends AuthState {
  const EnableBiometricSuccessState();
}

class EnableBiometricErrorState extends AuthState {
  final String message;

  const EnableBiometricErrorState({required this.message});
}

// ---------------------- logout ------------------
class LogoutLoadingState extends AuthState {}

class LogoutSuccessState extends AuthState {}

class LogoutErrorState extends AuthState {
  final String message;

  const LogoutErrorState({required this.message});
}
