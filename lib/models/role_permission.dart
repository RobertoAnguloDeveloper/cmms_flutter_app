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
      id: json['id'] as int,
      roleId: json['role_id'] as int,
      permissionId: json['permission_id'] as int,
      role: json['role'] != null ? Role.fromJson(json['role'] as Map<String, dynamic>) : null,
      permission: json['permission'] != null ? Permission.fromJson(json['permission'] as Map<String, dynamic>) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      isDeleted: json['is_deleted'] as bool? ?? false,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'id': id,
      'role_id': roleId,
      'permission_id': permissionId,
      if (role != null) 'role': role!.toJson(),
      if (permission != null) 'permission': permission!.toJson(),
    });
    return data;
  }

  RolePermission copyWith({
    int? id,
    int? roleId,
    int? permissionId,
    Role? role,
    Permission? permission,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return RolePermission(
      id: id ?? this.id,
      roleId: roleId ?? this.roleId,
      permissionId: permissionId ?? this.permissionId,
      role: role ?? this.role,
      permission: permission ?? this.permission,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}