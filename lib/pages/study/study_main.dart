import 'dart:io';

import 'package:fbl/fbl.dart';
import 'package:path_provider/path_provider.dart';

///
/// Created by a0010 on 2023/11/29 16:27
///
class StudyMain {
  static const String _tag = 'StudyMain';

  static void main() async {
    await _pathProviderTest();
  }

  static Future<void> _pathProviderTest() async {
    // Android：/data/user/0/com.dzenm.flutter_ui/cache
    // iOS：/var/mobile/Containers/Data/Application/3A0617A0-0774-401A-98E8-4713AF0CDCB6/Library/Caches
    // macOS：/Users/a0010/Library/Containers/com.dzenm.flutterUi/Data/Library/Caches
    Directory? temp = await getTemporaryDirectory();
    _log('获取文件路径：temp=${temp.path}');

    // Android：/data/user/0/com.dzenm.flutter_ui/files
    // iOS：/var/mobile/Containers/Data/Application/3A0617A0-0774-401A-98E8-4713AF0CDCB6/Library/Application Support
    // macOS：/Users/a0010/Library/Containers/com.dzenm.flutterUi/Data/Library/Application Support/com.dzenm.flutterUi
    Directory? support = await getApplicationSupportDirectory();
    _log('获取文件路径：support=${support.path}');

    // Android：/data/user/0/com.dzenm.flutter_ui/app_flutter
    // iOS：/var/mobile/Containers/Data/Application/3A0617A0-0774-401A-98E8-4713AF0CDCB6/Documents
    // macOS：/Users/a0010/Library/Containers/com.dzenm.flutterUi/Data/Documents
    Directory? document = await getApplicationDocumentsDirectory();
    _log('获取文件路径：document=${document.path}');

    // Android：/data/user/0/com.dzenm.flutter_ui/cache
    // iOS：/var/mobile/Containers/Data/Application/3A0617A0-0774-401A-98E8-4713AF0CDCB6/Library/Caches
    // macOS：/Users/a0010/Library/Containers/com.dzenm.flutterUi/Data/Library/Caches/com.dzenm.flutterUi
    Directory? cache = await getApplicationCacheDirectory();
    _log('获取文件路径：cache=${cache.path}');

    if (BuildConfig.isAndroid) {
      // Android：/storage/emulated/0/Android/data/com.dzenm.flutter_ui/files
      Directory? externalStorage = await getExternalStorageDirectory();
      _log('获取文件路径：externalStorage=${externalStorage?.path}');

      // Android：/storage/emulated/0/Android/data/com.dzenm.flutter_ui
      List<Directory>? externalCaches = await getExternalCacheDirectories();
      _log('获取文件路径：externalCaches=${externalCaches?.firstOrNull?.parent}');

      // Android：/storage/emulated/0/Android/data/com.dzenm.flutter_ui
      List<Directory>? externalStorages = await getExternalStorageDirectories();
      _log('获取文件路径：externalStorages=${externalStorages?.firstOrNull?.parent}');
    }

    if (BuildConfig.isIOS || BuildConfig.isMacOS) {
      // iOS：/var/mobile/Containers/Data/Application/3A0617A0-0774-401A-98E8-4713AF0CDCB6/Library
      // macOS：/Users/a0010/Library/Containers/com.dzenm.flutterUi/Data/Library
      Directory? library = await getLibraryDirectory();
      _log('获取文件路径：library=${library.path}');
    }
  }

  static void _log(String msg) {
    Log.d(msg, tag: _tag);
  }
}
