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

          // Convertir timestamp a fecha
          String dia = 'desconocido';
          try {
            final dateTime = DateTime.parse(fecha);
            dia = DateFormat('yyyy-MM-dd').format(dateTime);
          } catch (_) {}

          porDia[dia] = (porDia[dia] ?? 0) + 1;
          porUbicacion[ubicacion] = (porUbicacion[ubicacion] ?? 0) + 1;
        });

        setState(() {
          _alertasPorDia = SplayTreeMap.from(porDia);
          _alertasPorUbicacion = porUbicacion;
        });
      }
    });
  }

  Color _getBarColor(int value) {
    if (value <= 2) return Colors.green;
    if (value <= 5) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final totalAlertas = _alertasPorDia.values.fold(0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📋 Total de Alertas: $totalAlertas',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            const Text("📊 Alertas por Día",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 250, child: _BarChartWidget()),
            const SizedBox(height: 10),
            _buildLegend(),
            const SizedBox(height: 30),
            const Text("📍 Alertas por Ubicación",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(height: 250, child: _PieChartWidget()),
            const SizedBox(height: 20),
            _buildUbicacionList(),
          ],
        ),
      ),
    );
  }

  Widget _BarChartWidget() {
    final keys = _alertasPorDia.keys.toList();
    final values = _alertasPorDia.values.toList();

    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            //tooltipBackgroundColor: Colors.black87,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final fecha = keys[group.x.toInt()];
              final cantidad = rod.toY.toInt();
              return BarTooltipItem(
                '$fecha\n$cantidad alertas',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < keys.length) {
                  return Text(
                    keys[value.toInt()],
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        barGroups: List.generate(_alertasPorDia.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: values[i].toDouble(),
                color: _getBarColor(values[i]),
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
      ),
      swapAnimationDuration: const Duration(milliseconds: 600),
      swapAnimationCurve: Curves.easeOut,
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _LegendItem(color: Colors.green, label: 'Bajo'),
        SizedBox(width: 10),
        _LegendItem(color: Colors.orange, label: 'Medio'),
        SizedBox(width: 10),
        _LegendItem(color: Colors.red, label: 'Alto'),
      ],
    );
  }

  Widget _PieChartWidget() {
    if (_alertasPorUbicacion.isEmpty) return const Text("No hay datos.");

    final total =
        _alertasPorUbicacion.values.fold(0, (a, b) => a + b).toDouble();
    final keys = _alertasPorUbicacion.keys.toList();

    return PieChart(
      PieChartData(
        sections: _alertasPorUbicacion.entries.map((entry) {
          final index = keys.indexOf(entry.key);
          final value = entry.value.toDouble();
          final percentage = (value / total * 100).toStringAsFixed(1);
          return PieChartSectionData(
            value: value,
            title: '${entry.key}\n$percentage%',
            color: Colors.primaries[index % Colors.primaries.length],
            radius: 60,
            titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
          );
        }).toList(),
        sectionsSpace: 4,
        centerSpaceRadius: 30,
      ),
    );
  }

  Widget _buildUbicacionList() {
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
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
