import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as IM;

class Utils{
  
  static Future<File> pickImage({@required ImageSource imageSource}) async {
    File selectedImage = await ImagePicker.pickImage(source: imageSource);
    return compressImage(imageToCompress: selectedImage);
  }

  static Future<File> compressImage({@required File imageToCompress}) async {

    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int random = Random().nextInt(10000);
    IM.Image image = IM.decodeImage(imageToCompress.readAsBytesSync());
    IM.copyResize(image,width: 500, height: 500);
    return new File('$path/img_$random')..writeAsBytesSync(IM.encodeJpg(image,quality: 85));

  }
  
}