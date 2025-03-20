import 'package:flutter/material.dart';
import 'package:siar/services/firestore_service.dart';
import '../models/product_model.dart';
import 'edit_product_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  ProductDetailScreenState createState() => ProductDetailScreenState();
}

class ProductDetailScreenState extends State<ProductDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  late ProductModel _currentProduct;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
  }

  void _deleteProduct(String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content:
              const Text('¿Estás seguro de que deseas eliminar este producto?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cierra el modal
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _firestoreService.deleteProduct('productos', docId);
                if (mounted) {
                  Navigator.of(context).pop(); // Cierra el modal
                  Navigator.of(context).pop(); // Regresa a la pantalla anterior
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentProduct.nombreProducto),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 80,
                  backgroundImage: NetworkImage(_currentProduct.fotoProducto),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Detalles del Producto',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildDetailItem('Categoría', _currentProduct.categoria),
              _buildDetailItem('Descripción', _currentProduct.descripcion),
              _buildDetailItem('Estado', _currentProduct.estado),
              _buildDetailItem('Marca', _currentProduct.marca),
              _buildDetailItem('Modelo', _currentProduct.modelo),
              _buildDetailItem('Número de Serie', _currentProduct.numeroSerie),
              _buildDetailItem('Ubicación', _currentProduct.ubicacion),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _deleteProduct(widget.product.id);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Eliminar'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              EditProductScreen(product: _currentProduct),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
