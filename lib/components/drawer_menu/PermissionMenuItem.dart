import 'package:flutter/material.dart';

class PermissionMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool Function()? hasPermission; 
  final bool Function()? condition;    
  final VoidCallback onTap;

  const PermissionMenuItem({
    Key? key,
    required this.title,
    required this.icon,
    this.hasPermission,
    this.condition,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if ((hasPermission != null && !(hasPermission!())) || 
        (condition != null && !(condition!()))) {
      return const SizedBox.shrink();
    }

    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          color: Color.fromARGB(255, 73, 70, 70),
        ),
      ),
      leading: Icon(
        icon,
        size: 24,
        color: const Color.fromARGB(255, 34, 118, 186),
      ),
      onTap: onTap,
    );
  }
}
