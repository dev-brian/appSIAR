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
}
