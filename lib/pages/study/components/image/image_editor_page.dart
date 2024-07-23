import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ui/base/base.dart';
import 'package:image_picker/image_picker.dart';

///
/// Created by a0010 on 2022/6/23 10:48
/// 图片编辑
class ImageEditorPage extends StatefulWidget {
  const ImageEditorPage({super.key});

  @override
  State<StatefulWidget> createState() => _ImageEditor();
}

class _ImageEditor extends State<ImageEditorPage> {
  File? _image;

  final picker = ImagePicker();

  Future<void> toImageEditor(File origin) async {}

  void getImage() async {
    XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final File origin = File(image.path);
      toImageEditor(origin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonBar(
        title: '图片编辑',
      ),
      body: Material(
        color: Colors.white,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              if (_image != null) Expanded(child: Image.file(_image!)),
              ElevatedButton(
                onPressed: getImage,
                child: const Text('edit image'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
