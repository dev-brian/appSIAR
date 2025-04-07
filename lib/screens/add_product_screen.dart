import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:siar/services/firestore_service.dart';
import 'package:siar/services/storage_service.dart';
import '../utils/form_decorations.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // Variable para almacenar la imagen seleccionada
  File? imageToUpload;

  // Controladores para campos de texto
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _idRfidController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _numeroSerieController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();

  // Valores seleccionados para Dropdowns
  String? _selectedCategoria;
  String? _selectedEstado;

  // Opciones de categorías y estados
  static const List<String> categorias = [
    'Electrónica',
    'Mobiliario',
    'Oficina'
  ];
  static const List<String> estados = ['Activo', 'Reparación', 'Robo'];

  // Instancia de FirestoreService
  final FirestoreService _firestoreService = FirestoreService();

  // Clave para el formulario
  final _formKey = GlobalKey<FormState>();

  // Variable para controlar si se intentó enviar el formulario
  bool _formSubmitted = false;

  void _clearFields() {
    // Limpia los controladores de texto
    for (var controller in [
      _descripcionController,
      _idRfidController,
      _marcaController,
      _modeloController,
      _nombreController,
      _numeroSerieController,
      _ubicacionController,
    ]) {
      controller.clear();
    }

    // Restablece los dropdowns y la imagen seleccionada
    setState(() {
      _selectedCategoria = null;
      _selectedEstado = null;
      imageToUpload = null;
      _formSubmitted = false; // Restablece el estado del formulario
    });
  }

  Future<void> _selectImage(ImageSource source) async {
    final XFile? image = await ImagePicker().pickImage(source: source);
    if (image != null) {
      setState(() {
        imageToUpload = File(image.path);
      });
    }
  }

  void _addProduct() async {
    setState(() {
      _formSubmitted = true; // Marca que se intentó enviar el formulario
    });

    if (!_formKey.currentState!.validate()) return;

    try {
      // Subir imagen
      final String? imageUrl = await uploadImage(imageToUpload!);
      if (imageUrl == null) {
        showSnackBar('Error al subir la imagen');
        return;
      }

      // Añadir producto a Firestore
      await _firestoreService.addProduct('productos', {
        'categoria': _selectedCategoria,
        'descripcion': _descripcionController.text,
        'estado': _selectedEstado,
        'fotoProducto': imageUrl,
        'idRfid': _idRfidController.text,
        'marca': _marcaController.text,
        'modelo': _modeloController.text,
        'nombreProducto': _nombreController.text,
        'numeroSerie': _numeroSerieController.text,
        'ubicacion': _ubicacionController.text,
      });

      // Mostrar mensaje de éxito
      if (mounted) {
        showSnackBar('¡Producto registrado exitosamente!');
        _clearFields(); // Limpia los campos y restablece el formulario
      }
    } catch (e) {
      showSnackBar('Error: $e');
    }
  }

  void showSnackBar(String message,
      {Duration duration = const Duration(seconds: 3)}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Producto'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Imagen en un CircleAvatar con botón de edición
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: imageToUpload != null
                        ? FileImage(imageToUpload!) as ImageProvider
                        : const AssetImage('assets/placeholder.png'),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300, // Fondo gris
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.black),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.camera_alt),
                                  title: const Text('Tomar foto'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _selectImage(ImageSource.camera);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.photo),
                                  title:
                                      const Text('Seleccionar de la galería'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _selectImage(ImageSource.gallery);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 16),

              // Campos de texto reutilizables
              _buildTextField(_nombreController, 'Nombre del Producto'),

              _buildTextField(_marcaController, 'Marca'),
              _buildTextField(_modeloController, 'Modelo'),

              // Dropdown de Categoría
              DropdownButtonFormField<String>(
                value: _selectedCategoria,
                decoration: FormDecorations.inputDecoration('Categoría', false),
                isExpanded: true,
                hint: const Text('Selecciona una categoría'),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategoria = newValue;
                  });
                },
                items: categorias.map((categoria) {
                  return DropdownMenuItem(
                    value: categoria,
                    child: Text(categoria),
                  );
                }).toList(),
                validator: (value) {
                  if (_formSubmitted && value == null) {
                    return 'Selecciona una categoría';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(_numeroSerieController, 'Número de Serie'),
              _buildTextField(_ubicacionController, 'Ubicación'),

              // Dropdown de Estado
              DropdownButtonFormField<String>(
                value: _selectedEstado,
                decoration: FormDecorations.inputDecoration('Estado', false),
                isExpanded: true,
                hint: const Text('Selecciona un estado'),
                onChanged: (newValue) {
                  setState(() {
                    _selectedEstado = newValue;
                  });
                },
                items: estados.map((estado) {
                  return DropdownMenuItem(
                    value: estado,
                    child: Text(estado),
                  );
                }).toList(),
                validator: (value) {
                  if (_formSubmitted && value == null) {
                    return 'Selecciona un estado';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(_idRfidController, 'ID RFID'),
              _buildTextField(_descripcionController, 'Descripción'),
              const SizedBox(height: 16),
              // Botón para añadir producto
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (imageToUpload == null) {
                      showSnackBar('Por favor selecciona una imagen');
                      return;
                    }
                    _addProduct();
                  },
                  child: const Text('Añadir Producto'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: FormDecorations.inputDecoration(
            label, _formSubmitted && controller.text.isEmpty),
        validator: (value) {
          if (_formSubmitted && (value == null || value.isEmpty)) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    // Libera memoria de los controladores
    for (var controller in [
      _descripcionController,
      _idRfidController,
      _marcaController,
      _modeloController,
      _nombreController,
      _numeroSerieController,
      _ubicacionController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }
}
