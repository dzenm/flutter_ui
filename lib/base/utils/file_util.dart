import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../db/db.dart';

/// 原图路径对应的缩略图路径区分
const _thumb = '_thumb';

///
/// Created by a0010 on 2022/9/1 11:56
/// 文件工具类
class FileUtil {
  /// Windows APP的根目录文件夹
  static const windowsAppRootDir = 'FlutterUI';

  FileUtil._internal();

  static final FileUtil _instance = FileUtil._internal();

  static FileUtil get instance => _instance;

  factory FileUtil() => instance;

  static late Directory _appRootDir;
  static final List<Directory> _appDirs = [];

  Function? _logPrint;

  /// 初始化文件夹
  Future<void> init({Function? logPrint}) async {
    _logPrint = logPrint;
    _appRootDir = await getAppRootDirectory();
  }

  /// 获取App的根目录所在的路径
  /// macOS/iOS: /Users/a0010/Library/Containers/<package_name>/Data/Documents
  /// Windows:   C:\Users\Administrator\Documents\FlutterUI
  /// Android:   /data/user/0/<package_name>
  /// [dir] 在根目录下面创建的文件夹名称作为应用的根目录
  Future<Directory> getAppRootDirectory({String? dir}) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appRootDir = join(appDocDir.path);
    if (Platform.isMacOS || Platform.isIOS) {
      appRootDir = join(appDocDir.path);
    }
    if (Platform.isWindows || Platform.isLinux) {
      appRootDir = join(appDocDir.path, windowsAppRootDir);
    }
    if (Platform.isAndroid) {
      appRootDir = join(appDocDir.parent.path);
    }
    if (dir != null) {
      appRootDir = join(appRootDir, dir);
    }
    Directory result = Directory(appRootDir);
    if (!result.existsSync()) {
      result.createSync(recursive: true);
    }
    return result;
  }

  /// 初始化登录用户目录
  void initLoginUserDirectory(String user) {
    // 初始化常用文件夹
    for (var dir in UserDirectory.values) {
      String dirName = join(_appRootDir.path, user, dir.name);
      Directory result = Directory(dirName);
      if (!result.existsSync()) {
        result.createSync(recursive: true);
      }
      _appDirs.add(result);
      _log('初始化用户存储目录：path=${result.path}');
    }
  }

  /// 缓存文件夹路径 @see [init]、[_appDirs]
  /// macOS/iOS: /Users/a0010/Library/Containers/<package_name>/Data/Documents/messages
  /// Windows:   C:\Users\Administrator\Documents\FlutterUI\messages
  /// Android:   /data/user/0/<package_name>/messages
  Directory get messagesDirectory => _appDirs[0];

  /// 图片文件路径
  String getImagesPath(String user) => getMessagesDirectory('Images', user: user).path;

  /// 视频文件路径
  String getVideosPath(String user) => getMessagesDirectory('Videos', user: user).path;

  /// 音频文件路径
  String getAudiosPath(String user) => getMessagesDirectory('Audios', user: user).path;

  /// 文件路径
  String getFilesPath(String user) => getMessagesDirectory('Files', user: user).path;

  /// 获取缓存文件的子目录 @see [cacheDirectory]
  Directory getMessagesDirectory(String dir, {String? user}) {
    String cache = messagesDirectory.path;
    cache = join(cache, user, dir);
    Directory result = Directory(cache);
    if (!result.existsSync()) {
      result.createSync(recursive: true);
    }
    return result;
  }

  /// 返回本地文档下的APP的路径
  /// macOS/iOS: /Users/a0010/Library/Containers/<package_name>/Data/Documents
  /// Windows:   C:\Users\Administrator\Documents
  /// Android:   /data/user/0/<package_name>/
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
    Directory parent = Directory('${packageDir.path}${dir == null ? '' : '${Platform.pathSeparator}$dir'}');
    if (!parent.existsSync()) {
      await parent.create();
    }
    _log('获取文件夹路径: ${parent.path}');
    return parent;
  }

  /// 获取数据库文件夹所有数据库文件
  Future<List<String>> getDBFiles() async {
    String parent = await DBManager().databasesPath;
    List<String> files = [];
    Directory(parent).listSync().forEach((element) {
      if (element.path.endsWith('.db')) {
        files.add(element.path);
      }
    });
    _log('数据库文件夹: path=$parent, fileSize=${files.length}');
    return files;
  }

  /// 根据路径获取文件名
  String getFileName(dynamic file) {
    String path = '';
    if (file is File) {
      path = file.path;
    } else {
      path = file.toString();
    }
    return path.split(Platform.pathSeparator).last;
  }

  /// 保存text到本地文件里面
  Future<String?> save(String fileName, String text, {String? dir}) async {
    try {
      Directory parent = await getParent(dir: dir);
      File file = File('${parent.path}${Platform.pathSeparator}$fileName');
      if (!file.existsSync()) {
        await file.create();
      }
      IOSink slink = file.openWrite(mode: FileMode.append);
      slink.write(text);
      await slink.close();
      _log('保存文件成功: ${file.path}');
      return Future.value(file.path);
    } catch (e) {
      _log('保存文件错误: $e');
      return Future.value(null);
    }
  }

  /// 读取文件的内容
  Future<String> read(String fileName, {String? dir}) async {
    Directory parent = await getParent(dir: dir);
    File file = File('${parent.path}${Platform.pathSeparator}$fileName');
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
      oldFile.copySync(newPath);
      _log('文件复制成功: from=$oldPath to=$newPath');
    } catch (e) {
      _log('文件复制失败: $e');
    }
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
    File file = File('${parent.path}${Platform.pathSeparator}$fileName');
    if (file.existsSync()) {
      await file.writeAsString('');
    }
  }

  /// 删除文件夹的所有文件
  Future delete({String? dir}) async {
    Directory parent = await getParent(dir: dir);
    parent.listSync().forEach((element) async {
      await element.delete();
      _log('删除成功: ${element.path}');
    });
  }

  static Future<void> delDir(FileSystemEntity file) async {
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
    } catch (err) {
      FileUtil()._log(err.toString());
    }
  }

  // 循环获取缓存大小
  static Future getTotalSizeOfFilesInDir(final FileSystemEntity file) async {
    if (file is File && file.existsSync()) {
      // _log("临时缓存目录路径:${file.path}");

      int length = await file.length();
      return double.parse(length.toString());
    }
    if (file is Directory && file.existsSync()) {
      List children = file.listSync();
      double total = 0;
      if (children.isNotEmpty) {
        for (FileSystemEntity child in children) {
          total += await getTotalSizeOfFilesInDir(child);
        }
      }
      return total;
    }
    return 0;
  }

  //格式化文件大小
  static String renderSize(value) {
    if (value == null || value == 0) {
      return '0.0B';
    }
    List<String> unitArr = ['B', 'K', 'M', 'G'];
    int index = 0;
    while (value > 1024) {
      index++;
      value = value / 1024;
    }
    String size = value.toStringAsFixed(2);
    return size + unitArr[index];
  }

  /// 清理内存图片缓存:
  static clearMemoryImageCache() {
    PaintingBinding.instance.imageCache.clear();
  }

  // get ImageCache
  static getMemoryImageCache() {
    return PaintingBinding.instance.imageCache;
  }

  void _log(String text) => _logPrint == null ? null : _logPrint!(text, tag: 'FileUtil');
}

