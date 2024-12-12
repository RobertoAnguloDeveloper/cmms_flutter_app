import 'FormEnvironment.dart';

class FormUser {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String username;
  final String fullname;
  final FormEnvironment environment;

  FormUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.fullname,
    required this.environment,
  });

  factory FormUser.fromJson(Map<String, dynamic> json) {
    return FormUser(
      id: json['id'] as int,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      username: json['username'] as String,
      fullname: json['fullname'] as String,
      environment: FormEnvironment.fromJson(json['environment']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'fullname': fullname,
      'environment': environment.toJson(),
    };
  }
}