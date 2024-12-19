import 'base_model.dart';

class Permission extends BaseModel {
  final int id;
  final String name;
  final String? description;
  final List<dynamic>? roles;

  const Permission({
    required this.id,
    required this.name,
    this.description,
    this.roles,
    super.createdAt,
    super.updatedAt,
    super.isDeleted = false,
    super.deletedAt,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      roles: json['roles'] as List<dynamic>?,
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
      'name': name,
      if (description != null) 'description': description,
      if (roles != null) 'roles': roles,
    });
    return data;
  }

  Permission copyWith({
    int? id,
    String? name,
    String? description,
    List<dynamic>? roles,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return Permission(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      roles: roles ?? this.roles,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}