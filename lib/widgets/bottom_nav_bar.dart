import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed, // Mostrar etiquetas de forma fija
      showUnselectedLabels: false, // Mostrar etiquetas no seleccionadas
      selectedFontSize: 12, // Tamaño de fuente para ítems seleccionados
      unselectedFontSize: 12, // Tamaño de fuente para ítems no seleccionados
      iconSize: 24, // Tamaño de los íconos
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Estadísticas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: 'Añadir',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none_outlined),
          label: 'Notificaciones',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Cuenta',
        ),
      ],
    );
  }
}
