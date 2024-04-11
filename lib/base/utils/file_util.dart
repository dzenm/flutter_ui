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
  /// APP的根目录文件夹
  static const rootDir = 'FlutterUI';

  FileUtil._internal();

  static final FileUtil _instance = FileUtil._internal();

  static FileUtil get instance => _instance;

  factory FileUtil() => instance;

  late Directory _appRootDir;
  late Directory _userDir;
  final List<Directory> _appDirs = [];

  Function? _logPrint;

  /// 初始化文件夹
  Future<void> init({Function? logPrint}) async {
    _logPrint = logPrint;
    _appRootDir = await _getAppRootDirectory();
  }

  /// 获取App的根目录所在的路径
  /// macOS/iOS: /Users/a0010/Library/Containers/<package_name>/Data/Documents，macOS在/Users/a0010/Documents/FlutterUI/userId>/Messages
  /// Windows:   C:\Users\Administrator\Documents\FlutterUI\<userId>\Databases
  /// Android:   /data/user/0/<package_name>/<userId>/Databases
  /// [dir] 在根目录下面创建的文件夹名称作为应用的根目录
  Future<Directory> _getAppRootDirectory({String? dir}) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appRootDir = join(appDocDir.path);
    if (Platform.isIOS) {
      appRootDir = join(appDocDir.path, dir);
    }
    if (Platform.isMacOS) {
      appRootDir = join(appDocDir.path, rootDir, dir);
    }
    if (Platform.isWindows || Platform.isLinux) {
      appRootDir = join(appDocDir.path, rootDir, dir);
    }
    if (Platform.isLinux) {
      appRootDir = join(appDocDir.path, rootDir, dir);
    }
    if (Platform.isAndroid) {
      appRootDir = join(appDocDir.parent.path, dir);
    }
    Directory result = Directory(appRootDir);
    if (!result.existsSync()) {
      result.createSync(recursive: true);
    }
    return result;
  }

  /// 获取APP的路径
  Directory get appDir => _appRootDir.absolute;

  /// 初始化登录用户目录
  void initLoginUserDirectory(String userId) {
    String parent = join(_appRootDir.path, userId);
    _userDir = Directory(parent);
    _log('初始化用户目录：parent=$parent');
    // 初始化常用文件夹
    for (var dir in UserDirectory.values) {
      String dirName = join(parent, dir.dirName);
      Directory result = Directory(dirName);
      if (!result.existsSync()) {
        result.createSync(recursive: true);
      }
      _appDirs.add(result);
      _log('初始化用户存储目录：path=${result.path}');
    }
  }

  /// 缓存文件夹路径 @see [init]、[_appDirs]
  /// macOS/iOS: /Users/a0010/Library/Containers/<package_name>/Data/Documents/Messages，，macOS在/Users/a0010/Documents/FlutterUI/4824/Messages
  /// Windows:   C:\Users\Administrator\Documents\FlutterUI\Messages
  /// Android:   /data/user/0/<package_name>/Messages
  Directory get messagesDirectory => _appDirs[0];

  /// @see [getUserDirectory] and [FileCategory]
  String getMessagesCategory(FileCategory category, {String? user}) {
    return getUserDirectory(UserDirectory.messages.dirName, user, category.dirName).path;
  }

  /// 获取缓存文件的子目录 @see [messagesDirectory]
  Directory getUserDirectory(String part1, [String? part2, String? part3, String? part4, String? part5, String? part6]) {
    String parent = join(_userDir.path, part1, part2, part3, part4, part5, part6);
    Directory result = Directory(parent);
    if (!result.existsSync()) {
      result.createSync(recursive: true);
    }
    return result;
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
  Future<String?> save(String fileName, String text, {required String dir}) async {
    try {
      Directory parent = getUserDirectory(dir);
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
  Future<String> read(String path) async {
    File file = File(path);
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
  void clear(String path) async {
    File file = File(path);
    if (file.existsSync()) {
      await file.writeAsString('');
    }
  }

  /// 删除文件（根据路径删除）
  void deleteFile(String? path) {
    try {
      if ((path ?? '').isEmpty) return;
      File file = File(path!);
      if (file.existsSync()) {
        file.deleteSync();
      }
      _log('删除文件成功：path=$path');
    } catch (err) {
      _log('删除文件失败：err=$err');
    }
  }

  /// 删除文件夹的所有文件
  Future delete(String path) async {
    Directory parent = Directory(path);
    parent.listSync().forEach((element) async {
      await element.delete();
      _log('删除成功: ${element.path}');
    });
  }

  /// 格式化文件大小，例：
  /// len  = 2889728
  /// size = 2.88 MB
  String formatSize(int? len) {
    // 小于1024，直接按字节显示
    if (len == null) return '0 B';
    int multiple = 1000; // 字节的倍数
    if (len < multiple) return '$len B';

    List<String> suffix = ["B", "KB", "MB", "GB", "TB", "PB"];
    // 判断字节显示的范围，从KB开始
    int scope = multiple, i = 1;
    for (; i < suffix.length; i++) {
      if (len < scope * multiple) break; //找到范围 scope < len < scope * multiple
      scope *= multiple;
    }

    double res = len / scope; // 得到最终展示的小数
    return '${toStringAsFixed(res)} ${suffix[i]}';
  }

  String toStringAsFixed(dynamic value, {int position = 2}) {
    double num;
    if (value is double) {
      num = value;
    } else {
      num = double.parse(value.toString());
    }

    int index = num.toString().lastIndexOf(".");
    String res;
    if ((num.toString().length - index - 1) < position) {
      res = num.toStringAsFixed(position);
    } else {
      res = num.toString();
    }
    return res.substring(0, index + position + 1).toString();
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
    if (separatorIndex < 0) {
      separatorIndex = 0;
    }
    String parent = '';
    String? name;
    String? fileName;
    String? mimeTypeSuffix;
    int index = path.lastIndexOf('.');
    // 如果不存在文件名称包含.的情况
    if (index < 0) {
      // 在路径的最后面加上/，判断是不是文件夹
      Directory dir = Directory('$path/');
      if (dir.existsSync()) {
        // 是文件夹
        parent = dir.path;
      } else {
        // 是文件
        parent = path.substring(0, separatorIndex);
        // 如果不存在.后缀的路径，直接裁剪到结尾
        fileName = path.substring(separatorIndex + 1);
      }
    } else {
      parent = path.substring(0, separatorIndex);
      name = path.substring(separatorIndex + 1);
      fileName = path.substring(separatorIndex + 1, index);
      if (index + 1 < path.length) {
        mimeTypeSuffix = path.substring(index + 1);
      }
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
  favourites('Favourites'),
  crash('Crash');

  final String dirName;

  const UserDirectory(this.dirName);
}

/// 文件类别
enum FileCategory {
  images('Images'),
  videos('Videos'),
  audios('Audios'),
  files('Files'),
  others('Others');

  final String dirName;

  const FileCategory(this.dirName);
}

/// 文件类型
enum MimeType {
  unknown(value: 0, icon: 'icon_unknown'),
  image(value: 1, icon: 'icon_pic'),
  video(value: 2, icon: 'icon_mp4'),
  audio(value: 3, icon: 'icon_mp3'),
  pdf(value: 4, icon: 'icon_pdf'),
  word(value: 5, icon: 'icon_word'),
  zip(value: 6, icon: 'icon_zip'),
  excel(value: 7, icon: 'icon_xls'),
  txt(value: 8, icon: 'icon_txt'),
  ppt(value: 9, icon: 'icon_ppt'),
  apk(value: 10, icon: 'icon_apk');

  final int value;
  final String icon;

  const MimeType({required this.value, required this.icon});
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
