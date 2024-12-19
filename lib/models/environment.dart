import 'base_model.dart';

class Environment extends BaseModel {
  final int id;
  final String name;
  final String? description;
  final int? usersCount;

  const Environment({
    required this.id,
    required this.name,
    this.description,
    this.usersCount,
    super.createdAt,
    super.updatedAt,
    super.isDeleted = false,
    super.deletedAt,
  });

  factory Environment.fromJson(Map<String, dynamic> json) {
    // Handle both standard and nested response formats
    return Environment(
      id: json['id'] ?? json['environment_id'] ?? 0,
      name: json['name'] ?? json['environment_name'] ?? '',
      description: json['description'] ?? json['environment_description'],
      usersCount: json['users_count'],
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
      'name': name,
      if (description != null) 'description': description,
      if (usersCount != null) 'users_count': usersCount,
    };
  }

  Environment copyWith({
    int? id,
    String? name,
    String? Function()? description,
    int? Function()? usersCount,
    DateTime? Function()? createdAt,
    DateTime? Function()? updatedAt,
    bool? isDeleted,
    DateTime? Function()? deletedAt,
  }) {
    return Environment(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description != null ? description() : this.description,
      usersCount: usersCount != null ? usersCount() : this.usersCount,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt != null ? deletedAt() : this.deletedAt,
    );
  }
}