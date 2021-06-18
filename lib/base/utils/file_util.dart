import 'dart:io';

import 'package:flutter_ui/base/log/log.dart';
import 'package:path_provider/path_provider.dart';

class FileUtil {
  FileUtil._internal();

  static final FileUtil getInstance = FileUtil._internal();

  factory FileUtil() => getInstance;

  /// 此方法返回本地文件地址
  Future<Directory> getParent({String? dir}) async {
    // 获取文档目录的路径
    Directory? packageDir = await getExternalStorageDirectory();
    if (packageDir == null) {
      return Directory('/storage/emulated/0/tmp');
    }
    Directory parent = Directory('${packageDir.path}${dir == null ? '' : '/$dir'}');
    if (!parent.existsSync()) {
      await parent.create();
    }
    Log.d('文件夹: parent=${parent.path}');
    return parent;
  }

  /// 保存text到本地文件里面
  Future<bool> save(String fileName, String text, {String? dir}) async {
    try {
      Directory parent = await getParent(dir: dir);
      File file = File('${parent.path}/$fileName');
      if (!file.existsSync()) {
        await file.create();
      }
      IOSink slink = file.openWrite(mode: FileMode.append);
      slink.write('$text');
      slink.close();
      Log.d('保存文件成功: ${file.path}');
      return Future.value(true);
    } catch (e) {
      Log.d('保存文件错误: $e');
      return Future.value(false);
    }
  }

  /// 读取文件的内容
  Future<String> read(String fileName, {String? dir}) async {
    Directory parent = await getParent(dir: dir);
    File file = File('${parent.path}/$fileName');
    if (!file.existsSync()) {
      return '';
    }
    // 从文件中读取变量作为字符串，一次全部读完存在内存里面
    String contents = await file.readAsString();
    return contents;
  }

  // 清空保存的内容
  void clear(String fileName, {String? dir}) async {
    Directory parent = await getParent(dir: dir);
    File file = File('${parent.path}/$fileName');
    if (file.existsSync()) {
      await file.writeAsString('');
    }
  }

  // 删除文件夹的所有文件
  Future delete({String? dir}) async {
    Directory parent = await getParent(dir: dir);
    parent.listSync().forEach((element) async {
      await element.delete();
      Log.d('删除成功: ${element.path}');
    });
  }
}
