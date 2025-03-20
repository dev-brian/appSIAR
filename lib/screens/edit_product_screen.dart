import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:siar/services/firestore_service.dart';
import 'package:siar/services/storage_service.dart';
import '../models/product_model.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel product;

  const EditProductScreen({super.key, required this.product});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  final _formKey = GlobalKey<FormState>();
  bool _formSubmitted = false;

  late final TextEditingController _descripcionController;
  late final TextEditingController _estadoController;
  late final TextEditingController _idRfidController;
  late final TextEditingController _marcaController;
  late final TextEditingController _modeloController;
  late final TextEditingController _nombreController;
  late final TextEditingController _numeroSerieController;
  late final TextEditingController _ubicacionController;

  String? _selectedCategoria;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();

    // Inicializar controladores con los valores actuales del producto
    _selectedCategoria = widget.product.categoria;
    _descripcionController =
        TextEditingController(text: widget.product.descripcion);
    _estadoController = TextEditingController(text: widget.product.estado);
    _idRfidController = TextEditingController(text: widget.product.idRfid);
    _marcaController = TextEditingController(text: widget.product.marca);
    _modeloController = TextEditingController(text: widget.product.modelo);
    _nombreController =
        TextEditingController(text: widget.product.nombreProducto);
    _numeroSerieController =
        TextEditingController(text: widget.product.numeroSerie);
    _ubicacionController =
        TextEditingController(text: widget.product.ubicacion);
  }

  @override
  void dispose() {
    // Liberar memoria de los controladores
    _descripcionController.dispose();
    _estadoController.dispose();
    _idRfidController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _nombreController.dispose();
    _numeroSerieController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }

  Future<void> _selectImage(ImageSource source) async {
    final XFile? image = await ImagePicker().pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _updateProduct(String docId) async {
    setState(() {
      _formSubmitted = true; // Marca que se intentó enviar el formulario
    });

    if (!_formKey.currentState!.validate()) return;

    String? imageUrl = widget.product.fotoProducto;

    // Si se seleccionó una nueva imagen, súbela
    if (_selectedImage != null) {
      imageUrl = await uploadImage(_selectedImage!);
    }

    // Actualizar el producto en Firestore
    await _firestoreService.updateProduct('productos', docId, {
      'categoria': _selectedCategoria,
      'descripcion': _descripcionController.text,
      'estado': _estadoController.text,
      'fotoProducto':
          imageUrl, // Mantén la imagen actual si no se seleccionó una nueva
      'idRfid': _idRfidController.text,
      'marca': _marcaController.text,
      'modelo': _modeloController.text,
      'nombreProducto': _nombreController.text,
      'numeroSerie': _numeroSerieController.text,
      'ubicacion': _ubicacionController.text,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto editado exitosamente')),
      );
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Producto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!) as ImageProvider
                        : NetworkImage(widget.product.fotoProducto),
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
              DropdownButtonFormField<String>(
                value: _estadoController.text.isNotEmpty
                    ? _estadoController.text
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
                items: ['Activo', 'Reparación', 'Robo'].map((estado) {
                  return DropdownMenuItem(
                    value: estado,
                    child: Text(estado),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _estadoController.text = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategoria,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
                isExpanded: true,
                hint: const Text('Selecciona una categoría'),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategoria = newValue;
                  });
                },
                items:
                    ['Electrónica', 'Mobiliario', 'Oficina'].map((categoria) {
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
              _buildTextField(_nombreController, 'Nombre'),
              _buildTextField(_descripcionController, 'Descripción'),
              _buildTextField(_marcaController, 'Marca'),
              _buildTextField(_modeloController, 'Modelo'),
              _buildTextField(_numeroSerieController, 'Número de Serie'),
              _buildTextField(_ubicacionController, 'Ubicación'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _updateProduct(widget.product.id); // Actualiza el producto
                },
                child: const Text('Guardar'),
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
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (_formSubmitted && (value == null || value.isEmpty)) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
      ),
    );
  }
}
