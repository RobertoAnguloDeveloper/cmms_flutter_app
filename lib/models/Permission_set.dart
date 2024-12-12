class PermissionSet {
  final List<String> _permissions;

  PermissionSet.fromJson(List<dynamic> permissions)
      : _permissions = _extractPermissionNames(permissions);

  static List<String> _extractPermissionNames(List<dynamic> permissions) {
    try {
      print('Starting to extract permission names from: $permissions');
      return List<String>.from(
        permissions.map((permission) {
          if (permission is Map) {
            print('Processing permission map: $permission');
            return permission['name'] as String;
          }
          throw Exception(
              'Invalid permission format: Expected Map, got ${permission.runtimeType}');
        }),
      );
    } catch (e) {
      print('Error extracting permission names: $e');
      rethrow;
    }
  }

  bool hasPermission(String permission) {
    return _permissions.contains(permission);
  }

  bool hasAnyPermission(List<String> permissions) {
    return permissions.any((permission) => hasPermission(permission));
  }

  bool hasAllPermissions(List<String> permissions) {
    return permissions.every((permission) => hasPermission(permission));
  }

  List<String> get permissions => List.unmodifiable(_permissions);

  @override
  String toString() {
    return 'PermissionSet(permissions: $_permissions)';
  }
}
