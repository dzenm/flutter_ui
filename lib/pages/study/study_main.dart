import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../base/base.dart';

///
/// Created by a0010 on 2023/11/29 16:27
///
class StudyMain {
  static const String _tag = 'StudyMain';

  static void main() async {
    await _pathProviderTest();
  }


  static Future<void> _pathProviderTest() async {
    // macOS：/Users/a0010/Library/Containers/com.dzenm.flutterUi/Data/Library/Caches
    // Android：/data/user/0/com.dzenm.flutter_ui/cache
    Directory? temp = await getTemporaryDirectory();
    _log('获取文件路径：temp=${temp.path}');

    // macOS：/Users/a0010/Library/Containers/com.dzenm.flutterUi/Data/Library/Application Support/com.dzenm.flutterUi
    // Android：/data/user/0/com.dzenm.flutter_ui/files
    Directory? support = await getApplicationSupportDirectory();
    _log('获取文件路径：support=${support.path}');

    // macOS：/Users/a0010/Library/Containers/com.dzenm.flutterUi/Data/Documents
    // Android：/data/user/0/com.dzenm.flutter_ui/app_flutter
    Directory? document = await getApplicationDocumentsDirectory();
    _log('获取文件路径：document=${document.path}');

    // macOS：/Users/a0010/Library/Containers/com.dzenm.flutterUi/Data/Library/Caches/com.dzenm.flutterUi
    // Android：/data/user/0/com.dzenm.flutter_ui/cache
    Directory? cache = await getApplicationCacheDirectory();
    _log('获取文件路径：cache=${cache.path}');

    if (!BuildConfig.isAndroid) {
      // macOS：/Users/a0010/Library/Containers/com.dzenm.flutterUi/Data/Library
      Directory? library = await getLibraryDirectory();
      _log('获取文件路径：library=${library.path}');
    }
  }

  static void _log(String msg) {
    Log.d(msg, tag: _tag);
  }
}
