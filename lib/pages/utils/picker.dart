import 'package:fbl/fbl.dart';
import 'package:image_picker/image_picker.dart';

///
/// Created by a0010 on 2025/4/30 09:40
///
class Picker {
  void openImagePicker(bool isCamera) {
    ImagePicker().pickImage(source: isCamera ? ImageSource.camera : ImageSource.gallery).then((file) {
      if (file == null) {
        Log.e('failed to get image file');
        return;
      }
      String path = file.path;
      file.readAsBytes().then((data) {
        Log.d('image file length: ${data.length}, path: $path');
        // Image body = ImageUtils.memoryImage(data);
        // Alert.confirm(context, 'Pick Image', body,
        //   okAction: () {
        //     if (onPicked != null) {
        //       onPicked(path);
        //     }
        //     onRead(path, data);
        //   },
        // );
      }).onError((error, stackTrace) {
        // Alert.show(context, 'Image File Error', '$error');
      });
    });
  }
}
