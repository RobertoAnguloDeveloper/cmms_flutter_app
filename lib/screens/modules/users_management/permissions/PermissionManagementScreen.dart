import 'package:flutter/material.dart';
import '../../../../components/AddButton.dart';
import '../../../../components/ListItem.dart';
import '../../../../components/bottom_navigation_menu/BottomNavigationHelper.dart';
import '../../../../components/bottom_navigation_menu/BottomNavigationMenu.dart';
import '../../../../components/drawer_menu/DrawerMenu.dart';
import '../../../../models/Permission_set.dart';
import '../../../../services/api_model_services/PermissionApiService.dart';
import 'permission_management_helpers/PermissionRegisterHelper.dart';
import 'permission_management_helpers/PermissionDetailsHelper.dart';

class PermissionsPage extends StatefulWidget {
  final PermissionSet permissionSet;
  final Map<String, dynamic> sessionData;

  const PermissionsPage({
    Key? key,
    required this.permissionSet,
    required this.sessionData,
  }) : super(key: key);

  @override
  _PermissionsPageState createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  List<dynamic> permissions = [];
  List<dynamic> filteredPermissions = [];
  TextEditingController searchController = TextEditingController();
  final PermissionApiService permissionController = PermissionApiService();
  int _selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    fetchPermissions();
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
      filteredPermissions = permissions.where((perm) {
        String permName = (perm['name'] ?? '').toLowerCase();
        return permName.contains(searchQuery);
      }).toList();
    });
  }

  Future<void> fetchPermissions() async {
    try {
      final permissionsData =
          await permissionController.fetchPermissions(context);

      setState(() {
        permissions = permissionsData;
        filteredPermissions = permissions;
      });
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error retrieving permissions: $e')),
      // );
    }
  }

  void _viewPermissionDetails(
      BuildContext context, Map<String, dynamic> permission) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PermissionDetailsScreen(
          permission: permission,
          onPermissionUpdated: fetchPermissions,
        );
      },
    );
  }

  void _showRegisterPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RegisterPermission();
      },
    ).then((_) {
      fetchPermissions();
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

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
    double iconSize = 30.0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color:
                  isSelected ? Color.fromARGB(255, 34, 118, 186) : Colors.grey,
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Color.fromARGB(255, 34, 118, 186)
                    : Colors.grey,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
                'System Permissions',
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
                child: permissions.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: filteredPermissions.length,
                        itemBuilder: (context, index) {
                          final permission = filteredPermissions[index];
                          final permissionName = permission['name'] ?? '';
                          return ListItem(
                            name: permissionName,
                            onView: () {
                              _viewPermissionDetails(context, permission);
                            },
                            icon: Icon(
                              Icons.lock,
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
          _showRegisterPermissionDialog(context);
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

