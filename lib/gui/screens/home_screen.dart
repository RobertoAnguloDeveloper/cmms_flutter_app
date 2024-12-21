// 📂 lib/gui/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_services/auth_provider.dart';
import '../components/app_drawer.dart';
import '../components/screen_scaffold.dart';
import 'auth/login_screen.dart';

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

    return [
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
      DrawerItem(
        title: 'Settings',
        icon: Icons.settings,
        selected: _selectedIndex == 4,
        onTap: () => _onItemSelected(4),
      ),
      DrawerItem(
        title: 'Logout',
        icon: Icons.logout,
        onTap: () => _handleLogout(context),
      ),
    ];
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

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const Center(child: Text('Dashboard Content'));
      case 1:
        return const Center(child: Text('Forms Content'));
      case 2:
        return const Center(child: Text('Submissions Content'));
      case 3:
        return const Center(child: Text('Users Content'));
      case 4:
        return const Center(child: Text('Settings Content'));
      default:
        return const Center(child: Text('Dashboard Content'));
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