import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ui/base/widgets/image_editor/image_editor.dart';
import 'package:image_picker/image_picker.dart';

///
/// Created by a0010 on 2022/6/23 10:48
/// 图片编辑
class ImageEditorPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ImageEditor();
}

class _ImageEditor extends State<ImageEditorPage> {
  File? _image;

  final picker = ImagePicker();

  Future<void> toImageEditor(File origin) async {
    return Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ImageEditor(
        originImage: origin,
      );
    })).then((result) {
      if (result is EditorImageResult) {
        setState(() {
          _image = result.newFile;
        });
      }
    }).catchError((er) {
      debugPrint(er);
    });
  }

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
      appBar: AppBar(
        title: Text('图片编辑', style: TextStyle(color: Colors.white)),
      ),
      body: Material(
        color: Colors.white,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              if (_image != null) Expanded(child: Image.file(_image!)),
              ElevatedButton(
                onPressed: getImage,
                child: Text('edit image'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
