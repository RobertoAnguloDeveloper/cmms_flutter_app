import 'package:flutter/material.dart';

import '../../screens/modules/users_management/environment/EnvironmentManagementScreen.dart';
import '../../screens/modules/users_management/permissions/PermissionManagementScreen.dart';
import '../../screens/modules/users_management/roles/RoleManagementScreen.dart';
import '../../screens/modules/users_management/users/UserManagementScreen.dart';

class BottomNavigationHelper {
  static void onItemTapped({
    required BuildContext context,
    required int selectedIndex,
    required Function(int index) setSelectedIndex,
    required Map<String, dynamic> sessionData,
    required dynamic permissionSet,
  }) {
    Widget targetScreen;

    switch (selectedIndex) {
      case 0:
        targetScreen = UsersListScreen(
          permissionSet: permissionSet,
          sessionData: sessionData,
        );
        break;
      case 1:
        targetScreen = RoleManagementScreen(
          permissionSet: permissionSet,
          sessionData: sessionData,
        );
        break;
      case 2:
        targetScreen = EnvironmentManagementScreen(
          permissionSet: permissionSet,
          sessionData: sessionData,
        );
        break;
      case 3:
        targetScreen = PermissionsPage(
          permissionSet: permissionSet,
          sessionData: sessionData,
        );
        break;
      default:
        return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => targetScreen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
      (route) => false,
    );

    setSelectedIndex(selectedIndex);
  }
}
