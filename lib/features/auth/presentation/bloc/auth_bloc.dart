import 'dart:async';

import 'package:authantication/core/utils/message.dart';
import 'package:authantication/features/auth/domain/entity/login_entity.dart';
import 'package:authantication/features/auth/domain/entity/login_response_entity.dart';
import 'package:authantication/features/auth/domain/entity/session_info_entity.dart';
import 'package:authantication/features/auth/domain/usecase/auth_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthUseCase useCase;

  SessionInfoEntity? sessionInfo;

  AuthBloc({required this.useCase}) : super(AuthInitial()) {
    on<CheckSessionEvent>(_checkSession);
    on<LoginEvent>(_login);
    on<BiometricLoginEvent>(_biometricLogin);
    on<EnableBiometricEvent>(_enableBiometric);
    on<LogoutEvent>(_logout);
  }

  FutureOr<void> _checkSession(
    CheckSessionEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(CheckSessionLoadingState());

    final result = await useCase.getSessionInfo();

    result.fold(
      (failure) {
        emit(
          CheckSessionErrorState(
            message: failure.message ?? ErrorMessages.unKnownError,
          ),
        );
      },
      (info) {
        sessionInfo = info;
        emit(CheckSessionSuccessState(sessionInfo: info));
      },
    );
  }

  FutureOr<void> _login(LoginEvent event, Emitter<AuthState> emit) async {
    emit(LoginLoadingState());

    final result = await useCase.login(event.request);

    await result.fold<Future<void>>(
      (failure) async {
        emit(
          LoginErrorState(
            message: failure.message ?? ErrorMessages.unKnownError,
          ),
        );
      },
      (success) async {
        sessionInfo = SessionInfoEntity(
          hasSession: true,
          canUseBiometric: false,
        );
        emit(LoginSuccessState(user: success));
      },
    );
  }

  FutureOr<void> _biometricLogin(
    BiometricLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(BiometricLoginLoadingState());

    final result = await useCase.loginWithBiometric();

    await result.fold<Future<void>>(
      (failure) async {
        emit(
          BiometricLoginErrorState(
            message: failure.message ?? ErrorMessages.biometricAuthFailed,
          ),
        );
      },
      (success) async {
        emit(BiometricLoginSuccessState(user: success));
      },
    );
  }

  FutureOr<void> _enableBiometric(
    EnableBiometricEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(EnableBiometricLoadingState());

    final result = await useCase.enableBiometric();

    await result.fold<Future<void>>(
      (failure) async {
        emit(
          EnableBiometricErrorState(
            message: failure.message ?? ErrorMessages.biometricAuthFailed,
          ),
        );
      },
      (_) async {
        sessionInfo = SessionInfoEntity(
          hasSession: true,
          canUseBiometric: true,
        );
        emit(const EnableBiometricSuccessState());
      },
    );
  }

  FutureOr<void> _logout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(LogoutLoadingState());

    final result = await useCase.logout();

    await result.fold<Future<void>>(
      (failure) async {
        emit(
          LogoutErrorState(
            message: failure.message ?? ErrorMessages.unKnownError,
          ),
        );
      },
      (_) async {
        sessionInfo = const SessionInfoEntity(
          hasSession: false,
          canUseBiometric: false,
        );
        emit(LogoutSuccessState());
      },
    );
  }
}
