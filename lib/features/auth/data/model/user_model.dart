import 'package:authantication/features/auth/domain/entity/user_entity.dart';

class UserModel extends User {
  UserModel({required super.id, required super.email, required super.name});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    email: json['email'],
    name: json['name'],
  );

  Map<String, dynamic> toJson() => {'id': id, 'email': email, 'name': name};

  User toEntity() => User(id: id, email: email, name: name);
}