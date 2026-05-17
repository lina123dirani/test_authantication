import 'package:authantication/core/utils/secure_storage.dart';
import 'package:authantication/features/auth/data/datasource/auth_local_data_source.dart';
import 'package:authantication/features/auth/data/datasource/auth_mock_data_source.dart';
import 'package:authantication/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:authantication/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:authantication/features/auth/domain/repositories/auth_repository.dart';
import 'package:authantication/features/auth/domain/usecase/auth_usecase.dart';
import 'package:authantication/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:authantication/services/biometric/biometric_service.dart';
import 'package:authantication/services/biometric/local_auth_biometric_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // ---------------- Secure storage ----------------
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  getIt.registerLazySingleton<SecureStorageHelper>(
    () => SecureStorageHelper(getIt<FlutterSecureStorage>()),
  );

  // ---------------- Biometric ----------------
  getIt.registerLazySingleton<BiometricService>(
    () => LocalAuthBiometricService(),
  );

  // ---------------- Auth ----------------
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthMockDataSource(),
  );

  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(getIt<SecureStorageHelper>()),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remote: getIt<AuthRemoteDataSource>(),
      local: getIt<AuthLocalDataSource>(),
      biometricService: getIt<BiometricService>(),
    ),
  );

  getIt.registerLazySingleton<AuthUseCase>(
    () => AuthUseCase(repository: getIt<AuthRepository>()),
  );

  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(useCase: getIt<AuthUseCase>()),
  );
}
