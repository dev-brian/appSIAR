import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:siar/models/product_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory FirestoreService() {
    return _instance;
  }

  FirestoreService._internal();

  Stream<List<ProductModel>> getProduct(String collection) {
    return _firestore.collection(collection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromDocumentSnapshot(doc))
          .toList();
    });
  }

  Future<void> updateProduct(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) {
    return _firestore.collection(collection).doc(docId).update(data);
  }

  Future<void> deleteProduct(String collection, String docId) {
    return _firestore.collection(collection).doc(docId).delete();
  }

  Future<void> addProduct(String collection, Map<String, dynamic> data) {
    return _firestore.collection(collection).add(data);
  }

  Future<Map<String, dynamic>?> getProductByRfid(String idRfid) async {
    try {
      final querySnapshot = await _firestore
          .collection('productos')
          .where('idRfid', isEqualTo: idRfid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      }
    } catch (e) {
      print('Error al buscar producto: $e');
    }
    return null;
  }

  Future<void> addAlertToFirestore(
      String uid, Map<String, dynamic> alertData) async {
    try {
      // Verifica si ya existe un registro con el mismo UID y timestamp
      final querySnapshot = await _firestore
          .collection('estadisticas')
          .where('uid', isEqualTo: uid)
          .where('timestamp', isEqualTo: alertData['timestamp'])
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Si no existe, agrega el registro
        await _firestore.collection('estadisticas').add({
          'uid': uid,
          'categoria': alertData['categoria'],
          'timestamp': alertData['timestamp'],
          'nombreProducto': alertData['nombreProducto'],
        });
      } else {
        print('Registro duplicado detectado. No se agregó a Firestore.');
      }
    } catch (e) {
      print('Error al agregar alerta a Firestore: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getStatistics() async {
    try {
      final querySnapshot = await _firestore.collection('estadisticas').get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error al obtener estadísticas: $e');
      return [];
    }
  }

  Future<void> deleteStatistic(String nombreProducto, String timestamp) async {
    try {
      final querySnapshot = await _firestore
          .collection('estadisticas')
          .where('nombreProducto', isEqualTo: nombreProducto)
          .where('timestamp', isEqualTo: timestamp)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.delete();
      }
    } catch (e) {
      print('Error al eliminar el registro: $e');
    }
  }
}