/// 处理文件的路径信息
class PathInfo {
  String path; // 文件路径
  String parent; // 文件所在的文件夹
  String? name; // 文件的名称，带后缀
  String? fileName; // 文件的名称，不带后缀
  String? mimeTypeSuffix; // 文件后缀类型

  PathInfo({required this.path, required this.parent, this.name, this.fileName, this.mimeTypeSuffix});

  /// path=/Users/a0010/Documents/cache/5e6b6e5de3524abf9002540932652b38/Images/336ae1a1dff74c3292c06bdff09af061_WX20231130-160703@2x.png
  /// name=336ae1a1dff74c3292c06bdff09af061_WX20231130-160703@2x.png
  /// fileName=336ae1a1dff74c3292c06bdff09af061_WX20231130-160703@2x
  /// parent=/Users/a0010/Documents/cache/5e6b6e5de3524abf9002540932652b38/Images
  /// mimeTypeSuffix=png
  factory PathInfo.parse(String path) {
    int separatorIndex = path.lastIndexOf(Platform.pathSeparator);
    if (separatorIndex < 0) throw Exception('path=$path parse error, It is not contains directory');
    int index = path.lastIndexOf('.');
    String parent = path.substring(0, separatorIndex);
    String name = path.substring(separatorIndex + 1);
    String fileName;
    String? mimeTypeSuffix;
    if (index < 0) {
      // 如果不存在.后缀的路径，直接裁剪到结尾
      fileName = path.substring(separatorIndex + 1);
    } else {
      fileName = path.substring(separatorIndex + 1, index);
      mimeTypeSuffix = path.substring(index + 1);
    }
    return PathInfo(
      path: path,
      parent: parent,
      name: name,
      fileName: fileName,
      mimeTypeSuffix: mimeTypeSuffix,
    );
  }

  /// file=/Users/a0010/Documents/cache/5e6b6e5de3524abf9002540932652b38/Images/336ae1a1dff74c3292c06bdff09af061_WX20231130-160703@2x.png
  /// suffix=thumb_
  /// addFileNamePrefix=/Users/a0010/Documents/cache/5e6b6e5de3524abf9002540932652b38/Images/thumb_336ae1a1dff74c3292c06bdff09af061_WX20231130-160703@2x.png
  String addFileNamePrefix(String prefix) => join(parent, '$prefix$fileName.${mimeTypeSuffix ?? ''}');

