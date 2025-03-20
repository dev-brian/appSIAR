import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String categoria;
  final String descripcion;
  final String estado;
  final String fotoProducto;
  final String idRfid;
  final String marca;
  final String modelo;
  final String nombreProducto;
  final String numeroSerie;
  final String ubicacion;

  ProductModel({
    required this.id,
    required this.categoria,
    required this.descripcion,
    required this.estado,
    required this.fotoProducto,
    required this.idRfid,
    required this.marca,
    required this.modelo,
    required this.nombreProducto,
    required this.numeroSerie,
    required this.ubicacion,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoria': categoria,
      'descripcion': descripcion,
      'estado': estado,
      'fotoProducto': fotoProducto,
      'idRfid': idRfid,
      'marca': marca,
      'modelo': modelo,
      'nombreProducto': nombreProducto,
      'numeroSerie': numeroSerie,
      'ubicacion': ubicacion,
    };
  }

  factory ProductModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    return ProductModel(
      id: doc.id,
      categoria: doc['categoria'],
      descripcion: doc['descripcion'],
      estado: doc['estado'],
      fotoProducto: doc['fotoProducto'],
      idRfid: doc['idRfid'],
      marca: doc['marca'],
      modelo: doc['modelo'],
      nombreProducto: doc['nombreProducto'],
      numeroSerie: doc['numeroSerie'],
      ubicacion: doc['ubicacion'],
    );
  }
}
