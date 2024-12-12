import 'package:flutter/material.dart';

import '../../../../components/AddButton.dart';
import '../../../../components/ListItem.dart';
import '../../../../components/SnackBarUtil.dart';
import '../../../../components/bottom_navigation_menu/BottomNavigationHelper.dart';
import '../../../../components/bottom_navigation_menu/BottomNavigationMenu.dart';
import '../../../../components/drawer_menu/DrawerMenu.dart';
import '../../../../models/Permission_set.dart';
import '../../../../services/api_model_services/EnvironmentApiService.dart';
import '../../../../services/api_model_services/PermissionApiService.dart';
import '../../../../services/api_model_services/RoleApiService.dart';
import '../../../../services/api_model_services/UserApiService.dart';
import 'user_management_helpers/UserDetailHelper.dart';
import 'user_management_helpers/UserFilterHelper.dart';
import 'user_management_helpers/UserRegisterHelper.dart';

class UsersListScreen extends StatefulWidget {
  final PermissionSet permissionSet;
  final Map<String, dynamic> sessionData;

  const UsersListScreen({
    Key? key,
    required this.permissionSet,
    required this.sessionData,
  }) : super(key: key);

  @override
  _UsersListScreenState createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final UserApiService _userApiService = UserApiService();
  final RoleApiService _roleApiService = RoleApiService();
  final EnvironmentApiService _environmentApiService = EnvironmentApiService();
  final PermissionApiService _permissionApiService = PermissionApiService();
  TextEditingController searchController = TextEditingController();

  List<dynamic> users = [];
  List<dynamic> filteredUsers = [];
  List<dynamic> roles = [];
  List<dynamic> environments = [];
  List<dynamic> permissions = [];

  bool showDeletedUsers = false;

  String? selectedRole;
  String? selectedEnvironment;
  String? selectedPermission;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchUsers();
    fetchRoles();
    fetchEnvironment();
    fetchPermissions();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchUsers() async {
    try {
      List<dynamic> usersFromApi = await _userApiService.fetchAllUsers(context);
      setState(() {
        users = usersFromApi;
        filteredUsers = users.where((user) {
          return showDeletedUsers || !(user['is_deleted'] ?? false);
        }).toList();
      });
    } catch (e) {
      print('Error in fetchUsers: $e');
    }
  }

