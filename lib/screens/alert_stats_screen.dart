import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:collection';
import 'package:intl/intl.dart';

class AlertStatsScreen extends StatefulWidget {
  const AlertStatsScreen({super.key});

  @override
  State<AlertStatsScreen> createState() => _AlertStatsScreenState();
}

class _AlertStatsScreenState extends State<AlertStatsScreen> {
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref('alertas/lecturas');
  Map<String, int> _alertasPorDia = {};
  Map<String, int> _alertasPorUbicacion = {};

  @override
  void initState() {
    super.initState();
    _fetchAlertData();
  }

  void _fetchAlertData() {
    _databaseRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        final Map<String, int> porDia = {};
        final Map<String, int> porUbicacion = {};

        data.forEach((key, value) {
          final fecha = value['timestamp'] ?? '';
          final ubicacion = value['ubicacion'] ?? 'desconocido';

          // Convertir timestamp a fecha "yyyy-MM-dd"
          String dia = 'desconocido';
          try {
            final dateTime = DateTime.parse(fecha);
            dia = DateFormat('yyyy-MM-dd').format(dateTime);
          } catch (_) {}

          porDia[dia] = (porDia[dia] ?? 0) + 1;
          porUbicacion[ubicacion] = (porUbicacion[ubicacion] ?? 0) + 1;
        });

        setState(() {
          _alertasPorDia = SplayTreeMap.from(porDia); // ordena por fecha
          _alertasPorUbicacion = porUbicacion;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("📊 Alertas por Día",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 200, child: _BarChartWidget()),
            const SizedBox(height: 30),
            const Text("📍 Alertas por Ubicación",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildUbicacionChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildUbicacionChart() {
    return Column(
      children: _alertasPorUbicacion.entries.map((entry) {
        return ListTile(
          leading: const Icon(Icons.location_on),
          title: Text('${entry.key}'),
          trailing: Text('${entry.value} alertas'),
        );
      }).toList(),
    );
  }

  Widget _BarChartWidget() {
    final barData = _alertasPorDia.entries.map((e) {
      final index = _alertasPorDia.keys.toList().indexOf(e.key);
      return BarChartRodData(toY: e.value.toDouble(), color: Colors.blue);
    }).toList();

    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(show: false),
        barGroups: List.generate(_alertasPorDia.length, (i) {
          return BarChartGroupData(x: i, barRods: [barData[i]]);
        }),
      ),
    );
  }
}
