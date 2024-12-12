import 'package:flutter/material.dart';

import '../../../../services/api_model_services/PermissionApiService.dart';
import '../../../../services/api_model_services/RoleApiService.dart';

class RolePermissionDeleteModal extends StatefulWidget {
  final List<dynamic> roles;

  RolePermissionDeleteModal({required this.roles});

  @override
  _RolePermissionDeleteModalState createState() =>
      _RolePermissionDeleteModalState();
}

class _RolePermissionDeleteModalState extends State<RolePermissionDeleteModal> {
  final PermissionApiService permissionApiService = PermissionApiService();
  final RoleApiService roleApiService = RoleApiService();

  int? selectedRoleId;
  List<dynamic> rolePermissions = [];
  List<dynamic> filteredPermissions = [];
  bool isLoadingPermissions = false;
  List<dynamic> filteredRoles = [];

  @override
  void initState() {
    super.initState();
    // Filtrar roles para excluir "Admin"
    filteredRoles =
        widget.roles.where((role) => role['name'] != "Admin").toList();
  }

  Future<void> _loadPermissions(int roleId) async {
    setState(() {
      isLoadingPermissions = true;
      rolePermissions = [];
      filteredPermissions = [];
    });

    try {
      final roleData =
          await permissionApiService.fetchPermissionsByRole(context, roleId);

      setState(() {
        rolePermissions = roleData['permissions'] as List<dynamic>;
        filteredPermissions = rolePermissions;
        isLoadingPermissions = false;
      });
    } on Exception catch (e) {
      setState(() {
        isLoadingPermissions = false;
      });

      if (e.toString().contains('Session expired')) {
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text("Failed to load permissions: $e")),
        // );
      }
    }
  }

  Future<bool> _confirmDelete(
      BuildContext context, String permissionName) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Confirm Delete"),
              content: Text(
                  "Are you sure you want to remove the permission '$permissionName'?"),
              actions: [
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text("Delete"),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _removePermission(int rolePermissionId) async {
    final success = await permissionApiService.removePermissionFromRole(
      context,
      rolePermissionId,
    );

    if (success) {
      setState(() {
        rolePermissions
            .removeWhere((p) => p['role_permission_id'] == rolePermissionId);
        filteredPermissions = List.from(rolePermissions);
      });
      Navigator.pop(context, true);
    }
  }

  void _handleRoleSelection(int roleId) {
    setState(() {
      selectedRoleId = roleId;
    });
    _loadPermissions(roleId);
  }

  void _filterRoles(String query) {
    setState(() {
      filteredRoles = widget.roles
          .where((role) =>
              role['name'].toLowerCase().contains(query.toLowerCase()) &&
              role['name'] != "Admin") // Excluir "Admin"
          .toList();
    });
  }

  void _filterPermissions(String query) {
    setState(() {
      filteredPermissions = rolePermissions
          .where((permission) =>
              permission['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 600;

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Delete Role Permissions",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.black),
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: isWideScreen
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildRolesList(),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: _buildPermissionsList(),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                _buildRolesList(),
                                SizedBox(height: 16),
                                Expanded(child: _buildPermissionsList()),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRolesList() {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Roles",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: "Search Role",
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          ),
          onChanged: _filterRoles,
        ),
        SizedBox(height: 8),
        Container(
          height: isLandscape ? 200 : 350, // Altura dinámica
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 225, 241, 249),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ListView.builder(
            itemCount: filteredRoles.length,
            itemBuilder: (context, index) {
              final role = filteredRoles[index];
              final isSelected = selectedRoleId == role['id'];

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _handleRoleSelection(role['id']);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey[300]!,
                          width: isSelected ? 2.0 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.diversity_3, color: Colors.black54),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              role['name'],
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected ? Colors.blue : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Permissions",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: "Search Permission",
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          ),
          onChanged: _filterPermissions,
        ),
        SizedBox(height: 8),
        Expanded(
          child: isLoadingPermissions
              ? Center(child: CircularProgressIndicator())
              : filteredPermissions.isEmpty
                  ? Center(
                      child: Text(
                        "No permissions found for the selected role.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredPermissions.length,
                      itemBuilder: (context, index) {
                        final permission = filteredPermissions[index];

                        return ListTile(
                          title: Text(permission['name']),
                          subtitle: Text(permission['description']),
                          leading: Icon(Icons.lock),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await _confirmDelete(
                                  context, permission['name']);
                              if (confirm) {
                                await _removePermission(
                                    permission['role_permission_id']);
                              }
                            },
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
