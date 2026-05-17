part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckSessionEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final LoginEntity request;

  const LoginEvent({required this.request});

  @override
  List<Object?> get props => [request];
}

class BiometricLoginEvent extends AuthEvent {}

class EnableBiometricEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}
