import 'package:flutter/material.dart';

class UserFilterHelper {
//SEARCH
  static List<dynamic> filterUsers({
    required List<dynamic> users,
    required String? selectedRole,
    required String? selectedEnvironment,
    required String? selectedPermission,
  }) {
    return users.where((user) {
      final roleName = user['role'] != null ? user['role']['name'] : '';
      final environmentName =
          user['environment'] != null ? user['environment']['name'] : '';
      final permissionsList =
          user['permissions'] != null ? user['permissions'] : [];

      final matchesRole = selectedRole == null ||
          selectedRole.isEmpty ||
          roleName == selectedRole;
      final matchesEnvironment = selectedEnvironment == null ||
          selectedEnvironment.isEmpty ||
          environmentName == selectedEnvironment;
      final matchesPermission = selectedPermission == null ||
          selectedPermission.isEmpty ||
          permissionsList.any((perm) => perm['name'] == selectedPermission);

      return matchesRole && matchesEnvironment && matchesPermission;
    }).toList();
  }

  //SEARCH VIEW
  static void showFilterDialog({
    required BuildContext context,
    required List<dynamic> roles,
    required List<dynamic> environments,
    required List<dynamic> permissions,
    required String? selectedRole,
    required String? selectedEnvironment,
    required String? selectedPermission,
    required Function(String? role) onRoleChanged,
    required Function(String? environment) onEnvironmentChanged,
    required Function(String? permission) onPermissionChanged,
    required VoidCallback onApply,
    required VoidCallback onClear,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                'Filter Users',
                style: TextStyle(fontSize: 24),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: DropdownButton<String>(
                        value: selectedRole,
                        hint:
                            Text('Select Role', style: TextStyle(fontSize: 18)),
                        isExpanded: true,
                        items: roles.map((role) {
                          return DropdownMenuItem<String>(
                            value: role['name'],
                            child: Text(role['name'],
                                style: TextStyle(fontSize: 16)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value;
                          });
                          onRoleChanged(value);
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: DropdownButton<String>(
                        value: selectedEnvironment,
                        hint: Text('Select Environment',
                            style: TextStyle(fontSize: 18)),
                        isExpanded: true,
                        items: environments.map((env) {
                          return DropdownMenuItem<String>(
                            value: env['name'],
                            child: Text(env['name'],
                                style: TextStyle(fontSize: 16)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedEnvironment = value;
                          });
                          onEnvironmentChanged(value);
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: DropdownButton<String>(
                        value: selectedPermission,
                        hint: Text('Select Permission',
                            style: TextStyle(fontSize: 18)),
                        isExpanded: true,
                        items: permissions.map((perm) {
                          return DropdownMenuItem<String>(
                            value: perm['name'],
                            child: Text(perm['name'],
                                style: TextStyle(fontSize: 16)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedPermission = value;
                          });
                          onPermissionChanged(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: OutlinedButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.symmetric(vertical: 16)),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Color.fromARGB(255, 214, 217, 219)),
                        side: MaterialStateProperty.all<BorderSide>(
                          BorderSide(
                              color: Color.fromARGB(255, 113, 120, 127),
                              width: 2),
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      onPressed: () {
                        onClear();
                        Navigator.pop(context);
                      },
                      child: Text('Clear',
                          style: TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(255, 113, 120, 127))),
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: OutlinedButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.symmetric(vertical: 16)),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Color(0xFFD2EFFC)),
                        side: MaterialStateProperty.all<BorderSide>(
                          BorderSide(color: Color(0xFF2276BA), width: 2),
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        onApply();
                      },
                      child: Text('Apply',
                          style: TextStyle(
                              fontSize: 18, color: Color(0xFF2276BA))),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
