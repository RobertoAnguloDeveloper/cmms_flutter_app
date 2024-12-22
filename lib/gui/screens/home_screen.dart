// 📂 lib/gui/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_services/auth_provider.dart';
import '../components/app_drawer.dart';
import '../components/screen_scaffold.dart';
import 'auth/login_screen.dart';
import 'env_theme_config_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<DrawerItem> _buildDrawerItems(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;
    final isAdmin = currentUser?.id == 1;

    final List<DrawerItem> items = [
      DrawerItem(
        title: 'Dashboard',
        icon: Icons.dashboard,
        selected: _selectedIndex == 0,
        onTap: () => _onItemSelected(0),
      ),
      DrawerItem(
        title: 'Forms',
        icon: Icons.assignment,
        selected: _selectedIndex == 1,
        onTap: () => _onItemSelected(1),
      ),
      DrawerItem(
        title: 'Submissions',
        icon: Icons.fact_check,
        selected: _selectedIndex == 2,
        onTap: () => _onItemSelected(2),
      ),
      DrawerItem(
        title: 'Users',
        icon: Icons.people,
        selected: _selectedIndex == 3,
        onTap: () => _onItemSelected(3),
      ),
    ];

    // Add Environment Theme Configuration only for admin user
    if (isAdmin) {
      items.add(
        DrawerItem(
          title: 'Environment Theme',
          icon: Icons.palette,
          selected: _selectedIndex == 4,
          onTap: () => _onItemSelected(4),
        ),
      );

      items.add(
        DrawerItem(
          title: 'Settings',
          icon: Icons.settings,
          selected: _selectedIndex == 5,
          onTap: () => _onItemSelected(5),
        ),
      );
    } else {
      items.add(
        DrawerItem(
          title: 'Settings',
          icon: Icons.settings,
          selected: _selectedIndex == 4,
          onTap: () => _onItemSelected(4),
        ),
      );
    }

    // Add Logout as the last item
    items.add(
      DrawerItem(
        title: 'Logout',
        icon: Icons.logout,
        onTap: () => _handleLogout(context),
      ),
    );

    return items;
  }

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Close drawer on mobile
    Navigator.of(context).pop();
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  Widget _buildDashboardContent() {
    return const Center(
      child: Text(
        'Dashboard Content',
        style: TextStyle(fontSize: 24),
      ),
    );
  }

  Widget _buildFormsContent() {
    return const Center(
      child: Text(
        'Forms Content',
        style: TextStyle(fontSize: 24),
      ),
    );
  }

  Widget _buildSubmissionsContent() {
    return const Center(
      child: Text(
        'Submissions Content',
        style: TextStyle(fontSize: 24),
      ),
    );
  }

  Widget _buildUsersContent() {
    return const Center(
      child: Text(
        'Users Content',
        style: TextStyle(fontSize: 24),
      ),
    );
  }

  Widget _buildSettingsContent() {
    return const Center(
      child: Text(
        'Settings Content',
        style: TextStyle(fontSize: 24),
      ),
    );
  }

  Widget _buildContent() {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.currentUser?.id == 1;

    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return _buildFormsContent();
      case 2:
        return _buildSubmissionsContent();
      case 3:
        return _buildUsersContent();
      case 4:
      // For admin users, index 4 is Environment Theme
      // For regular users, index 4 is Settings
        if (isAdmin) {
          return const EnvThemeConfigScreen();
        } else {
          return _buildSettingsContent();
        }
      case 5:
      // Only admin users will have index 5 (Settings)
        if (isAdmin) {
          return _buildSettingsContent();
        }
        // Fall through to default if not admin
        return _buildDashboardContent();
      default:
        return _buildDashboardContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    return ScreenScaffold(
      title: 'CMMS App',
      drawer: AppDrawer(
        headerWidget: UserAccountsDrawerHeader(
          accountName: Text(
            '${currentUser?.firstName ?? ''} ${currentUser?.lastName ?? ''}',
          ),
          accountEmail: Text(currentUser?.email ?? ''),
          currentAccountPicture: CircleAvatar(
            child: Text(
              (currentUser?.firstName.isNotEmpty == true
                  ? currentUser!.firstName[0]
                  : 'U').toUpperCase(),
            ),
          ),
        ),
        items: _buildDrawerItems(context),
      ),
      body: _buildContent(),
    );
  }
}