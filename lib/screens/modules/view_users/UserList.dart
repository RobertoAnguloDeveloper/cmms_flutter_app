import 'package:flutter/material.dart';

import '../../../components/drawer_menu/DrawerMenu.dart';
import '../../../models/Permission_set.dart';
import '../../../services/api_model_services/UserApiService.dart';

class UsersPage extends StatefulWidget {
  final PermissionSet permissionSet;
  final Map<String, dynamic> sessionData;

  const UsersPage({
    Key? key,
    required this.permissionSet,
    required this.sessionData,
  }) : super(key: key);

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<dynamic> users = [];
  List<dynamic> filteredUsers = [];
  TextEditingController searchController = TextEditingController();
  final UserApiService _userController = UserApiService();

  @override
  void initState() {
    super.initState();
    fetchUsersByEnvironment();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchUsersByEnvironment() async {
    try {
      final environment = widget.sessionData['environment'];
      if (environment != null && environment.containsKey('id')) {
        int environmentId = environment['id'];

        List<dynamic> usersFromApi = await _userController
            .fetchUsersByEnvironment(context, environmentId);

        setState(() {
          users = usersFromApi;
          filteredUsers = users;
        });
      } else {
        throw Exception(
            'Environment ID is null or missing in sessionData. Content: ${widget.sessionData}');
      }
    } catch (e) {
      print('Error in fetchUsersByEnvironment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading users: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _onSearchChanged() {
    String searchQuery = searchController.text.toLowerCase();
    setState(() {
      filteredUsers = users.where((user) {
        String fullName =
            '${user['first_name']} ${user['last_name']}'.toLowerCase();
        return fullName.contains(searchQuery);
      }).toList();
    });
  }

  void _viewUserDetails(BuildContext context, Map<String, dynamic> user) {
    String username = user['username'] ?? 'No Username';
    String phoneNumber = user['contact_number'] ?? 'No Contact Number';
    String firstName = user['first_name'] ?? 'No First Name';
    String lastName = user['last_name'] ?? 'No Last Name';
    String email = user['email'] ?? 'No Email';
    String role = user['role']?['role_name'] ?? 'No Role';
    String environment =
        user['environment']?['environment_name'] ?? 'No Environment';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            width: 320,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField('Username', username),
                  const SizedBox(height: 10),
                  _buildTextField('Phone Number', phoneNumber),
                  const SizedBox(height: 10),
                  _buildTextField('First Name', firstName),
                  const SizedBox(height: 10),
                  _buildTextField('Last Name', lastName),
                  const SizedBox(height: 10),
                  _buildTextField('Email', email),
                  const SizedBox(height: 10),
                  _buildTextField('Role', role),
                  const SizedBox(height: 10),
                  _buildTextField('Environment', environment),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(String label, String value) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.black),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
      controller: TextEditingController(text: value),
      style: TextStyle(color: Colors.black),
      enabled: false,
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
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFD2EFFC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: users.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          final fullName =
                              '${user['first_name']} ${user['last_name']}';
                          return Card(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Color(0xFF7DD0F4)),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Color(0xFF2276BA),
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              title: Text(fullName),
                              onTap: () => _viewUserDetails(context, user),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
