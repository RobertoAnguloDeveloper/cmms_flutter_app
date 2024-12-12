import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  final String name;
  final VoidCallback onView;
  final Icon icon;
  final bool isDeleted;

  const ListItem({
    Key? key,
    required this.name,
    required this.onView,
    required this.icon,
    this.isDeleted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: isDeleted
          ? Colors.grey[300] // Fondo más oscuro si está eliminado
          : Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isDeleted
              ? Colors.grey // Borde gris si está eliminado
              : Color.fromARGB(255, 125, 208, 244),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        onTap: onView, // Acción al hacer clic
        splashColor:
            Colors.blue.withOpacity(0.2), // Color de la animación de selección
        highlightColor:
            Colors.blue.withOpacity(0.1), // Color del efecto de presión
        borderRadius:
            BorderRadius.circular(8.0), // Asegura que el efecto siga el borde
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isDeleted
                  ? Colors.grey // Fondo gris del ícono si está eliminado
                  : Color.fromARGB(255, 34, 118, 186),
              child: icon,
            ),
            title: Text(
              isDeleted ? "$name (Deleted)" : name,
              style: TextStyle(
                color: isDeleted ? Colors.red : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
