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

  bool _isUsersExpanded = false;
  bool _isFormsExpanded = false;

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

  bool _hasAnyUserPermission() {
    return _isSuperUser || (widget.permissionSet?.hasPermission('view_users') ?? false);
  }

  bool _hasAnyFormPermission() {
    return (widget.permissionSet?.hasPermission('view_forms') ?? false) ||
        (widget.permissionSet?.hasPermission('create_forms') ?? false) ||
        (widget.permissionSet?.hasPermission('view_form_submissions') ?? false) ||
        (widget.permissionSet?.hasPermission('create_form_submissions') ?? false);
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
            const Divider(color: Colors.grey, indent: 10, endIndent: 10),

            // DRAWER MENU OPTIONS
            // 1-OPTION HOME
            PermissionMenuItem(
              title: 'HOME',
              icon: FontAwesomeIcons.home,
              onTap: () => DrawerMenuNavigationHelper.navigateToHome(
                context: context,
                sessionData: widget.sessionData,
                permissionSet: widget.permissionSet,
              ),
            ),

            // CATEGORÍA DE USUARIOS
            if (_hasAnyUserPermission()) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  setState(() {
                    _isUsersExpanded = !_isUsersExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.users,
                        size: 20,
                        color: const Color.fromARGB(255, 34, 118, 186),
                      ),
                      const SizedBox(width: 32),
                      const Text(
                        'USERS',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(255, 73, 70, 70),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        _isUsersExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: const Color.fromARGB(255, 73, 70, 70),
                      ),
                    ],
                  ),
                ),
              ),

              // Submenú de USERS con estilo mejorado
              if (_isUsersExpanded) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: const Color(0xFFE0E5ED), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // OPCIÓN: User Management (superusuarios con permiso view_users)
                      if (_isSuperUser && (widget.permissionSet?.hasPermission('view_users') ?? false))
                        PermissionMenuItem(
                          title: 'Users Management',
                          icon: FontAwesomeIcons.userGroup,
                          indent: 8.0,
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

                      // OPCIÓN: View Users (usuarios no superusuarios con permiso view_users)
                      if (!_isSuperUser && (widget.permissionSet?.hasPermission('view_users') ?? false))
                        PermissionMenuItem(
                          title: 'View users',
                          icon: FontAwesomeIcons.users,
                          indent: 8.0,
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

                      // OPCIÓN: Assign Permissions (solo superusuarios)
                      PermissionMenuItem(
                        title: 'Assign permissions',
                        icon: FontAwesomeIcons.userLock,
                        condition: () => _isSuperUser,
                        indent: 8.0,
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
                    ],
                  ),
                ),
              ],
            ],

            // CATEGORÍA DE FORMULARIOS
            if (_hasAnyFormPermission()) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  setState(() {
                    _isFormsExpanded = !_isFormsExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.fileAlt,
                        size: 20,
                        color: const Color.fromARGB(255, 34, 118, 186),
                      ),
                      const SizedBox(width: 32),
                      const Text(
                        'FORMS',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(255, 73, 70, 70),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        _isFormsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: const Color.fromARGB(255, 73, 70, 70),
                      ),
                    ],
                  ),
                ),
              ),

              // Submenú de FORMS con estilo mejorado
              if (_isFormsExpanded) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: const Color(0xFFE0E5ED), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // OPCIÓN: Form Management
                      PermissionMenuItem(
                        title: 'Form Designer',
                        icon: FontAwesomeIcons.fileCircleCheck,
                        indent: 8.0,
                        hasPermission: () =>
                        (widget.permissionSet?.hasPermission('view_forms') ?? false) &&
                            (widget.permissionSet?.hasPermission('create_forms') ?? false),
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

                      // OPCIÓN: Form Submission
                      PermissionMenuItem(
                        title: 'Submit Forms',
                        icon: FontAwesomeIcons.clipboardList,
                        indent: 8.0,
                        hasPermission: () =>
                        (widget.permissionSet?.hasPermission('view_form_submissions') ?? false) &&
                            (widget.permissionSet?.hasPermission('create_form_submissions') ?? false),
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

                      // OPCIÓN: View Form
                      PermissionMenuItem(
                        title: 'View Submissions',
                        icon: FontAwesomeIcons.clipboardCheck,
                        indent: 8.0,
                        hasPermission: () =>
                        (widget.permissionSet?.hasPermission('view_form_submissions') ?? false),
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
              ],
            ],

            // DRAFTS como módulo independiente
            const SizedBox(height: 8),
            PermissionMenuItem(
              title: 'DRAFTS',
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

            const SizedBox(height: 16),
            const Divider(color: Colors.grey, indent: 10, endIndent: 10),

            // OPCIÓN: Log Out (siempre visible)
            PermissionMenuItem(
              title: 'LOG OUT',
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
          ],
        ),
      ),
    );
  }
}