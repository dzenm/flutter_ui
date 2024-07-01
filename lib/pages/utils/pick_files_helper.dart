import 'package:file_selector/file_selector.dart';

/// 可以选中的最大文件数量
const kSelectedMaxFileLength = 9;

///
/// Created by a0010 on 2023/11/28 11:10
///
class PickFilesHelper {
  static void pickFile({required void Function(List<XFile> files) success, void Function(String text)? failed}) async {
    List<XFile> files = await openFiles();
    if (files.isEmpty) return;
    if (files.length > kSelectedMaxFileLength) {
      if (failed != null) {
        failed('最多只能选择$kSelectedMaxFileLength个文件');
      }
    } else {
      success(files);
    }
  }
}
