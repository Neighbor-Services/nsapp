import 'package:image_picker/image_picker.dart';
import 'package:nsapp/core/initialize/init.dart';

class MediaUtils {
  static Future<void> selectImageFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      image = pickedFile;
    }
  }

  static Future<void> selectImagesFromGallery() async {
    List<XFile> pickedFiles = await ImagePicker().pickMultiImage(
      limit: 10,
    );
    if (pickedFiles.isNotEmpty) {
      images = pickedFiles;
    }
  }

  static Future<void> selectImageFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      image = pickedFile;
    }
  }
}
