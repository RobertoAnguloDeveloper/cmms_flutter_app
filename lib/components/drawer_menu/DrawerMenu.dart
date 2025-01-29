import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/Permission_set.dart';
import '../../models/submission_management/QuestionsAnswerScreen.dart';
import '../../screens/DraftsScreen.dart';
import '../../screens/login_screen/LoginPage.dart';
import '../../screens/modules/assign_permissions/PermissionsByRolesScreen.dart';
import '../../screens/modules/form_management/FormListScreen.dart';
import '../../screens/modules/form_management/form_submissions_view_screen.dart';
import '../../screens/modules/users_management/users/UserManagementScreen.dart';
import '../../screens/modules/view_users/UserList.dart';
import '../../services/api_session_client_services/SessionManager.dart';
import 'PermissionMenuItem.dart';
import 'drawer_menu_helpers/DrawerMenuNavigationHelper.dart';

class DrawerMenu extends StatefulWidget {
  //INFORMATION VARIABLES AND PERMISSIONS
  final Function(int) onItemTapped;
  final BuildContext parentContext;
  final PermissionSet? permissionSet;
  final Map<String, dynamic>? sessionData;

  const DrawerMenu({
    Key? key,
    required this.onItemTapped,
    required this.parentContext,
    required this.permissionSet,
    required this.sessionData,
  }) : super(key: key);

  @override
  _DrawerMenuState createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  String? _userName;
  String? _userEmail;
  bool _isSuperUser = false;

  @override
  void initState() {
    super.initState();
    _initUserData();
  }

  void _initUserData() {
    if (widget.sessionData != null) {
      setState(() {
        _userName = widget.sessionData!['full_name'] ?? 'NO-DATA-USER';
        _userEmail = widget.sessionData!['email'] ?? 'NO-DATA-USER';
        _isSuperUser = widget.sessionData!['role']?['is_super_user'] ?? false;
      });
    }
  }

  //BUILD WIDGET DRAWER MENU
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(_userName ?? 'NO-DATA-USER'),
              accountEmail: Text(_userEmail ?? 'NO-DATA-USER'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: Color.fromARGB(255, 34, 118, 186),
                ),
              ),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 34, 118, 186),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                'Navigation',
                style: TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 73, 70, 70),
                ),
              ),
            ),
            const Divider(
              color: Colors.grey,
              indent: 10,
              endIndent: 10,
            ),

            //DRAWER MENU OPTIONS
            //1-OPTION HOME
            PermissionMenuItem(
              title: 'Home',
              icon: FontAwesomeIcons.home,
              onTap: () => DrawerMenuNavigationHelper.navigateToHome(
                context: context,
                sessionData: widget.sessionData,
                permissionSet: widget.permissionSet,
              ),
            ),

            // DRAWER MENU USER PERMISSIONS MANAGER
            // //2-OPTION User Management - Visible if 'view_all_users'
            if (_isSuperUser &&
                (widget.permissionSet?.hasPermission('view_all_users') ??
                    false))
              PermissionMenuItem(
                title: 'Users Management',
                icon: FontAwesomeIcons.userGroup,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UsersListScreen(
                        permissionSet: widget.permissionSet!,
                        sessionData: widget.sessionData!,
                      ),
                    ),
                  );
                },
              ),

            // DRAWER MENU USER VIEW USERS
            if (!_isSuperUser &&
                (widget.permissionSet?.hasPermission('view_users') ?? false))
              PermissionMenuItem(
                title: 'View users',
                icon: FontAwesomeIcons.users,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UsersPage(
                        permissionSet: widget.permissionSet!,
                        sessionData: widget.sessionData!,
                      ),
                    ),
                  );
                },
              ),

            // DRAWER MENU PERMISSION-ROLE ASSIGN
            // 6-OPTION Form management - Visible if 'super_user'
            PermissionMenuItem(
              title: 'Assign permissions',
              icon: FontAwesomeIcons.userLock,
              condition: () => _isSuperUser,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PermissionsByRoleScreen(
                      permissionSet: widget.permissionSet!,
                      sessionData: widget.sessionData!,
                    ),
                  ),
                );
              },
            ),

            // DRAWER MENU USER FORM OPTION
            // //4-OPTION Form management - Visible if 'view_forms'
            PermissionMenuItem(
              title: 'Form Management',
              icon: FontAwesomeIcons.fileCircleCheck,
              hasPermission: () =>
                  (widget.permissionSet?.hasPermission('view_forms') ??
                      false) &&
                  (widget.permissionSet?.hasPermission('create_forms') ??
                      false),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormListScreen(
                      permissionSet: widget.permissionSet!,
                      sessionData: widget.sessionData!,
                    ),
                  ),
                );
              },
            ),
    PermissionMenuItem(
    title: 'Form Submission',
    icon: FontAwesomeIcons.clipboardList,
    // Eliminamos condition: () => _isSuperUser,
    hasPermission: () =>
    (widget.permissionSet?.hasPermission('view_submissions') ?? false) &&
    (widget.permissionSet?.hasPermission('create_submissions') ?? false),
    onTap: () {
    Navigator.pushReplacement(
    context,
    MaterialPageRoute(
    builder: (context) => QuestionsAnswerScreen(
    formTitle: 'Form Title',
    formDescription: 'Description of the form',
    permissionSet: widget.permissionSet!,
    sessionData: widget.sessionData!,
    formId: 0,
    ),
    ),
    );
    },
    ),
            PermissionMenuItem(
              title: 'Drafts',
              icon: FontAwesomeIcons.save,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DraftsScreen(
                      permissionSet: widget.permissionSet!,
                      sessionData: widget.sessionData!,
                    ),
                  ),
                );
              },
            ),
            // Logout Option
            PermissionMenuItem(
              title: 'Log Out',
              icon: Icons.logout,
              onTap: () async {
                await SessionManager.clearSession();
                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
            PermissionMenuItem(
              title: 'Form Submissions',
              icon: FontAwesomeIcons.clipboardList,
              hasPermission: () =>
              (widget.permissionSet?.hasPermission('view_submissions') ?? false),
              onTap: () {
                if (widget.sessionData != null && widget.permissionSet != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FormSubmissionsViewScreen(
                        formId: widget.sessionData!['current_form_id'] ?? 0,
                        formTitle: widget.sessionData!['current_form_title'] ?? 'Form Submissions',
                        permissionSet: widget.permissionSet!,
                        sessionData: widget.sessionData!,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}