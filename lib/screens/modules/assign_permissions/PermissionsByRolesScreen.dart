import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../components/SnackBarUtil.dart';
import '../../../components/drawer_menu/DrawerMenu.dart';
import '../../../models/Permission_set.dart';
import '../../../services/api_model_services/PermissionApiService.dart';
import '../../../services/api_model_services/RoleApiService.dart';
import 'assign_permissions_components/RolePermissionDeleteModal.dart';

class PermissionsByRoleScreen extends StatefulWidget {
  final PermissionSet permissionSet;
  final Map<String, dynamic> sessionData;

  const PermissionsByRoleScreen({
    Key? key,
    required this.permissionSet,
    required this.sessionData,
  }) : super(key: key);

  @override
  _PermissionsByRoleScreenState createState() =>
      _PermissionsByRoleScreenState();
}

class _PermissionsByRoleScreenState extends State<PermissionsByRoleScreen> {
  final PermissionApiService permissionApiService = PermissionApiService();
  final RoleApiService roleApiService = RoleApiService();

  List<dynamic> roles = [];
  List<dynamic> filteredRoles = [];
  List<dynamic> allPermissions = [];
  List<dynamic> filteredPermissions = [];
  List<int> rolePermissions = [];
  List<int> immutablePermissions = [];
  String? selectedRole;
  int? selectedRoleId;
  bool isLoadingRoles = true;
  bool isLoadingPermissions = false;
  bool isSaving = false;
  String roleSearchQuery = "";
  String permissionSearchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    try {
      List<dynamic> fetchedRoles = await roleApiService.fetchRoles(context);
      setState(() {
        // Filtrar los roles para que no incluya el rol "Admin"
        roles = fetchedRoles.where((role) => role['name'] != "Admin").toList();
        filteredRoles = roles;
        isLoadingRoles = false;
      });
    } catch (e) {
      setState(() {
        isLoadingRoles = false;
      });
      //_showErrorSnackBar('Failed to load roles: $e');
    }
  }

  Future<void> _loadPermissionsByRole(int roleId) async {
    setState(() {
      isLoadingPermissions = true;
      filteredPermissions = [];
      allPermissions = [];
      rolePermissions = [];
      immutablePermissions = [];
    });

    try {
      final fetchedPermissions =
          await permissionApiService.fetchPermissions(context);

      final roleData =
          await permissionApiService.fetchPermissionsByRole(context, roleId);

      setState(() {
        allPermissions = fetchedPermissions;
        filteredPermissions = fetchedPermissions;

        final permissionsFromRole = roleData['permissions'] as List<dynamic>;
        immutablePermissions =
            permissionsFromRole.map<int>((p) => p['id']).toList();

        rolePermissions = List.from(immutablePermissions);

        isLoadingPermissions = false;
      });
    } on Exception catch (e) {
      setState(() {
        isLoadingPermissions = false;
      });

      if (e.toString().contains('Session expired')) {
        // The session expired error will already be handled by the ApiResponseHandler
      } else {
        //_showErrorSnackBar('Failed to load permissions for the selected role: $e');
      }
    }
  }

  Future<void> _assignPermissionsToRole() async {
    if (selectedRoleId == null || rolePermissions.isEmpty) {
      _showErrorSnackBar("Please select a role and permissions to assign.");
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await permissionApiService.bulkAssignPermissions(
        context,
        selectedRoleId!,
        rolePermissions,
      );

      await _loadPermissionsByRole(selectedRoleId!);

      setState(() {
        isSaving = false;
      });

      SnackBarUtil.showCustomSnackBar(
        context: context,
        message: "Permissions assigned successfully",
        duration: const Duration(milliseconds: 500),
      );
    } catch (e) {
      setState(() {
        isSaving = false;
      });

      if (e.toString().contains("Session expired")) {
      } else {
        //_showErrorSnackBar("Failed to assign permissions: $e");
      }
    }
  }

  void _showErrorSnackBar(String message) {
    SnackBarUtil.showCustomSnackBar(
      context: context,
      message: message,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _filterRoles(String query) {
    setState(() {
      roleSearchQuery = query;
      filteredRoles = roles
          .where((role) =>
              role['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _filterPermissions(String query) {
    setState(() {
      permissionSearchQuery = query;
      filteredPermissions = allPermissions
          .where((permission) =>
              permission['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _handleFloatingActionButtonPress() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return RolePermissionDeleteModal(
          roles: roles,
        );
      },
    );

    if (result == true && selectedRoleId != null) {
      _loadPermissionsByRole(selectedRoleId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: DrawerMenu(
        onItemTapped: (index) {
          Navigator.pop(context);
        },
        parentContext: context,
        permissionSet: widget.permissionSet,
        sessionData: widget.sessionData,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLandscape
            ? Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            hintText: "Search Role",
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            filled: true,
                            fillColor: Colors.grey[300],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (value) {
                            _filterRoles(value);
                          },
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: _buildRolesSection(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (selectedRole != null)
                          TextField(
                            decoration: InputDecoration(
                              hintText: "Search Permission",
                              prefixIcon:
                                  Icon(Icons.search, color: Colors.grey),
                              filled: true,
                              fillColor: Colors.grey[300],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (value) {
                              _filterPermissions(value);
                            },
                          ),
                        SizedBox(height: 16),
                        Expanded(
                          child: _buildPermissionsSection(),
                        ),
                        SizedBox(height: 16),
                        _buildAssignButton(),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search Role",
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[300],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      _filterRoles(value);
                    },
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    flex: 1,
                    child: _buildRolesSection(),
                  ),
                  if (selectedRole != null) ...[
                    SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Search Permission",
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[300],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        _filterPermissions(value);
                      },
                    ),
                  ],
                  SizedBox(height: 16),
                  Expanded(
                    flex: 2,
                    child: _buildPermissionsSection(),
                  ),
                  SizedBox(height: 16),
                  _buildAssignButton(),
                ],
              ),
      ),
      floatingActionButton: Container(
        height: 60,
        width: 60,
        child: FloatingActionButton(
          onPressed: _handleFloatingActionButtonPress,
          backgroundColor: Colors.red,
          child: Icon(
            Icons.delete,
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
    );
  }

  Widget _buildRolesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 194, 233, 250),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "System Roles",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 34, 118, 186),
              ),
            ),
          ),
          isLoadingRoles
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                  child: filteredRoles.isEmpty
                      ? Center(
                          child: Text(
                            "No roles found.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredRoles.length,
                          itemBuilder: (context, index) {
                            final role = filteredRoles[index];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedRole = role['name'];
                                  selectedRoleId = role['id'];
                                  _loadPermissionsByRole(role['id']);
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 10.0),
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4.0,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.diversity_3,
                                      color: Color.fromARGB(255, 34, 118, 186),
                                      size: 24.0,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        role['name'],
                                        style: TextStyle(
                                            fontSize: 19.0,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    Radio<String>(
                                      value: role['name'],
                                      groupValue: selectedRole,
                                      activeColor:
                                          Color.fromARGB(255, 34, 118, 186),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedRole = value;
                                          selectedRoleId = role['id'];
                                          _loadPermissionsByRole(role['id']);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
        ],
      ),
    );
  }

  Widget _buildPermissionsSection() {
    final isWeb = kIsWeb;

    return Container(
      height: isWeb ? 500 : 300,
      width: isWeb ? 910 : double.infinity,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 194, 233, 250),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Permissions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 34, 118, 186),
              ),
            ),
          ),
          isLoadingPermissions
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                  child: SingleChildScrollView(
                    child: filteredPermissions.isEmpty
                        ? Center(
                            child: Text(
                              "No permissions found.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : Column(
                            children: filteredPermissions.map((permission) {
                              final isSelected =
                                  rolePermissions.contains(permission['id']);
                              final isImmutable = immutablePermissions
                                  .contains(permission['id']);

                              return GestureDetector(
                                onTap: isImmutable
                                    ? null
                                    : () {
                                        setState(() {
                                          if (isSelected) {
                                            rolePermissions
                                                .remove(permission['id']);
                                          } else {
                                            rolePermissions
                                                .add(permission['id']);
                                          }
                                        });
                                      },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 9.0, horizontal: 20.0),
                                  padding: const EdgeInsets.all(18.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4.0,
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.lock,
                                        color: isImmutable
                                            ? Colors.grey
                                            : Color.fromARGB(255, 34, 118, 186),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          permission['name'],
                                          style: TextStyle(
                                            fontSize: 19.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Checkbox(
                                        value: isSelected,
                                        activeColor:
                                            Color.fromARGB(255, 11, 101, 204),
                                        onChanged: isImmutable
                                            ? null
                                            : (bool? value) {
                                                setState(() {
                                                  if (value == true) {
                                                    rolePermissions
                                                        .add(permission['id']);
                                                  } else {
                                                    rolePermissions.remove(
                                                        permission['id']);
                                                  }
                                                });
                                              },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildAssignButton() {
    return ElevatedButton.icon(
      onPressed: (selectedRole == null || rolePermissions.isEmpty || isSaving)
          ? null
          : _assignPermissionsToRole,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            (selectedRole == null || rolePermissions.isEmpty || isSaving)
                ? Colors.grey // Disabled Color
                : Color(0xFF2276BA), // Hex: #2276ba
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 37),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      icon: isSaving
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Icon(Icons.assignment_turned_in, color: Colors.white),
      label: Text(
        isSaving ? "" : "Assign",
        style: TextStyle(fontSize: 22, color: Colors.white),
      ),
    );
  }
}
