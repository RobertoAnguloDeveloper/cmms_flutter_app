import 'base_model.dart';
import 'role.dart';
import 'environment.dart';

class User extends BaseModel {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String? contactNumber;
  final Role? role;
  final Environment? environment;

  User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.contactNumber,
    this.role,
    this.environment,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.deletedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      contactNumber: json['contact_number'],
      role: json['role'] != null ? Role.fromJson(json['role']) : null,
      environment: json['environment'] != null ? Environment.fromJson(json['environment']) : null,
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
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'contact_number': contactNumber,
      'role': role?.toJson(),
      'environment': environment?.toJson(),
    });
    return data;
  }
}