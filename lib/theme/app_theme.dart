import 'package:flutter/material.dart';

class AppTheme {
  // Colores principales
  static const Color primaryColor = Color(0xFF254652); // Verde oscuro
  static const Color secondaryColor = Color(0xFF357E83); // Azul verdoso

  // Colores adicionales
  static const Color lightBlue = Color(0xFF98C0D9); // Azul claro
  static const Color deepBlue = Color(0xFF155F82); // Azul profundo
  static const Color softBeige = Color(0xFFF4EADF); // Beige suave
  // Colores basicos
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;

  static ThemeData get theme {
    return ThemeData(
      colorScheme: ColorScheme(
        primary: primaryColor,
        primaryContainer: primaryColor.withOpacity(0.7),
        secondary: secondaryColor,
        secondaryContainer: secondaryColor.withOpacity(0.7),
        surface: softBeige, // Beige suave como fondo
        error: Colors.red,
        onPrimary: Colors.white, // Texto sobre fondo primario
        onSecondary: Colors.white, // Texto sobre fondo secundario
        onSurface: Colors.black, // Texto en superficies
        onError: Colors.white,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: deepBlue,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: softBeige,
        selectedItemColor: primaryColor,
        unselectedItemColor: secondaryColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
