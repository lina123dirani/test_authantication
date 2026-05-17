import 'package:authantication/core/error/failure.dart';
import 'package:authantication/features/auth/domain/entity/login_entity.dart';
import 'package:authantication/features/auth/domain/entity/login_response_entity.dart';
import 'package:authantication/features/auth/domain/entity/session_info_entity.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, LoginResponseEntity>> login(LoginEntity request);

  Future<Either<Failure, LoginResponseEntity>> loginWithBiometric();

  Future<Either<Failure, Unit>> enableBiometric();

  Future<Either<Failure, SessionInfoEntity>> getSessionInfo();

  Future<Either<Failure, Unit>> logout();
}
