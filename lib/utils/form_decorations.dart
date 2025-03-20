import 'package:flutter/material.dart';

class FormDecorations {
  // Decoración para campos de texto
  static InputDecoration inputDecoration(String label, bool isEmpty) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      errorText: isEmpty ? 'Este campo es obligatorio' : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  // Decoración para campos de texto con ícono (opcional)
  static InputDecoration inputDecorationWithIcon(
      String label, bool isEmpty, IconData icon) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      errorText: isEmpty ? 'Este campo es obligatorio' : null,
      prefixIcon: Icon(icon),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
