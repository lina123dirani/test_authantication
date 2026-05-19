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

/// إشارة أن Home مفتوح — البيانات الحساسة تُقرأ في Home من التخزين الآمن فقط.
class EnterHomeEvent extends AuthEvent {}

/// مغادرة Home — إعادة الـ Bloc لحالة أولية (التخزين الآمن يبقى حتى logout).
class LeaveHomeEvent extends AuthEvent {}
