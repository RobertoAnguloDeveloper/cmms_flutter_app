import 'Permission.dart';
import 'Role.dart';

class RolePermission {
  final int id;
  final Permission permission;
  final Role role;
  final DateTime createdAt;
  final DateTime updatedAt;

  RolePermission({
    required this.id,
    required this.permission,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RolePermission.fromJson(Map<String, dynamic> json) {
    return RolePermission(
      id: json['id'],
      permission: Permission.fromJson(json['permissions']),
      role: Role.fromJson(json['role']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
