import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final String? agentCode;
  final String? placeOfWork;
  final bool isActive;
  final bool isSuperuser;
  final bool mustChangePassword;
  final List<UserRole> roles;

  const User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.agentCode,
    this.placeOfWork,
    required this.isActive,
    required this.isSuperuser,
    required this.mustChangePassword,
    required this.roles,
  });

  @override
  List<Object?> get props => [
    id,
    username,
    firstName,
    lastName,
    agentCode,
    placeOfWork,
    isActive,
    isSuperuser,
    mustChangePassword,
    roles,
  ];
}

class UserRole extends Equatable {
  final String id;
  final String name;
  final String slug;
  final List<String> permissions;

  const UserRole({
    required this.id,
    required this.name,
    required this.slug,
    required this.permissions,
  });

  @override
  List<Object?> get props => [id, name, slug, permissions];
}
