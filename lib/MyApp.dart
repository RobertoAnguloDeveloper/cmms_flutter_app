import 'package:flutter/material.dart';
import 'models/Permission_set.dart';
import 'screens/login_screen/LoginPage.dart';
import 'screens/modules/home/HomePage.dart';

class MyApp extends StatelessWidget {
  final Map<String, dynamic>? sessionData;
  final PermissionSet? permissionSet;

  const MyApp({
    Key? key, 
    this.sessionData,
    this.permissionSet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CMMS App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: sessionData != null && permissionSet != null
          ? HomePage(
              sessionData: sessionData!,
              permissionSet: permissionSet!,
            )
          : const LoginPage(),
    );
  }
}
