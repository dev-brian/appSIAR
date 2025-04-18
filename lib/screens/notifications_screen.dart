import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:siar/services/firestore_service.dart';
import 'dart:async';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance
      .ref('alertas/lecturas'); // Ruta en la base de datos
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _alertas = [];
  StreamSubscription<DatabaseEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    _subscription = _databaseRef.onValue.listen((event) async {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        final List<Map<String, dynamic>> loadedAlertas = [];

        for (var entry in data.entries) {
          final key = entry.key;
          final value = entry.value;

          // Verifica si ya se procesó esta alerta
          if (loadedAlertas.any((alerta) => alerta['id'] == key)) {
            continue; // Si ya existe, omite esta entrada
          }

          // Buscar el producto relacionado en Firestore
          final product =
              await _firestoreService.getProductByRfid(value['uid']);

          final alertData = {
            'id': key,
            'alarma': value['alarma'],
            'dispositivo': value['dispositivo'],
            'timestamp': value['timestamp'],
            'tipo': value['tipo'],
            'ubicacion': value['ubicacion'],
            'uid': value['uid'],
            'nombreProducto': product?['nombreProducto'] ?? 'Desconocido',
            'categoria': product?['categoria'] ?? 'Desconocido',
          };

          // Agregar alerta a Firestore
          await _firestoreService.addAlertToFirestore(value['uid'], alertData);

          loadedAlertas.add(alertData);
        }

        setState(() {
          _alertas = loadedAlertas;
        });
      }
    });
  }

  @override
  void dispose() {
    // Cancelar la suscripción a Firebase
    _subscription?.cancel();
    super.dispose();
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

  void _showProductDetails(String uid) async {
    // Busca el producto relacionado en Firestore
    final product = await _firestoreService.getProductByRfid(uid);

    if (product != null) {
      // Muestra los detalles del producto en un cuadro de diálogo
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Detalles del Producto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nombre: ${product['nombreProducto']}'),
              Text('Marca: ${product['marca']}'),
              Text('Modelo: ${product['modelo']}'),
              Text('Ubicación: ${product['ubicacion']}'),
              Text('Estado: ${product['estado']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    } else {
      // Si no se encuentra el producto, muestra un mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto no encontrado')),
      );
    }
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
                return ExpansionTile(
                  title: Text('Producto: ${alerta['nombreProducto']}'),
                  subtitle: Text('Ubicación: ${alerta['ubicacion']}'),
                  trailing: alerta['alarma'] == true
                      ? const Icon(Icons.warning, color: Colors.red)
                      : const Icon(Icons.check_circle, color: Colors.green),
                  children: [
                    ListTile(
                      title: const Text('Detalles'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('UID: ${alerta['uid']}'),
                          Text('Hora: ${alerta['timestamp']}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.info, color: Colors.blue),
                            onPressed: () {
                              _showProductDetails(alerta['uid']);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.grey),
                            onPressed: () {
                              _deleteNotification(alerta['id']);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
