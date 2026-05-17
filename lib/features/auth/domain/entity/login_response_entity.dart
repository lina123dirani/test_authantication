import 'package:authantication/features/auth/domain/entity/user_entity.dart';
import 'package:equatable/equatable.dart';

class LoginResponseEntity extends Equatable {
  final String token;
  final User user;

  const LoginResponseEntity({required this.token, required this.user});

  @override
  List<Object?> get props => [token, user];
}
