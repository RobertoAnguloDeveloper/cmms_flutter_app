import 'package:flutter/material.dart';

import '../../models/Permission_set.dart';

class BottomNavigationMenu extends StatefulWidget {
  final int selectedIndex;
  final Map<String, dynamic> sessionData;
  final PermissionSet permissionSet;
  final Function(int) onItemTapped;

  const BottomNavigationMenu({
    Key? key,
    required this.selectedIndex,
    required this.sessionData,
    required this.permissionSet,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  _BottomNavigationMenuState createState() => _BottomNavigationMenuState();
}

class _BottomNavigationMenuState extends State<BottomNavigationMenu> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; // Ancho de la pantalla
    final textScaleFactor = screenWidth > 600
        ? 1.2 // Escala para pantallas más grandes (e.g., tabletas)
        : 0.9; // Escala para pantallas más pequeñas (e.g., teléfonos)

    return Row(
      children: [
        buildNavBarItem(0, Icons.person, 'Users', textScaleFactor),
        buildNavBarItem(1, Icons.diversity_3, 'Roles', textScaleFactor),
        buildNavBarItem(2, Icons.location_city, 'Environment', textScaleFactor),
        buildNavBarItem(3, Icons.lock, 'Permissions', textScaleFactor),
      ],
    );
  }

  Widget buildNavBarItem(int index, IconData icon, String label, double textScaleFactor) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          widget.onItemTapped(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 90.0,
          color: _selectedIndex == index
              ? const Color.fromARGB(255, 34, 118, 186)
              : Colors.white,
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 42.0,
                color: _selectedIndex == index ? Colors.white : Colors.grey,
              ),
              const SizedBox(height: 1.0),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1, // Limitar a una línea
                overflow: TextOverflow.ellipsis, // Mostrar puntos suspensivos si el texto es muy largo
                style: TextStyle(
                  fontSize: 13 * textScaleFactor, // Ajustar tamaño de fuente
                  fontWeight: FontWeight.bold,
                  color: _selectedIndex == index ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
