import 'package:authantication/features/auth/data/model/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
}
