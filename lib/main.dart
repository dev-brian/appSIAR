import 'package:flutter/material.dart';
import 'package:app_siar/screens/home_screen.dart'; // Asegúrate de importar home_screen.dart

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(), // Cambia esto a HomeScreen
    );
  }
}
