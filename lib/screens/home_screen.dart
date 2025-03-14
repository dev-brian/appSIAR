import 'package:flutter/material.dart';

class Product {
  final String name;
  final String status;
  final Color statusColor;
  final bool hasInfo;

  Product({
    required this.name,
    required this.status,
    required this.statusColor,
    this.hasInfo = true,
  });

}

class Category {
  final String name;

  Category({required this.name});
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Lista de categorías
  final List<Category> categories = [
    Category(name: 'Electrónica'),
    Category(name: 'Mobiliario'),
    Category(name: 'Oficina'),
  ];

  // Lista de productos
  final List<Product> products = [
    Product(
        name: 'Guillotina',
        status: 'Estado: Activo',
        statusColor: Colors.green),
    Product(
        name: 'Impresora Canon',
        status: 'Estado: Activo',
        statusColor: Colors.green),
    Product(
        name: 'Control Xbox 1',
        status: 'Estado: Roto',
        statusColor: Colors.red),
    Product(
        name: 'Encuadernadora',
        status: 'Estado: Reparación',
        statusColor: Colors.orange),
  ];

  static const List<Widget> _widgetOptions = <Widget>[
    Text('Home Screen'),
    Text('Estadísticas'),
    Text('Añadir'),
    Text('Notificaciones'),
    Text('Cuenta'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.home, color: Color(0xFF155f82)),
            SizedBox(width: 8),
            Text(
              'Hola Rosie!',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.grey[300], // Espacio de imagen temporal
            radius: 18,
          ),
          SizedBox(width: 16),
        ],
      ),
      body: _selectedIndex == 0
          ? _buildHomeContent()
          : Center(
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Estadísticas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle, size: 30), label: 'Añadir'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Notificaciones'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'Cuenta'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF155f82),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra de búsqueda
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  Icon(Icons.tune, color: Colors.grey),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Categorías
            Container(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Column(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF155f82),
                          ),
                          child: ClipOval(
                            child: Container(
                              color: Colors
                                  .grey[300], // Espacio de imagen temporal
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          categories[index].name,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 16),

            // Productos
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return _buildProductCard(products[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del producto (reemplazada por un contenedor gris)
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            child: Container(
              height: 120,
              width: double.infinity,
              color: Colors.grey[300], // Espacio de imagen temporal
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      product.status,
                      style:
                          TextStyle(color: product.statusColor, fontSize: 12),
                    ),
                    Spacer(),
                    if (product.hasInfo)
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.info_outline,
                            size: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
