import 'package:image_picker/image_picker.dart';

Future<XFile?> getImage(ImageSource source) async {
  final ImagePicker _picker = ImagePicker();
  final XFile? image = await _picker.pickImage(source: source);
  return image;
}
