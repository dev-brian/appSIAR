import 'package:flutter/material.dart';

class FormValidations {
  static bool validateFields({
    required BuildContext context,
    required String categoria,
    required String estado,
    required String nombre,
    required String descripcion,
    required String idRfid,
    required String marca,
    required String modelo,
    required String numeroSerie,
    required String ubicacion,
  }) {
    if (nombre.isEmpty) {
      _showSnackBar(context, 'El nombre es obligatorio');
      return false;
    }

    if (categoria.isEmpty) {
      _showSnackBar(context, 'La categoría es obligatoria');
      return false;
    }

    if (estado.isEmpty) {
      _showSnackBar(context, 'El estado es obligatorio');
      return false;
    }

    if (descripcion.isEmpty) {
      _showSnackBar(context, 'La descripción es obligatoria');
      return false;
    }

    if (marca.isEmpty) {
      _showSnackBar(context, 'La marca es obligatoria');
      return false;
    }

    if (modelo.isEmpty) {
      _showSnackBar(context, 'El modelo es obligatorio');
      return false;
    }

    if (numeroSerie.isEmpty) {
      _showSnackBar(context, 'El número de serie es obligatorio');
      return false;
    }

    if (ubicacion.isEmpty) {
      _showSnackBar(context, 'La ubicación es obligatoria');
      return false;
    }

    return true; // Todos los campos son válidos
  }

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
