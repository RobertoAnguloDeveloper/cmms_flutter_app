import 'package:flutter/material.dart';
import 'models/Permission_set.dart';
import 'models/user_management_models/User.dart';
import 'screens/login_screen/LoginPage.dart';

class MyApp extends StatelessWidget {
  final Map<String, dynamic>? sessionData;
  final PermissionSet? permissionSet;

  
  const MyApp({super.key, this.sessionData, this.permissionSet,});

  @override
  Widget build(BuildContext context) {
    if (sessionData != null) {
      User user = User.fromJson2(sessionData);
      print("from MyApp");
      print(user.runtimeType);
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
