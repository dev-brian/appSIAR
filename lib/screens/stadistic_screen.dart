import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:siar/services/firestore_service.dart';

class PieChartScreen extends StatefulWidget {
  @override
  _PieChartScreenState createState() => _PieChartScreenState();
}

class _PieChartScreenState extends State<PieChartScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, int> categoryCounts = {};
  List<Map<String, dynamic>> deviceDetails =
      []; // Lista para los detalles de los dispositivos

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  void _fetchStatistics() async {
    final statistics = await _firestoreService.getStatistics();

    Map<String, int> counts = {};
    List<Map<String, dynamic>> details = [];

    for (var stat in statistics) {
      final category = stat['categoria'] ?? 'Desconocido';
      if (counts.containsKey(category)) {
        counts[category] = counts[category]! + 1;
      } else {
        counts[category] = 1;
      }

      // Agregar detalles del dispositivo a la lista
      details.add({
        'nombreProducto': stat['nombreProducto'] ?? 'Desconocido',
        'categoria': category,
        'timestamp': stat['timestamp'] ?? 'Sin fecha',
      });
    }

    setState(() {
      categoryCounts = counts;
      deviceDetails = details; // Actualizar los detalles de los dispositivos
    });
  }

  PieChartSectionData _createPieChartSection(String category, int count) {
    return PieChartSectionData(
      color: _getCategoryColor(category),
      value: count.toDouble(),
      title: '$category\n$count',
      radius: 60,
      titleStyle: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

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

  void _deleteStatistic(Map<String, dynamic> device, int index) async {
    try {
      await _firestoreService.deleteStatistic(
        device['nombreProducto'],
        device['timestamp'],
      );

      setState(() {
        deviceDetails.removeAt(index);
        categoryCounts[device['categoria']] =
            (categoryCounts[device['categoria']] ?? 1) - 1;

        if (categoryCounts[device['categoria']] == 0) {
          categoryCounts.remove(device['categoria']);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registro eliminado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el registro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Distribución de Productos')),
      body: categoryCounts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Gráfica de pastel
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
                      ),
                    ),
                  ),
                ),
                // Lista de detalles de dispositivos
                Expanded(
                  flex: 3,
                  child: ListView.builder(
                    itemCount: deviceDetails.length,
                    itemBuilder: (context, index) {
                      final device = deviceDetails[index];
                      return ListTile(
                        leading: Icon(Icons.devices,
                            color: _getCategoryColor(device['categoria'])),
                        title: Text(device['nombreProducto']),
                        subtitle: Text(
                          'Categoría: ${device['categoria']}\nFecha: ${device['timestamp']}',
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteStatistic(device, index);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
