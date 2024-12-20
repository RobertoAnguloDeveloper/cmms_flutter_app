import 'base_model.dart';
import 'role.dart';
import 'permission.dart';

class RolePermission extends BaseModel {
  final int id;
  final int roleId;
  final int permissionId;
  final Role? role;
  final Permission? permission;

  const RolePermission({
    required this.id,
    required this.roleId,
    required this.permissionId,
    this.role,
    this.permission,
    super.createdAt,
    super.updatedAt,
    super.isDeleted = false,
    super.deletedAt,
  });

  factory RolePermission.fromJson(Map<String, dynamic> json) {
    return RolePermission(
      id: json['id'] as int? ?? 0,
      // Extract roleId from either direct field or nested role object
      roleId: json['role_id'] as int? ??
          (json['role'] != null ? (json['role']['id'] as int? ?? 0) : 0),
      // Extract permissionId from either direct field or nested permission object
      permissionId: json['permission_id'] as int? ??
          (json['permissions'] != null ? (json['permissions']['id'] as int? ?? 0) : 0),
      // Handle nested objects
      role: json['role'] != null ? Role.fromJson(json['role'] as Map<String, dynamic>) : null,
      permission: json['permissions'] != null ? Permission.fromJson(json['permissions'] as Map<String, dynamic>) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      isDeleted: json['is_deleted'] as bool? ?? false,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'id': id,
      'role_id': roleId,
      'permission_id': permissionId,
      if (role != null) 'role': role?.toJson(),
      if (permission != null) 'permission': permission?.toJson(),
    };
  }

  RolePermission copyWith({
    int? id,
    int? roleId,
    int? permissionId,
    Role? Function()? role,
    Permission? Function()? permission,
    DateTime? Function()? createdAt,
    DateTime? Function()? updatedAt,
    bool? isDeleted,
    DateTime? Function()? deletedAt,
  }) {
    return RolePermission(
      id: id ?? this.id,
      roleId: roleId ?? this.roleId,
      permissionId: permissionId ?? this.permissionId,
      role: role != null ? role() : this.role,
      permission: permission != null ? permission() : this.permission,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt != null ? deletedAt() : this.deletedAt,
    );
  }
}