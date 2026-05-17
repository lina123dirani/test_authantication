import 'package:authantication/core/error/exception.dart';
import 'package:authantication/core/error/failure.dart';
import 'package:authantication/core/utils/message.dart';
import 'package:authantication/features/auth/data/datasource/auth_local_data_source.dart';
import 'package:authantication/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:authantication/features/auth/domain/entity/login_entity.dart';
import 'package:authantication/features/auth/domain/entity/login_response_entity.dart';
import 'package:authantication/features/auth/domain/entity/session_info_entity.dart';
import 'package:authantication/features/auth/domain/repositories/auth_repository.dart';
import 'package:authantication/services/biometric/biometric_service.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;
  final BiometricService biometricService;

  AuthRepositoryImpl({
    required this.remote,
    required this.local,
    required this.biometricService,
  });

  /// يشغّل التحقق بالبصمة ويرجع Either برسالة عربية واضحة.
  Future<Either<Failure, Unit>> _runBiometricGate(String reason) async {
    try {
      await biometricService.authenticate(reason: reason);
      return const Right(unit);
    } on BiometricException catch (e) {
      return Left(BiometricFailure(message: e.message));
    } catch (_) {
      return const Left(
        BiometricFailure(message: ErrorMessages.generalError),
      );
    }
  }

  @override
  Future<Either<Failure, LoginResponseEntity>> login(
    LoginEntity request,
  ) async {
    try {
      final user = await remote.login(
        email: request.email,
        password: request.password,
      );

      const token = 'mock_token';
      await local.saveSession(token: token, user: user);

      return Right(
        LoginResponseEntity(token: token, user: user.toEntity()),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LoginResponseEntity>> loginWithBiometric() async {
    try {
      if (!await local.hasSession()) {
        return const Left(
          ServerFailure(message: ErrorMessages.noSavedSession),
        );
      }

      if (!await local.isBiometricEnabled()) {
        return const Left(
          ServerFailure(message: ErrorMessages.biometricNotEnabled),
        );
      }

      final gate = await _runBiometricGate(
        'استخدم البصمة لتسجيل الدخول',
      );

      return await gate.fold(
        (failure) async => Left<Failure, LoginResponseEntity>(failure),
        (_) async {
          final user = await local.getSavedUser();
          if (user == null) {
            return const Left<Failure, LoginResponseEntity>(
              CacheFailure(message: ErrorMessages.noSavedSession),
            );
          }

          return Right<Failure, LoginResponseEntity>(
            LoginResponseEntity(
              token: 'mock_token',
              user: user.toEntity(),
            ),
          );
        },
      );
    } catch (_) {
      return const Left(
        BiometricFailure(message: ErrorMessages.generalError),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> enableBiometric() async {
    if (!await local.hasSession()) {
      return const Left(
        ServerFailure(message: ErrorMessages.noSavedSession),
      );
    }

    final gate = await _runBiometricGate('فعّل الدخول بالبصمة');
    if (gate.isLeft()) return gate;

    await local.setBiometricEnabled(true);
    return const Right(unit);
  }

  @override
  Future<Either<Failure, SessionInfoEntity>> getSessionInfo() async {
    try {
      final hasSession = await local.hasSession();
      final canUseBiometric =
          hasSession && await local.isBiometricEnabled();

      return Right(
        SessionInfoEntity(
          hasSession: hasSession,
          canUseBiometric: canUseBiometric,
        ),
      );
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await local.clear();
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
