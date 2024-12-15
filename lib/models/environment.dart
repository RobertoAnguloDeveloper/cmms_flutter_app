// lib/models/environment.dart
import 'base_model.dart';

class Environment extends BaseModel {
  final int id;
  final String name;
  final String? description;
  final int? usersCount;

  Environment({
    required this.id,
    required this.name,
    this.description,
    this.usersCount,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.deletedAt,
  });

  factory Environment.fromJson(Map<String, dynamic> json) {
    return Environment(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      usersCount: json['users_count'],
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
    });
    return data;
  }
}