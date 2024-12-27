// 📂 lib/screens/DraftsScreen.dart

import 'package:flutter/material.dart';
import '../screens/modules/home/HomePage.dart';
import '../models/Permission_set.dart';

class DraftsScreen extends StatelessWidget {
  final PermissionSet permissionSet;
  final Map<String, dynamic> sessionData;

  const DraftsScreen({
    Key? key,
    required this.permissionSet,
    required this.sessionData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(
                  sessionData: sessionData,
                  permissionSet: permissionSet,
                ),
              ),
            );
          },
        ),
        title: const Text("Drafts"),
      ),
      body: Container(
        color: const Color.fromARGB(255, 211, 234, 248),
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: const Color.fromARGB(255, 237, 231, 253),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            title: const Text(
              "The form has been saved.",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              "A draft or reference of the completed form is displayed.",
            ),
            trailing: const Icon(Icons.check_circle_outline, color: Colors.green),
          ),
        ),
      ),
    );
  }
}