import 'dart:io';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;

final FirebaseStorage storage = FirebaseStorage.instance;

Future<String?> uploadImage(File image) async {
  try {
    // Leer la imagen original
    final img.Image? originalImage = img.decodeImage(image.readAsBytesSync());
    if (originalImage == null) {
      print('Error: No se pudo decodificar la imagen.');
      return null;
    }

    // Comprimir la imagen (ajustar calidad y tamaño si es necesario)
    final img.Image resizedImage = img.copyResize(originalImage,
        width: 800); // Cambia el ancho según tus necesidades
    final List<int> compressedImageBytes =
        img.encodeJpg(resizedImage, quality: 85); // Ajusta la calidad (0-100)

    // Crear un archivo temporal para la imagen comprimida
    final String tempPath =
        '${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final File compressedImageFile = File(tempPath)
      ..writeAsBytesSync(compressedImageBytes);

    // Subir la imagen comprimida a Firebase Storage
    final String namefile =
        '${DateTime.now().millisecondsSinceEpoch}-${image.path.split('/').last}';
    final Reference ref = storage.ref().child('products').child(namefile);
    final UploadTask uploadTask = ref.putFile(compressedImageFile);

    // Aplicar timeout de 15 segundos
    final TaskSnapshot snapshot = await uploadTask.timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        throw TimeoutException('La subida de la imagen ha tardado demasiado.');
      },
    );

    if (snapshot.state == TaskState.success) {
      // Eliminar el archivo temporal después de subirlo
      compressedImageFile.deleteSync();
      return await snapshot.ref.getDownloadURL();
    } else {
      return null;
    }
  } on TimeoutException catch (_) {
    print('Error: Tiempo de espera excedido');
    return null;
  } catch (e) {
    print('Error al subir la imagen: $e');
    return null;
  }
}
