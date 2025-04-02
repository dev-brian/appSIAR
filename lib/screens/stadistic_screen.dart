import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartScreen extends StatefulWidget {
  @override
  _PieChartScreenState createState() => _PieChartScreenState();
}

class _PieChartScreenState extends State<PieChartScreen> {
  // Lista de productos simulados
  List<Map<String, String>> productos = [
    {
      'nombre': 'Laptop',
      'categoria': 'Electrónica',
      'descripcion': 'Laptop de 15 pulgadas'
    },
    {
      'nombre': 'Smartphone',
      'categoria': 'Electrónica',
      'descripcion': 'Smartphone con cámara 4K'
    },
    {
      'nombre': 'Silla de oficina',
      'categoria': 'Oficina',
      'descripcion': 'Silla ergonómica con respaldo'
    },
    {
      'nombre': 'Mesa de trabajo',
      'categoria': 'Oficina',
      'descripcion': 'Mesa de escritorio de madera'
    },
    {
      'nombre': 'Televisor',
      'categoria': 'Electrónica',
      'descripcion': 'Televisor 4K de 55 pulgadas'
    },
    {
      'nombre': 'Sofa',
      'categoria': 'Mobiliario',
      'descripcion': 'Sofá de tres plazas color gris'
    },
    {
      'nombre': 'Lámpara',
      'categoria': 'Mobiliario',
      'descripcion': 'Lámpara de pie con base de mármol'
    },
    {
      'nombre': 'Impresora',
      'categoria': 'Oficina',
      'descripcion': 'Impresora láser color'
    },
    {
      'nombre': 'Auriculares',
      'categoria': 'Electrónica',
      'descripcion': 'Auriculares inalámbricos'
    },
    {
      'nombre': 'Escritorio',
      'categoria': 'Oficina',
      'descripcion': 'Escritorio de madera con cajones'
    },
  ];

  // Lista para almacenar el conteo de productos por categoría
  Map<String, int> categoryCounts = {};

  @override
  void initState() {
    super.initState();
    _countCategories();
  }

  // Función para contar los productos por categoría en la lista local
  void _countCategories() {
    Map<String, int> counts = {};

    for (var product in productos) {
      String category = product['categoria']!;
      if (category == 'Electrónica' ||
          category == 'Mobiliario' ||
          category == 'Oficina') {
        if (counts.containsKey(category)) {
          counts[category] = counts[category]! + 1;
        } else {
          counts[category] = 1;
        }
      }
    }

    setState(() {
      categoryCounts = counts;
    });
  }

  // Función para construir la gráfica de pastel
  PieChartSectionData _createPieChartSection(String category, int count) {
    return PieChartSectionData(
      color: _getCategoryColor(category),
      value: count.toDouble(),
      title: '$category\n$count',
      radius: 60, // Hacer la gráfica más grande
      titleStyle: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  // Asignar un color único a cada categoría
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Electrónica':
        return Colors.blue;
      case 'Mobiliario':
        return Colors.green;
      case 'Oficina':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Navegar a la pantalla con detalles de los productos por categoría
  void _navigateToProductDetails(String category) {
    final filteredProducts =
        productos.where((product) => product['categoria'] == category).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListScreen(
          category: category,
          products: filteredProducts,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Distribución de Productos')),
      body: Column(
        children: [
          // Gráfico de pastel
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: PieChart(
                PieChartData(
                  sections: categoryCounts.entries.map((entry) {
                    return _createPieChartSection(entry.key, entry.value);
                  }).toList(),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 50,
                  pieTouchData: PieTouchData(
                    touchCallback:
                        (FlTouchEvent event, PieTouchResponse? touchResponse) {
                      if (touchResponse != null &&
                          touchResponse.touchedSection != null) {
                        final touchedSection = touchResponse.touchedSection;
                        final touchedCategory =
                            touchedSection?.title?.split('\n')[0] ?? '';
                        if (touchedCategory.isNotEmpty) {
                          _navigateToProductDetails(touchedCategory);
                        }
                      }
                    },
                  ),
                ),
              ),
            ),
          ),

          // Lista de productos con intentos de robo
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Productos con intentos de robo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: productos.length,
                      itemBuilder: (context, index) {
                        final product = productos[index];
                        return ListTile(
                          title: Text(product['nombre']!),
                          subtitle: Text(product['categoria']!),
                          onTap: () {
                            // Acción al tocar un producto
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension on PieTouchedSection? {
  get title => null;
}

class ProductListScreen extends StatelessWidget {
  final String category;
  final List<Map<String, String>> products;

  const ProductListScreen(
      {Key? key, required this.category, required this.products})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Productos de $category')),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            title: Text(product['nombre']!),
            subtitle: Text(product['descripcion']!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(product: product),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ProductDetailScreen extends StatelessWidget {
  final Map<String, String> product;

  const ProductDetailScreen({Key? key, required this.product})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product['nombre']!)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre: ${product['nombre']}'),
            Text('Categoría: ${product['categoria']}'),
            Text('Descripción: ${product['descripcion']}'),
            // Agregar más detalles si es necesario
          ],
        ),
      ),
    );
  }
}
