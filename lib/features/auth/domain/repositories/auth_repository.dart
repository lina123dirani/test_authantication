import 'package:authantication/core/error/failure.dart';
import 'package:authantication/features/auth/domain/entity/login_entity.dart';
import 'package:authantication/features/auth/domain/entity/login_response_entity.dart';
import 'package:authantication/features/auth/domain/entity/session_info_entity.dart';
import 'package:authantication/features/auth/domain/entity/user_display_entity.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, LoginResponseEntity>> login(LoginEntity request);

  Future<Either<Failure, LoginResponseEntity>> loginWithBiometric();

  Future<Either<Failure, Unit>> enableBiometric();

  Future<Either<Failure, SessionInfoEntity>> getSessionInfo();

  /// للعرض في Home — الاسم والبريد فقط، بدون توكن في الـ API العام.
  Future<Either<Failure, UserDisplayEntity>> getStoredUserProfile();

  Future<void> logout();
}
