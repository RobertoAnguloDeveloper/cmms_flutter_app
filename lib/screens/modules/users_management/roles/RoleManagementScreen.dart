import 'package:flutter/material.dart';

import '../../../../components/AddButton.dart';
import '../../../../components/ListItem.dart';
import '../../../../components/bottom_navigation_menu/BottomNavigationHelper.dart';
import '../../../../components/bottom_navigation_menu/BottomNavigationMenu.dart';
import '../../../../components/drawer_menu/DrawerMenu.dart';
import '../../../../models/Permission_set.dart';
import '../../../../services/api_model_services/RoleApiService.dart';
import 'role_management_helpers/RoleDetailsHelper.dart';
import 'role_management_helpers/RoleRegisterHelper.dart';

class RoleManagementScreen extends StatefulWidget {
  final PermissionSet permissionSet;
  final Map<String, dynamic> sessionData;

  const RoleManagementScreen({
    Key? key,
    required this.permissionSet,
    required this.sessionData,
  }) : super(key: key);

  @override
  _RolesPageState createState() => _RolesPageState();
}

class _RolesPageState extends State<RoleManagementScreen> {
  List<dynamic> roles = [];
  List<dynamic> filteredRoles = [];
  TextEditingController searchController = TextEditingController();
  int _selectedIndex = 1;
  final RoleApiService roleApiService = RoleApiService();

  @override
  void initState() {
    super.initState();
    fetchRoles();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

 void _onSearchChanged() {
  String searchQuery = searchController.text.toLowerCase();
  setState(() {
    filteredRoles = roles.where((role) {
      String roleName = (role['name'] ?? '').toLowerCase();
      return roleName.contains(searchQuery) && roleName != 'admin';
    }).toList();
  });
}


  Future<void> fetchRoles() async {
    try {
      final rolesData = await roleApiService.fetchRoles(context);
      setState(() {
        roles = rolesData.where((role) => role['name'] != 'Admin').toList();
        filteredRoles = roles;
      });
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error retrieving roles: $e')),
      // );
    }
  }

  void _viewRoleDetails(BuildContext context, Map<String, dynamic> role) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RoleDetailsHelper(
          role: role,
          onRoleUpdated: fetchRoles,
        );
      },
    );
  }

  void _showRegisterRoleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RoleRegisterHelper();
      },
    ).then((_) {
      fetchRoles();
    });
  }

  void _onItemTapped(int index) {
    BottomNavigationHelper.onItemTapped(
      context: context,
      selectedIndex: index,
      setSelectedIndex: (int newIndex) {
        setState(() {
          _selectedIndex = newIndex;
        });
      },
      sessionData: widget.sessionData,
      permissionSet: widget.permissionSet,
    );
  }

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'System Roles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 34, 118, 186),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 30.0),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 210, 239, 252),
                  border: Border.all(color: Color(0xFFD5E9FC), width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: roles.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: filteredRoles.length,
                        itemBuilder: (context, index) {
                          final role = filteredRoles[index];
                          final roleName = role['name'] ?? '';
                          return ListItem(
                            name: roleName,
                            onView: () {
                              _viewRoleDetails(context, role);
                            },
                            icon: Icon(
                              Icons.group, 
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: AddButton(  
        onPressed: () {
          _showRegisterRoleDialog(context);
        },
      ),
      bottomNavigationBar: BottomNavigationMenu(
        selectedIndex: _selectedIndex,
        sessionData: widget.sessionData,
        permissionSet: widget.permissionSet,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
