import 'package:authantication/core/error/failure.dart';
import 'package:authantication/core/utils/auth_validator.dart';
import 'package:authantication/features/auth/domain/entity/login_entity.dart';
import 'package:authantication/features/auth/domain/entity/login_response_entity.dart';
import 'package:authantication/features/auth/domain/entity/session_info_entity.dart';
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

  Future<Either<Failure, Unit>> logout() {
    return repository.logout();
  }
}
