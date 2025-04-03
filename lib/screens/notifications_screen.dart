import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance
      .ref('alertas/lecturas'); // Ruta en la base de datos
  List<Map<String, dynamic>> _alertas = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    _databaseRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        final List<Map<String, dynamic>> loadedAlertas = [];
        data.forEach((key, value) {
          loadedAlertas.add({
            'id': key,
            'alarma': value['alarma'],
            'dispositivo': value['dispositivo'],
            'timestamp': value['timestamp'],
            'tipo': value['tipo'],
            'ubicacion': value['ubicacion'],
            'uid': value['uid'],
          });
        });

        setState(() {
          _alertas = loadedAlertas;
        });
      }
    });
  }

  void _deleteNotification(String id) {
    // Elimina la notificación de Firebase
    _databaseRef.child(id).remove().then((_) {
      setState(() {
        _alertas.removeWhere((alerta) => alerta['id'] == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notificación eliminada')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
      ),
      body: _alertas.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _alertas.length,
              itemBuilder: (ctx, index) {
                final alerta = _alertas[index];
                return ListTile(
                  title: Text('Dispositivo: ${alerta['dispositivo']}'),
                  subtitle: Text(
                      'Tipo: ${alerta['tipo']} - Ubicación: ${alerta['ubicacion']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      alerta['alarma'] == true
                          ? const Icon(Icons.warning, color: Colors.red)
                          : const Icon(Icons.check_circle, color: Colors.green),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.grey),
                        onPressed: () {
                          _deleteNotification(alerta['id']);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
