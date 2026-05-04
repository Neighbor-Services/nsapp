import 'package:image_picker/image_picker.dart';

class MediaUtils {
  static Future<XFile?> selectImageFromGallery() async {
    return await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
  }

  static Future<List<XFile>?> selectImagesFromGallery() async {
    return await ImagePicker().pickMultiImage(
      limit: 10,
    );
  }

  static Future<XFile?> selectImageFromCamera() async {
    return await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
  }
}


