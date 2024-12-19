import 'base_model.dart';
import 'permission.dart';

class Role extends BaseModel {
  final int id;
  final String name;
  final String? description;
  final bool isSuperUser;
  final List<Permission>? permissions;

  const Role({
    required this.id,
    required this.name,
    this.description,
    required this.isSuperUser,
    this.permissions,
    super.createdAt,
    super.updatedAt,
    super.isDeleted = false,
    super.deletedAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    // Handle both standard and nested response formats
    return Role(
      id: json['id'] ?? json['role_id'] ?? 0,
      name: json['name'] ?? json['role_name'] ?? '',
      description: json['description'] ?? json['role_description'],
      isSuperUser: json['is_super_user'] as bool? ?? false,
      permissions: json['permissions'] != null
          ? (json['permissions'] as List)
          .map((p) => Permission.fromJson(p as Map<String, dynamic>))
          .toList()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      isDeleted: json['is_deleted'] as bool? ?? false,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'is_super_user': isSuperUser,
      if (permissions != null) 'permissions': permissions!.map((p) => p.toJson()).toList(),
    };
  }

  Role copyWith({
    int? id,
    String? name,
    String? description,
    bool? isSuperUser,
    List<Permission>? permissions,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return Role(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isSuperUser: isSuperUser ?? this.isSuperUser,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}