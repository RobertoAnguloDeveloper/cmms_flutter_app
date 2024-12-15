import 'base_model.dart';
import 'permission.dart';

class Role extends BaseModel {
  final int id;
  final String name;
  final String? description;
  final bool isSuperUser;
  final List<Permission>? permissions;

  Role({
    required this.id,
    required this.name,
    this.description,
    this.isSuperUser = false,
    this.permissions,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.deletedAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isSuperUser: json['is_super_user'] ?? false,
      permissions: json['permissions'] != null
          ? (json['permissions'] as List)
          .map((p) => Permission.fromJson(p))
          .toList()
          : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      isDeleted: json['is_deleted'] ?? false,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'id': id,
      'name': name,
      'description': description,
      'is_super_user': isSuperUser,
      'permissions': permissions?.map((p) => p.toJson()).toList(),
    });
    return data;
  }
}