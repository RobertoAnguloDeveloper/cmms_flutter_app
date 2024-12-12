import 'package:flutter/material.dart';

import '../../../components/drawer_menu/DrawerMenu.dart';
import '../../../models/Permission_set.dart';

class HomePage extends StatelessWidget {
  final Map<String, dynamic> sessionData;
  final PermissionSet permissionSet;

  const HomePage({
    Key? key,
    required this.sessionData,
    required this.permissionSet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('HomePage building...');
    print('SessionData keys: ${sessionData.keys}');
    print('PermissionSet contains: ${permissionSet.permissions}');
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
        permissionSet: permissionSet,
        sessionData: sessionData,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Welcome ${sessionData['full_name']}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
