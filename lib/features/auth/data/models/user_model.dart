import '../../domain/entities/user_entity.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.firstName,
    required super.lastName,
    super.agentCode,
    super.placeOfWork,
    required super.isActive,
    required super.isSuperuser,
    required super.mustChangePassword,
    required super.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // metadata_ is used in profile response, metadata in some other responses
    final metadata = json['metadata_'] ?? json['metadata'] ?? {};

    // For names, we prefer first_name/last_name but can try to split fullname if present
    String firstName = json['first_name'] ?? '';
    String lastName = json['last_name'] ?? '';
    if (firstName.isEmpty && lastName.isEmpty && json['fullname'] != null) {
      final parts = (json['fullname'] as String).split(' ');
      if (parts.isNotEmpty) {
        firstName = parts.first;
        if (parts.length > 1) {
          lastName = parts.sublist(1).join(' ');
        }
      }
    }

    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? json['matricule'] ?? '',
      firstName: firstName,
      lastName: lastName,
      agentCode: json['matricule'] ?? metadata['code'] ?? json['code'],
      placeOfWork: metadata['place_of_work'] ?? json['place_of_work'],
      isActive: json['is_active'] ?? false,
      isSuperuser: json['is_superuser'] ?? false,
      mustChangePassword: json['must_change_password'] ?? false,
      roles:
          (json['roles'] as List<dynamic>?)
              ?.map((e) => UserRoleModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'code': agentCode,
      'place_of_work': placeOfWork,
      'is_active': isActive,
      'is_superuser': isSuperuser,
      'must_change_password': mustChangePassword,
      'roles': roles.map((e) => (e as UserRoleModel).toJson()).toList(),
    };
  }

  UserModel copyWith({
    String? agentCode,
    String? placeOfWork,
    String? firstName,
    String? lastName,
  }) {
    return UserModel(
      id: this.id,
      username: this.username,
      isActive: this.isActive,
      isSuperuser: this.isSuperuser,
      mustChangePassword: this.mustChangePassword,
      roles: this.roles,
      agentCode: agentCode ?? this.agentCode,
      placeOfWork: placeOfWork ?? this.placeOfWork,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
    );
  }
}

class UserRoleModel extends UserRole {
  const UserRoleModel({
    required super.id,
    required super.name,
    required super.slug,
    required super.permissions,
  });

  factory UserRoleModel.fromJson(Map<String, dynamic> json) {
    return UserRoleModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      permissions:
          (json['permissions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'slug': slug, 'permissions': permissions};
  }
}
