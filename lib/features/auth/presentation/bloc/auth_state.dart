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

  @override
  List<Object?> get props => [message];
}

// ---------------------- login ------------------
class LoginLoadingState extends AuthState {}

/// إشارة نجاح فقط — البيانات الحساسة في التخزين الآمن فقط.
class LoginSuccessState extends AuthState {
  const LoginSuccessState();
}

class LoginErrorState extends AuthState {
  final String message;

  const LoginErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

// ---------------------- biometric login ------------------
class BiometricLoginLoadingState extends AuthState {}

class BiometricLoginSuccessState extends AuthState {
  const BiometricLoginSuccessState();
}

class BiometricLoginErrorState extends AuthState {
  final String message;

  const BiometricLoginErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

// ---------------------- enable biometric ------------------
class EnableBiometricLoadingState extends AuthState {}

class EnableBiometricSuccessState extends AuthState {
  const EnableBiometricSuccessState();
}

class EnableBiometricErrorState extends AuthState {
  final String message;

  const EnableBiometricErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

// ---------------------- Home (إشارة فقط — بدون توكن ولا مستخدم) ------------------
class HomeActiveState extends AuthState {
  const HomeActiveState();
}

// ---------------------- logout ------------------
class LogoutLoadingState extends AuthState {}

class LogoutSuccessState extends AuthState {}

class LogoutErrorState extends AuthState {
  final String message;

  const LogoutErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
