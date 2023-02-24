import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../log/log.dart';

class FileUtil {
  FileUtil._internal();

  static final FileUtil instance = FileUtil._internal();

  factory FileUtil() => instance;

  /// 此方法返回本地文件地址
  Future<Directory> getParent({String? dir}) async {
    // 获取文档目录的路径
    // getTemporaryDirectory()	              Future<Directory>	          临时目录
    // getApplicationSupportDirectory()	      Future<Directory>	          应用程序支持目录
    // getLibraryDirectory()	                Future<Directory>	          应用程序持久文件目录
    // getApplicationDocumentsDirectory()	    Future<Directory>	          文档目录
    // getExternalStorageDirectory()	        Future<Directory>	          外部存储目录
    // getExternalCacheDirectories()	        Future<List<Directory>?>	  外部存储缓存目录
    // getExternalStorageDirectories()	      Future<List<Directory>?>	  外部存储目录（单独分区）
    // getDownloadsDirectory()	              Future<Directory?>	        桌面程序下载目录
    Directory? packageDir = await getApplicationDocumentsDirectory();
    Directory parent = Directory('${packageDir.path}${dir == null ? '' : '/$dir'}');
    if (!parent.existsSync()) {
      await parent.create();
    }
    Log.d('获取文件夹路径: ${parent.path}');
    return parent;
  }

  /// 获取数据库文件夹所有数据库文件
  Future<List<String>> getDBFiles() async {
    String parent = await getDatabasesPath();
    List<String> files = [];
    Directory(parent).listSync().forEach((element) {
      if (element.path.endsWith('.db')) {
        files.add(element.path);
      }
    });
    Log.d('数据库文件夹: path=$parent, fileSize=${files.length}');
    return files;
  }

  /// 保存text到本地文件里面
  Future<String?> save(String fileName, String text, {String? dir}) async {
    try {
      Directory parent = await getParent(dir: dir);
      File file = File('${parent.path}/$fileName');
      if (!file.existsSync()) {
        await file.create();
      }
      IOSink slink = file.openWrite(mode: FileMode.append);
      slink.write('$text');
      await slink.close();
      Log.d('保存文件成功: ${file.path}');
      return Future.value(file.path);
    } catch (e) {
      Log.d('保存文件错误: $e');
      return Future.value(null);
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

  /// 拷贝文件
  void copy(String oldPath, String newPath) {
    File oldFile = File(oldPath);
    try {
      oldFile.copySync('$newPath');
      Log.d('文件复制成功: from=$oldPath to=$newPath');
    } catch (e) {
      Log.e('文件复制失败: $e');
    }
  }

  /// 根据路径获取文件名
  String getFileName(String path) {
    int index = path.lastIndexOf('/');
    int len = path.length;
    return index == -1 ? '' : path.substring(index, len);
  }

  /// 拷贝文件夹
  void copyDir(String oldDir, String newDir) {
    Directory dir = Directory(oldDir);
    if (!dir.existsSync()) {
      return;
    }
    dir.listSync().forEach((FileSystemEntity file) {
      String name = getFileName(file.path);
      copy('$oldDir$name', '$newDir$name');
    });
  }

  /// 清空保存的内容
  void clear(String fileName, {String? dir}) async {
    Directory parent = await getParent(dir: dir);
    File file = File('${parent.path}/$fileName');
    if (file.existsSync()) {
      await file.writeAsString('');
    }
  }

  /// 删除文件夹的所有文件
  Future delete({String? dir}) async {
    Directory parent = await getParent(dir: dir);
    parent.listSync().forEach((element) async {
      await element.delete();
      Log.d('删除成功: ${element.path}');
    });
  }

  //l 清除缓存目录工具
  static Future<Null> clearTempCache() async {
    var tempPath = await getTemporaryDirectory();
    await requestPermission(tempPath);
  }

  static Future<Null> requestPermission(FileSystemEntity file) async {
    // PermissionStatus status = await Permission.storage.status;
    // if (status != PermissionStatus.granted) {
    //   CommonDialog.showToast("请先开启读写权限");
    //   return;
    // }
    await delDir(file);
  }

  static Future<Null> delDir(FileSystemEntity file) async {
    if (file is Directory && file.existsSync()) {
      final List<FileSystemEntity> children = file.listSync(recursive: true, followLinks: true);
      for (final FileSystemEntity child in children) {
        await delDir(child);
      }
    }

    try {
      if (file.existsSync()) {
        await file.delete(recursive: true);
      }
    } catch (err) {}
  }

  //l 循环获取缓存大小
  static Future getTotalSizeOfFilesInDir(final FileSystemEntity file) async {
    if (file is File && file.existsSync()) {
      // Log.d("临时缓存目录路径:${file.path}");

      int length = await file.length();
      return double.parse(length.toString());
    }
    if (file is Directory && file.existsSync()) {
      List children = file.listSync();
      double total = 0;
      if (children.length > 0) for (final FileSystemEntity child in children) total += await getTotalSizeOfFilesInDir(child);
      return total;
    }
    return 0;
  }

  //格式化文件大小
  static String renderSize(value) {
    if (value == null || value == 0) {
      return '0.0B';
    }
    List<String> unitArr = []
      ..add('B')
      ..add('K')
      ..add('M')
      ..add('G');
    int index = 0;
    while (value > 1024) {
      index++;
      value = value / 1024;
    }
    String size = value.toStringAsFixed(2);
    return size + unitArr[index];
  }

  /// 清理内存图片缓存:
  //clear all of image  in memory
  static clearMemoryImageCache() {
    PaintingBinding.instance.imageCache.clear();
  }

  // get ImageCache
  static getMemoryImageCache() {
    return PaintingBinding.instance.imageCache;
  }
}
