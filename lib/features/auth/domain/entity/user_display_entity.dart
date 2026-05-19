import 'package:equatable/equatable.dart';

/// للعرض في Home فقط — بدون توكن.
class UserDisplayEntity extends Equatable {
  final String name;
  final String email;

  const UserDisplayEntity({required this.name, required this.email});

  @override
  List<Object?> get props => [name, email];
}
