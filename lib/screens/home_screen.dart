import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:siar/widgets/product_item.dart';
import '../models/product_model.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'Todas'; // Categoría seleccionada
  String selectedState = 'Todos'; // Estado seleccionado
  final TextEditingController _searchController = TextEditingController();

  // Obtiene los productos de Firestore según la categoría seleccionada
  Stream<List<ProductModel>> _getProducts() {
    final collection = FirebaseFirestore.instance.collection('productos');

    Query query = collection;

    // Filtrar por categoría si no es "Todas"
    if (selectedCategory != 'Todas') {
      query = query.where('categoria', isEqualTo: selectedCategory);
    }

    // Filtrar por texto de búsqueda (nombre o etiqueta RFID)
    if (_searchController.text.isNotEmpty) {
      final searchText = _searchController.text.toLowerCase();
      query = query
          .where('nombreProducto', isGreaterThanOrEqualTo: searchText)
          .where('nombreProducto', isLessThanOrEqualTo: searchText + '\uf8ff');
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromDocumentSnapshot(doc))
          .toList();
    });
  }

  void _showSearch() async {
    final String? result = await showSearch(
      context: context,
      delegate: ProductSearchDelegate(),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _searchController.text = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos', style: TextStyle(fontSize: 24)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearch,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de Categorías
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryItem('Todas'),
                  _buildCategoryItem('Electrónica'),
                  _buildCategoryItem('Mobiliario'),
                  _buildCategoryItem('Oficina'),
                ],
              ),
            ),
          ),

          // Lista de Productos Filtrados
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: _getProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('No hay productos registrados'));
                }

                final products = snapshot.data!;
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductItem(
                      name: product.nombreProducto,
                      status: product.estado,
                      color: _getStatusColor(product.estado),
                      imageUrl: product.fotoProducto,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailScreen(product: product),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget de cada categoría
  Widget _buildCategoryItem(String category) {
    final isSelected = selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.secondary
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            category,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Función para asignar colores según estado
  Color _getStatusColor(String estado) {
    switch (estado) {
      case 'Activo':
        return Colors.green;
      case 'Reparación':
        return Colors.yellow;
      case 'Robo':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// Clase separada para el buscador
class ProductSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = ''; // Limpia el texto de búsqueda
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, ''); // Cierra el buscador sin devolver un resultado
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Realiza una consulta a Firestore para buscar productos que coincidan con el texto ingresado
    final collection = FirebaseFirestore.instance.collection('productos');
    final searchQuery = query.toLowerCase();

    return FutureBuilder<QuerySnapshot>(
      future: collection
          .where('nombreProducto', isGreaterThanOrEqualTo: searchQuery)
          .where('nombreProducto', isLessThanOrEqualTo: searchQuery + '\uf8ff')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No se encontraron resultados para "$query"',
              style: const TextStyle(fontSize: 18),
            ),
          );
        }

        final results = snapshot.data!.docs.map((doc) {
          return ProductModel.fromDocumentSnapshot(doc);
        }).toList();

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final product = results[index];
            return ListTile(
              title: Text(product.nombreProducto),
              subtitle: Text(product.estado),
              onTap: () {
                close(
                    context,
                    product
                        .nombreProducto); // Devuelve el nombre del producto seleccionado
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text('Ingresa el nombre o etiqueta RFID para buscar'),
    );
  }
}