  //METHOD FETCH ROLES
  Future<void> fetchRoles() async {
    try {
      List<dynamic> rolesFromApi = await _roleApiService.fetchRoles(context);
      setState(() {
        roles = rolesFromApi;
      });
    } catch (e) {
      print('Error in fetchRoles: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error retrieving roles: $e')),
      // );
    }
  }

  //METHOD FETCH ENVIRONMENT
  Future<void> fetchEnvironment() async {
    try {
      List<dynamic> environmentsFromApi =
          await _environmentApiService.fetchEnvironment(context);
      setState(() {
        environments = environmentsFromApi;
      });
    } catch (e) {
      print('Error in fetchEnvironment: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error retrieving environments: $e')),
      // );
    }
  }

  //METHOD FETCH PERMISSIONS
  Future<void> fetchPermissions() async {
    try {
      List<dynamic> permissionsFromApi =
          await _permissionApiService.fetchPermissions(context);
      setState(() {
        permissions = permissionsFromApi;
      });
    } catch (e) {
      print('Error in fetchPermissions: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error retrieving permissions: $e')),
      // );
    }
  }

  //METHOD ON SEARCH
  void _onSearchChanged() {
    String searchQuery = searchController.text.toLowerCase();
    setState(() {
      filteredUsers = users.where((user) {
        String firstName = (user['first_name'] ?? '').toLowerCase();
        String lastName = (user['last_name'] ?? '').toLowerCase();
        String fullName = '$firstName $lastName';
        return fullName.startsWith(searchQuery) &&
            (showDeletedUsers || !(user['is_deleted'] ?? false));
      }).toList();
    });
  }

  //FILTER METHOD
  void filterUsers() {
    setState(() {
      filteredUsers = UserFilterHelper.filterUsers(
        users: users,
        selectedRole: selectedRole,
        selectedEnvironment: selectedEnvironment,
        selectedPermission: selectedPermission,
      ).where((user) {
        return showDeletedUsers || !(user['is_deleted'] ?? false);
      }).toList();
    });
  }

  //DIALOG FILTER
  void _showFilterDialog(BuildContext context) {
    UserFilterHelper.showFilterDialog(
      context: context,
      roles: roles,
      environments: environments,
      permissions: permissions,
      selectedRole: selectedRole,
      selectedEnvironment: selectedEnvironment,
      selectedPermission: selectedPermission,
      onRoleChanged: (value) {
        setState(() {
          selectedRole = value;
        });
      },
      onEnvironmentChanged: (value) {
        setState(() {
          selectedEnvironment = value;
        });
      },
      onPermissionChanged: (value) {
        setState(() {
          selectedPermission = value;
        });
      },
      onApply: () {
        filterUsers();
      },
      onClear: () {
        setState(() {
          selectedRole = null;
          selectedEnvironment = null;
          selectedPermission = null;
          filteredUsers = users.where((user) {
            return showDeletedUsers || !(user['is_deleted'] ?? false);
          }).toList();
        });
      },
    );
  }

  //VIEW USER DETAIL
  void _viewUserDetails(BuildContext context, Map<String, dynamic> user) {
    final int currentUserId = widget.sessionData['id'];
    UserDetailHelper.viewUserDetails(
      context: context,
      user: user,
      roles: roles,
      environments: environments,
      fetchUsers: fetchUsers,
      confirmDeleteUser: _confirmDeleteUser,
      currentUserId: currentUserId,
    );
  }

  //REGISTER USER
  void _showRegisterUserDialog(BuildContext context) {
    UserRegisterHelper.showRegisterUserDialog(
      context: context,
      roles: roles,
      environments: environments,
      fetchUsers: fetchUsers,
    );
  }

  //CONFIRM DELETE
  void _confirmDeleteUser(
      BuildContext outerContext, Map<String, dynamic> user) {
    final username = user['username'] ?? 'Usuario';

    showDialog(
      context: outerContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm deletion'),
          content:
              Text('Are you sure you want to delete the user? "$username"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteUser(user['id'] as int);
                Navigator.pop(outerContext);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  //DELETE USER
  Future<void> _deleteUser(int userId) async {
    try {
      await _userApiService.deleteUser(context, userId);

      SnackBarUtil.showCustomSnackBar(
        context: context,
        message: 'User deleted successfully.',
        duration: const Duration(milliseconds: 500),
      );
      fetchUsers();
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Error deleting user: $e'),
      //   ),
      // );
    }
  }

  //ON ITEM TAPPED
  void _onItemTapped(int index) {
    BottomNavigationHelper.onItemTapped(
      context: context,
      selectedIndex: index,
      setSelectedIndex: (newIndex) {
        setState(() {
          _selectedIndex = newIndex;
        });
      },
      sessionData: widget.sessionData,
      permissionSet: widget.permissionSet,
    );
  }

  //MAIN BUILD
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
            Row(
              children: [
                Expanded(
                  flex: 8,
                  child: TextField(
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
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14.0,
                        horizontal: 14.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    color: Color(0xFFBBE4FD),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_alt_outlined,
                        color: Color.fromARGB(255, 0, 51, 128)),
                    onPressed: () => _showFilterDialog(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // TITLE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'System Users',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 34, 118, 186),
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showDeletedUsers = !showDeletedUsers;
                          filterUsers();
                        });
                      },
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: showDeletedUsers
                              ? Color.fromARGB(255, 4, 88, 215)
                              : Colors.grey[300],
                        ),
                        child: showDeletedUsers
                            ? Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Show deleted users',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 34, 118, 186),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // USER LIST
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 30.0),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 210, 239, 252),
                  border: Border.all(color: Color(0xFFD5E9FC), width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: users.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final List<dynamic> notDeletedUsers = filteredUsers
                              .where((user) => user['is_deleted'] == false)
                              .toList();
                          final List<dynamic> deletedUsers = filteredUsers
                              .where((user) => user['is_deleted'] == true)
                              .toList();
                          final sortedUsers = [
                            ...notDeletedUsers,
                            ...deletedUsers
                          ];
                          final user = sortedUsers[index];
                          final username = user['username'] ?? '';
                          final fullName =
                              '${user['first_name']} ${user['last_name']}';
                          final isDeleted = user['is_deleted'] ?? false;

                          return ListItem(
                            name: fullName.isNotEmpty ? fullName : username,
                            onView: () {
                              _viewUserDetails(context, user);
                            },
                            icon: Icon(
                              Icons.account_circle,
                              color: Colors.white,
                            ),
                            isDeleted: isDeleted,
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
          _showRegisterUserDialog(context);
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
