import 'package:flutter/material.dart';
import '../../../../components/AddButton.dart';
import '../../../../components/ListItem.dart';
import '../../../../components/bottom_navigation_menu/BottomNavigationHelper.dart';
import '../../../../components/bottom_navigation_menu/BottomNavigationMenu.dart';
import '../../../../components/drawer_menu/DrawerMenu.dart';
import '../../../../models/Permission_set.dart';
import '../../../../services/api_model_services/EnvironmentApiService.dart';
import 'environment_management_helpers/EnvironmentRegisterHelper.dart';
import 'environment_management_helpers/EnviromentsDetailsHelper.dart';

//I CHANGED THIS 17/11/2024 10:48
class EnvironmentManagementScreen extends StatefulWidget {
  final PermissionSet permissionSet;
  final Map<String, dynamic> sessionData;

  const EnvironmentManagementScreen({
    Key? key,
    required this.permissionSet,
    required this.sessionData,
  }) : super(key: key);

  @override
  _EnvironmentsPageState createState() => _EnvironmentsPageState();
}

class _EnvironmentsPageState extends State<EnvironmentManagementScreen> {
  List<dynamic> environments = [];
  List<dynamic> filteredEnvironments = [];
  TextEditingController searchController = TextEditingController();
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    fetchEnvironments();
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
      filteredEnvironments = environments.where((env) {
        String envName = (env['name'] ?? '').toLowerCase();
        return envName.contains(searchQuery);
      }).toList();
    });
  }

  Future<void> fetchEnvironments() async {
  try {
    final environmentsData =
        await EnvironmentApiService().fetchEnvironment(context);
    setState(() {
      environments = environmentsData;
      filteredEnvironments = environments;
    });
  } catch (e) {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Error retrieving environments: $e')),
    // );
  }
}


  void _viewEnvironmentDetails(
      BuildContext context, Map<String, dynamic> environment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EnvironmentDetailsScreen(environment: environment);
      },
    ).then((_) {
      fetchEnvironments();
    });
  }

  void _showRegisterEnvironmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RegisterEnvironment();
      },
    ).then((_) {
      fetchEnvironments();
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
                'System Environments',
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
                child: environments.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: filteredEnvironments.length,
                        itemBuilder: (context, index) {
                          final environment = filteredEnvironments[index];
                          final environmentName = environment['name'] ?? '';
                          return ListItem(
                            name: environmentName,
                            onView: () {
                              _viewEnvironmentDetails(context, environment);
                            },
                            icon: Icon(
                              Icons
                                  .location_city, 
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
      floatingActionButton: AddButton(  // Use the new AddUserButton widget
        onPressed: () {
          _showRegisterEnvironmentDialog(context);
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
