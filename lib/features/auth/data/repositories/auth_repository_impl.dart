import 'package:authantication/core/error/exception.dart';
import 'package:authantication/core/error/failure.dart';
import 'package:authantication/core/security/security_gate.dart';
import 'package:authantication/core/utils/message.dart';
import 'package:authantication/features/auth/data/datasource/auth_local_data_source.dart';
import 'package:authantication/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:authantication/features/auth/domain/entity/login_entity.dart';
import 'package:authantication/features/auth/domain/entity/login_response_entity.dart';
import 'package:authantication/features/auth/domain/entity/session_info_entity.dart';
import 'package:authantication/features/auth/domain/entity/user_display_entity.dart';
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

  /// فحص بيئة التشغيل قبل كل عملية حساسة (يُعاد في release).
  Future<void> _assertSafeRuntime() => SecurityGate.assertSafeRuntime();

  /// إذا أُضيفت/حُذفت بصمة على الجهاز → مسح الجلسة وإرجاع Failure.
  Future<Failure?> _failureIfEnrollmentChanged() async {
    if (!await local.isBiometricEnabled()) return null;

    final changed = await local.hasBiometricEnrollmentChanged();
    if (!changed) return null;

    await local.clear();
    return const BiometricFailure(
      message: ErrorMessages.biometricEnrollmentChanged,
    );
  }

  @override
  Future<Either<Failure, LoginResponseEntity>> login(
    LoginEntity request,
  ) async {
    try {
      await _assertSafeRuntime();

      final user = await remote.login(
        email: request.email,
        password: request.password,
      );

      const token = 'mock_token';
      await local.saveSession(token: token, user: user);

      return Right(
        LoginResponseEntity(token: token, user: user.toEntity()),
      );
    } on SecurityException catch (e) {
      return Left(SecurityFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LoginResponseEntity>> loginWithBiometric() async {
    try {
      await _assertSafeRuntime();

      final enrollmentFailure = await _failureIfEnrollmentChanged();
      if (enrollmentFailure != null) return Left(enrollmentFailure);

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

      final session = await local.readBiometricProtectedSession();
      if (session == null) {
        if (await local.isBiometricEnabled()) {
          await local.resetBiometricAfterCorruptStorage();
          return const Left(
            BiometricFailure(
              message: ErrorMessages.biometricSessionNeedsRefresh,
            ),
          );
        }
        return const Left(
          CacheFailure(message: ErrorMessages.noSavedSession),
        );
      }

      return Right(
        LoginResponseEntity(
          token: session.token,
          user: session.user.toEntity(),
        ),
      );
    } on SecurityException catch (e) {
      return Left(SecurityFailure(message: e.message));
    } on BiometricException catch (e) {
      return Left(BiometricFailure(message: e.message));
    } catch (e) {
      return Left(BiometricFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> enableBiometric() async {
    try {
      await _assertSafeRuntime();
    } on SecurityException catch (e) {
      return Left(SecurityFailure(message: e.message));
    }

    if (!await local.hasSession()) {
      return const Left(
        ServerFailure(message: ErrorMessages.noSavedSession),
      );
    }

    final readiness = await biometricService.checkReadiness();
    if (!readiness.isReady) {
      return Left(BiometricFailure(message: readiness.message));
    }

    try {
      // نافذة بصمة واحدة من النظام عند نقل الجلسة للـ vault (بدون authenticate مكرر).
      await local.migrateSessionToBiometricVault();
      await local.setBiometricEnabled(true);
      await local.installBiometricEnrollmentMarker();

      return const Right(unit);
    } on BiometricException catch (e) {
      return Left(BiometricFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(BiometricFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SessionInfoEntity>> getSessionInfo() async {
    try {
      await _assertSafeRuntime();

      final enrollmentFailure = await _failureIfEnrollmentChanged();
      if (enrollmentFailure != null) {
        return Left(enrollmentFailure);
      }

      final hasSession = await local.hasSession();
      final canUseBiometric =
          hasSession && await local.isBiometricEnabled();

      return Right(
        SessionInfoEntity(
          hasSession: hasSession,
          canUseBiometric: canUseBiometric,
        ),
      );
    } on SecurityException catch (e) {
      return Left(SecurityFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserDisplayEntity>> getStoredUserProfile() async {
    try {
      await _assertSafeRuntime();

      final enrollmentFailure = await _failureIfEnrollmentChanged();
      if (enrollmentFailure != null) {
        return Left(enrollmentFailure);
      }

      final stored = await local.readStoredSession();
      if (stored == null) {
        return const Left(
          CacheFailure(message: ErrorMessages.noSavedSession),
        );
      }

      final user = stored.user.toEntity();
      return Right(
        UserDisplayEntity(name: user.name, email: user.email),
      );
    } on SecurityException catch (e) {
      return Left(SecurityFailure(message: e.message));
    } on BiometricException catch (e) {
      return Left(BiometricFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await local.clear();
    } catch (_) {
      // إعادة المحاولة — الأمان أولاً حتى لو فشلت المرة الأولى.
      await local.clear();
    }
  }
}