  /// file=/Users/a0010/Documents/cache/5e6b6e5de3524abf9002540932652b38/Images/thumb_336ae1a1dff74c3292c06bdff09af061_WX20231130-160703@2x.png
  /// suffix=thumb_
  /// removeFileNamePrefix=/Users/a0010/Documents/cache/5e6b6e5de3524abf9002540932652b38/Images/336ae1a1dff74c3292c06bdff09af061_WX20231130-160703@2x_thumb.png
  String removeFileNamePrefix(String prefix) {
    if (fileName == null) return '';
    String name = fileName ?? '';
    if (fileName!.startsWith(prefix)) {
      name = fileName!.substring(prefix.length);
    }
    return join(parent, '$name.${mimeTypeSuffix ?? ''}');
  }

  /// file=/Users/a0010/Documents/cache/5e6b6e5de3524abf9002540932652b38/Images/336ae1a1dff74c3292c06bdff09af061_WX20231130-160703@2x.png
  /// suffix=_thumb
  /// addFileNameSuffix=/Users/a0010/Documents/cache/5e6b6e5de3524abf9002540932652b38/Images/336ae1a1dff74c3292c06bdff09af061_WX20231130-160703@2x_thumb.png
  String addFileNameSuffix(String suffix) => join(parent, '$fileName$suffix.${mimeTypeSuffix ?? ''}');

  /// file=/Users/a0010/Documents/cache/5e6b6e5de3524abf9002540932652b38/Images/336ae1a1dff74c3292c06bdff09af061_WX20231130-160703@2x_thumb.png
  /// suffix=_thumb
  /// removeFileNameSuffix=/Users/a0010/Documents/cache/5e6b6e5de3524abf9002540932652b38/Images/336ae1a1dff74c3292c06bdff09af061_WX20231130-160703@2x.png
  String removeFileNameSuffix(String suffix) {
    if (fileName == null) return '';
    String name = fileName ?? '';
    if (fileName!.endsWith(suffix)) {
      name = fileName!.substring(0, fileName!.lastIndexOf(suffix));
    }
    return join(parent, '$name.${mimeTypeSuffix ?? ''}');
  }

  /// 文件名称起始或者终止位置是否包含字符串
  bool nameContains(String fix) {
    if (fileName == null) return false;
    return fileName!.startsWith(fix) || fileName!.endsWith(fix);
  }

  /// 获取缩略图文件路径
  String get thumbPath => nameContains(_thumb) ? path : addFileNameSuffix(_thumb);

  /// 获取原文件路径
  String get originPath => nameContains(_thumb) ? removeFileNameSuffix(_thumb) : path;

  /// 复制到指定文件夹
  String copyPath(String parent) => join(parent, fileName);

  /// 获取文件类型
  MimeType get mimeType => mimeTypes[mimeTypeSuffix] ?? MimeType.unknown;

  /// 是否是Gif图
  bool get isGif => mimeTypeSuffix?.toLowerCase() == 'gif';
}

/// 用户目录
enum UserDirectory {
  messages('Messages'),
  databases('Databases'),
  favourites('Favourites');

  final String name;

  const UserDirectory(this.name);
}

/// 文件类型
enum MimeType {
  unknown(0, 'icon_unknown'),
  image(1, 'icon_pic'),
  video(2, 'icon_mp4'),
  audio(3, 'icon_mp3'),
  pdf(4, 'icon_pdf'),
  word(5, 'icon_word'),
  zip(6, 'icon_zip'),
  excel(7, 'icon_xls'),
  txt(8, 'icon_txt'),
  ppt(9, 'icon_ppt'),
  apk(10, 'icon_apk');

  final int value;
  final String icon;

  const MimeType(this.value, this.icon);
}

/// 根据路径后缀判断文件类型
Map<String, MimeType> mimeTypes = {
  'png': MimeType.image,
  'jpg': MimeType.image,
  'jpeg': MimeType.image,
  'webp': MimeType.image,
  'gif': MimeType.image,
  'bmp': MimeType.image,
  '3gp': MimeType.video,
  '3gpp': MimeType.video,
  '3gpp2': MimeType.video,
  'avi': MimeType.video,
  'mp4': MimeType.video,
  'x-msvideo': MimeType.video,
  'x-matroska': MimeType.video,
  'mpeg': MimeType.video,
  'webm': MimeType.video,
  'mp2ts': MimeType.video,
  'x-ms-wma': MimeType.audio,
  'x-wav': MimeType.audio,
  'amr': MimeType.audio,
  'wav': MimeType.audio,
  'aac': MimeType.audio,
  'lamr': MimeType.audio,
  'mp3': MimeType.audio,
  'm4a': MimeType.audio,
  'pdf': MimeType.pdf,
  'docx': MimeType.pdf,
  'doc': MimeType.word,
  'zip': MimeType.zip,
  'rar': MimeType.zip,
  'xls': MimeType.excel,
  'xlsx': MimeType.excel,
  'txt': MimeType.txt,
  'ppt': MimeType.ppt,
  'pptx': MimeType.ppt,
  'apk': MimeType.apk,
};
