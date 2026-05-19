import 'package:authantication/core/error/failure.dart';
import 'package:authantication/core/utils/auth_validator.dart';
import 'package:authantication/features/auth/domain/entity/login_entity.dart';
import 'package:authantication/features/auth/domain/entity/login_response_entity.dart';
import 'package:authantication/features/auth/domain/entity/session_info_entity.dart';
import 'package:authantication/features/auth/domain/entity/user_display_entity.dart';
import 'package:authantication/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class AuthUseCase {
  final AuthRepository repository;

  AuthUseCase({required this.repository});

  Future<Either<Failure, LoginResponseEntity>> login(
    LoginEntity request,
  ) async {
    final emailError = Validator.validatorEmail(request.email);
    if (emailError != null) {
      return Left(ValidationFailure(message: emailError));
    }

    final passwordError = Validator.validatorPassword(request.password);
    if (passwordError != null) {
      return Left(ValidationFailure(message: passwordError));
    }

    return repository.login(request);
  }

  Future<Either<Failure, LoginResponseEntity>> loginWithBiometric() {
    return repository.loginWithBiometric();
  }

  Future<Either<Failure, Unit>> enableBiometric() {
    return repository.enableBiometric();
  }

  Future<Either<Failure, SessionInfoEntity>> getSessionInfo() {
    return repository.getSessionInfo();
  }

  /// للعرض في Home — من التخزين الآمن؛ الاسم والبريد فقط (بدون توكن في الذاكرة طويلاً).
  Future<Either<Failure, UserDisplayEntity>> getStoredUserProfile() {
    return repository.getStoredUserProfile();
  }

  /// يمسح التخزين المحلي دائماً — بدون اعتماد على الشبكة.
  Future<void> logout() async {
    await repository.logout();
  }
}
