import 'package:authantication/core/error/exception.dart';
import 'package:authantication/core/utils/message.dart';
import 'package:authantication/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:authantication/features/auth/data/model/user_model.dart';

/// بديل الـ API — لاحقاً استبدليها بـ AuthApiDataSource بنفس الـ interface.
class AuthMockDataSource implements AuthRemoteDataSource {
  static const String demoEmail = 'test@test.com';
  static const String demoPassword = '123456';

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (email.trim() == demoEmail && password == demoPassword) {
      return UserModel(
        id: '1',
        email: email.trim(),
        name: 'Test User',
      );
    }

    throw ServerException(ErrorMessages.invalidCredentials);
  }
}
