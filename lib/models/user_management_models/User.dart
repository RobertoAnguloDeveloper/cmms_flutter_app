//MODEL USER CLASS
class User {
  final int id;
  final String id_type;
  final String identification;
  final String firstName;
  final String lastName;
  final String email;
  final int role_id;
  final int environment_id;
  final String username;
  final String password;

  User({
    required this.id,
    required this.id_type,
    required this.identification,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role_id,
    required this.environment_id,
    required this.username,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic>? json) {
    print("from Json");
    print(json);
    return User(
      id: json?['id'],
      id_type: json?['id_type'],
      identification: json?['identification'],
      firstName: json?['firstName'],
      lastName: json?['lastName'],
      email: json?['email'],
      role_id: json?['role_id']['id'],
      environment_id: json?['environment_id']?['id'],
      username: json?['username'],
      password: json?['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_type': id_type,
      'identification': identification,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role_id': role_id,
      'environment_id': environment_id,
      'username': username,
      'password': password,
    };
  }

  factory User.fromJson2(Map<String, dynamic>? json) {
    print("from Json");
    print(json);
    return User(
      id: json?['id'],
      id_type: json?['id_type'],
      identification: json?['identification'],
      firstName: json?['firstName'],
      lastName: json?['lastName'],
      email: json?['email'],
      role_id: json?['role_id'],
      environment_id: json?['environment'],
      username: json?['username'],
      password: json?['password'],
    );
  }
}

class UserRole {
  final int id;
  final String roleName;
  final String roleDescription;

  UserRole({
    required this.id,
    required this.roleName,
    required this.roleDescription,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: json['id'],
      roleName: json['role_name'],
      roleDescription: json['role_description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role_name': roleName,
      'role_description': roleDescription,
    };
  }
}

class UserEnvironment {
  final int id;
  final String environmentName;
  final String environmentDescription;

  UserEnvironment({
    required this.id,
    required this.environmentName,
    required this.environmentDescription,
  });

  factory UserEnvironment.fromJson(Map<String, dynamic> json) {
    return UserEnvironment(
      id: json['id'],
      environmentName: json['environment_name'],
      environmentDescription: json['environment_description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'environment_name': environmentName,
      'environment_description': environmentDescription,
    };
  }
}


/*
class User {
  final int id;
  final String id_type;
  final String identification;
  final String firstName;
  final String lastName;
  final String email;
  final int role_id;
  final int environment_id;
  final String username;
  final String password;

  User({
    required this.id,
    required this.id_type,
    required this.identification,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role_id,
    required this.environment_id,
    required this.username,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic>? json) {
    print("from Json");
    print(json);
    return User(
      id: json?['id'] ?? 0,
      id_type: json?['id_type'] ?? '',
      identification: json?['identification'] ?? '',
      firstName: json?['firstName'] ?? '',
      lastName: json?['lastName'] ?? '',
      email: json?['email'] ?? '',
      role_id: json?['role_id']['id'] ?? 0,
      environment_id: json?['environment_id']?['id'] ?? 0,
      username: json?['username'] ?? '',
      password: json?['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_type': id_type,
      'identification': identification,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role_id': role_id,
      'environment_id': environment_id,
      'username': username,
      'password': password,
    };
  }

  factory User.fromJson2(Map<String, dynamic>? json) {
    print("from Json");
    print(json);
    return User(
      id: json?['id'] ?? 0,
      id_type: json?['id_type'] ?? '',
      identification: json?['identification'] ?? '',
      firstName: json?['firstName'] ?? '',
      lastName: json?['lastName'] ?? '',
      email: json?['email'] ?? '',
      role_id: json?['role_id'] ?? 0,
      environment_id: json?['environment'] ?? 0,
      username: json?['username'] ?? '',
      password: json?['password'] ?? '',
    );
  }
}

class UserRole {
  final int id;
  final String roleName;
  final String roleDescription;

  UserRole({
    required this.id,
    required this.roleName,
    required this.roleDescription,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: json['id'] ?? 0,
      roleName: json['role_name'] ?? '',
      roleDescription: json['role_description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role_name': roleName,
      'role_description': roleDescription,
    };
  }
}

class UserEnvironment {
  final int id;
  final String environmentName;
  final String environmentDescription;

  UserEnvironment({
    required this.id,
    required this.environmentName,
    required this.environmentDescription,
  });

  factory UserEnvironment.fromJson(Map<String, dynamic> json) {
    return UserEnvironment(
      id: json['id'] ?? 0,
      environmentName: json['environment_name'] ?? '',
      environmentDescription: json['environment_description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'environment_name': environmentName,
      'environment_description': environmentDescription,
    };
  }
}
*/