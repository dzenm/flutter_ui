import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// 原图路径对应的缩略图路径区分
const _thumb = '_thumb';

///
/// Created by a0010 on 2022/9/1 11:56
/// 文件工具类
class FileUtil with _DirectoryMixin {
  FileUtil._internal();

  factory FileUtil() => _instance;
  static final FileUtil _instance = FileUtil._internal();

  /// 删除文件（根据路径删除）
  void delete(String? path) {
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

  /// 格式化字节大小，例：
  /// len  = 2889728
  /// size = 2.88 MB
  String formatByteSize(int? len) {
    // 小于1024，直接按字节显示
    if (len == null) return '0 B';
    int multiple = 1024; // 字节的倍数
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

  /// 计算文件的MD5值
  Future<String> getMD5(String path) async => _calculateFileMd5(path);

  /// 计算文件的MD5值
  Future<String> _calculateFileMd5(String path) async {
    final file = File(path);
    final bytes = await file.readAsBytes();
    return md5.convert(bytes).toString();
  }

  // String _getMd5(String path) {
  //   int partSize = 1024 * 1024 * 3; //默认3m每块
  //   File file = File(path);
  //   int fileSize = file.lengthSync();
  //   int totalPart = (fileSize * 1.0 / partSize).ceil();
  //   int start; //开始读文件的位置
  //   int length; //读取文件的长度
  //   var output = convert.AccumulatorSink<Digest>();
  //   var input = md5.startChunkedConversion(output);
  //   int currentPart = 0;
  //   while (currentPart < totalPart) {
  //     start = currentPart * partSize;
  //     length = (start + partSize > fileSize) ? (fileSize - start) : partSize;
  //     RandomAccessFile raf = file.openSync(mode: FileMode.read);
  //     raf.setPositionSync(start);
  //     Uint8List data = raf.readSync(length);
  //     input.add(data);
  //     currentPart++;
  //   }
  //   input.close();
  //   var digest = output.events.single.toString();
  //   return digest;
  // }

  /// 将浮点数 [value] 转为取 [position] 位的小数的字符串
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
}

/// APP文件夹的具体实现
abstract mixin class _DirectoryMixin {
  static const rootDir = 'FlutterUI'; // APP的根目录文件夹
  static late Directory _appRootDir;
  static late Directory _userDir;
  static final Map<UserDirectory, Directory> _appDirs = {};

  Function? _logPrint;

  /// 初始化文件夹
  Future<void> init({Function? logPrint}) async {
    _logPrint = logPrint;
    _appRootDir = await _getAppRootDirectory();
  }

  /// 缓存文件夹路径 @see [init]、[_appDirs]
  /// Android：/data/user/0/<package_name>/files/{dir}/
  /// iOS：/var/mobile/Containers/Data/Application/{Random ID}/Library/Application Support/{dir}/
  /// macOS：/Users/a0010/Documents/FlutterUI/{dir}/
  /// Windows：C:\Users\Administrator\Documents\FlutterUI\{dir}\
  Future<Directory> _getAppRootDirectory({String? dir}) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appRootDir = join(appDocDir.path);
    if (Platform.isAndroid) {
      appDocDir = await getApplicationSupportDirectory();
      appRootDir = join(appDocDir.path);
    } else if (Platform.isIOS) {
      appDocDir = await getApplicationSupportDirectory();
      appRootDir = join(appDocDir.path);
    } else if (Platform.isMacOS) {
      appRootDir = join(appDocDir.path, rootDir);
    } else if (Platform.isWindows) {
      appRootDir = join(appDocDir.path, rootDir);
    } else if (Platform.isLinux) {
      appRootDir = join(appDocDir.path, rootDir);
    }
    String parent = join(appRootDir, dir);
    Directory result = Directory(parent);
    if (!result.existsSync()) {
      result.createSync(recursive: true);
    }
    return result;
  }

  /// 获取APP的路径
  Directory get appDir => _appRootDir.absolute;

  /// 初始化登录用户目录
  /// Android：/data/user/0/<package_name>/files/{dir}/{userId}/
  /// iOS：/var/mobile/Containers/Data/Application/{Random ID}/Library/Application Support/{dir}/{userId}/
  /// macOS：/Users/a0010/Documents/FlutterUI/{dir}/{userId}/
  /// Windows：C:\Users\Administrator\Documents\FlutterUI\{dir}\{userId}\
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
      _appDirs[dir] = result;
      _log('初始化用户存储目录：path=${result.path}');
    }
  }

  /// 缓存文件夹路径 @see [init]、[_appDirs]
  /// Android：/data/user/0/<package_name>/files/{dir}/{userId}/Messages/
  /// iOS：/var/mobile/Containers/Data/Application/{Random ID}/Library/Application Support/{dir}/{userId}/Messages/
  /// macOS：/Users/a0010/Documents/FlutterUI/{dir}/{userId}/Messages/
  /// Windows：C:\Users\Administrator\Documents\FlutterUI\{dir}\{userId}\Messages\
  Directory get messagesDirectory => _appDirs[UserDirectory.messages]!;

  /// @see [getUserDirectory]
  String getMessagesCategory(FileCategory category, {String? user}) {
    return getUserDirectory(UserDirectory.messages.dirName, user, category.dirName).path;
  }

  /// @see [getUserDirectory]
  String getFavouritesCategory(FileCategory category, {String? user}) {
    return getUserDirectory(UserDirectory.favourites.dirName, user, category.dirName).path;
  }

  /// 获取缓存文件的子目录 @see [messagesDirectory]
  Directory getUserDirectory(
    String part1, [
    String? part2,
    String? part3,
    String? part4,
    String? part5,
    String? part6,
  ]) {
    String parent = join(_userDir.path, part1, part2, part3, part4, part5, part6);
    Directory result = Directory(parent);
    if (!result.existsSync()) {
      result.createSync(recursive: true);
    }
    return result;
  }

  String getCopyFilePath(String fileName) {
    return '';
  }

  void _log(String text) => _logPrint == null ? null : _logPrint!(text, tag: 'FileUtil');
}

/// 对路径进行解析获取常用的字符信息
/// [path] 是路径的完整信息，[parent] 是文件的父文件夹，[name] 是文件的全
/// 称，[fileName] 是文件不含有后缀的名称，[extension] 是文件的后缀信息
///
/// 例子
///   PathInfo info = PathInfo.parse(path); // path='/Users/a0010/336a.png'
///   print(info.path); // /Users/a0010/336a.png
///   print(info.parent) // /Users/a0010/
///   print(info.name) // 336a.png
///   print(info.fileName) // 336a
///   print(info.extension) // png
class PathInfo {
  String get path => _path; // 文件路径
  String _path = '';

  String get parent => _parent; // 文件所在的文件夹
  String _parent = '';

  String? get name => _name; // 文件的名称，带后缀
  String get __name => _name ?? '';
  String? _name;

  String? get fileName => _fileName; // 文件的名称，不带后缀
  String get __fileName => _fileName ?? '';
  String? _fileName;

  String? get extension => _extension; // 文件后缀类型
  String get __extension => _extension ?? '';
  String? _extension;

  PathInfo._({
    required String path,
    required String parent,
    String? name,
    String? fileName,
    String? extension,
  })  : _path = path,
        _parent = parent,
        _name = name,
        _fileName = fileName,
        _extension = extension;

  /// path=/Users/a0010/Documents/cache/5e6b6e5de3524abf9002540932652b38/Images/336ae1a1dff74c3292c06bdff09af061_WX20231130-160703@2x.png
  /// name=336ae1a1dff74c3292c06bdff09af061_WX20231130-160703@2x.png
  /// fileName=336ae1a1dff74c3292c06bdff09af061_WX20231130-160703@2x
  /// parent=/Users/a0010/Documents/cache/5e6b6e5de3524abf9002540932652b38/Images
  /// suffix=png
  factory PathInfo.parse(String path) {
    int separatorIndex = path.lastIndexOf(Platform.pathSeparator);
    if (separatorIndex < 0) {
      separatorIndex = 0;
    }
    String parent = '';
    String? name;
    String? fileName;
    String? extension;
    int index = path.lastIndexOf('.');
    // 如果不存在文件名称包含.的情况
    if (index < 0) {
      // 在路径的最后面加上/，判断是不是文件夹
      Directory dir = Directory('$path${Platform.pathSeparator}');
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
        extension = path.substring(index + 1);
      }
    }
    return PathInfo._(
      path: path,
      parent: parent,
      name: name,
      fileName: fileName,
      extension: extension?.toLowerCase(),
    );
  }

  /// file=/Users/a0010/Documents/cache/5e6b6e5de3524abf9002540932652b38/Images/336ae1a1dff74c3292c06bdff09af061_WX20231130-160703@2x.png
  /// suffix=thumb_
  /// addFileNamePrefix=/Users/a0010/Documents/cache/5e6b6e5de3524abf9002540932652b38/Images/thumb_336ae1a1dff74c3292c06bdff09af061_WX20231130-160703@2x.png
  String addFileNamePrefix(String prefix) {
    assert(() {
      if (isDirectory) {
        throw FlutterError('PathInfo parse\'s path is directory, Can\'t addFileNamePrefix in name(name=$name)');
      }
      return true;
    }());
    return join(_parent, '$prefix$__fileName.$__extension');
  }

  /// file=/Users/a0010/Documents/cache/5e6b6e5de3524abf9002540932652b38/Images/thumb_336ae1a1dff74c3292c06bdff09af061_WX20231130-160703@2x.png
  /// suffix=thumb_
  /// removeFileNamePrefix=/Users/a0010/Documents/cache/5e6b6e5de3524abf9002540932652b38/Images/336ae1a1dff74c3292c06bdff09af061_WX20231130-160703@2x_thumb.png
  String removeFileNamePrefix(String prefix) {
    if (__fileName.isEmpty) return _path;
    String fileName = __fileName;
    if (fileName.startsWith(prefix)) {
      fileName = fileName.substring(prefix.length);
    }
    return join(_parent, '$fileName.$__extension');
  }

  /// file=/Users/a0010/Documents/cache/5e6b6e5de3524abf9002540932652b38/Images/336ae1a1dff74c3292c06bdff09af061_WX20231130-160703@2x.png
  /// suffix=_thumb
  /// addFileNameSuffix=/Users/a0010/Documents/cache/5e6b6e5de3524abf9002540932652b38/Images/336ae1a1dff74c3292c06bdff09af061_WX20231130-160703@2x_thumb.png
  String addFileNameSuffix(String suffix) {
    assert(() {
      if (isDirectory) {
        throw FlutterError('PathInfo parse\'s path is directory, Can\'t addFileNameSuffix in name(name=$name)');
      }
      return true;
    }());
    return join(_parent, '$__fileName$suffix.$__extension');
  }

  /// file=/Users/a0010/Documents/cache/5e6b6e5de3524abf9002540932652b38/Images/336ae1a1dff74c3292c06bdff09af061_WX20231130-160703@2x_thumb.png
  /// suffix=_thumb
  /// removeFileNameSuffix=/Users/a0010/Documents/cache/5e6b6e5de3524abf9002540932652b38/Images/336ae1a1dff74c3292c06bdff09af061_WX20231130-160703@2x.png
  String removeFileNameSuffix(String suffix) {
    if (__fileName.isEmpty) return _path;
    String fileName = __fileName;
    if (fileName.endsWith(suffix)) {
      fileName = fileName.substring(0, fileName.lastIndexOf(suffix));
    }
    return join(_parent, '$fileName.$__extension');
  }

  /// 文件名称起始或者终止位置是否包含字符串
  bool nameContains(String fix) {
    if (__fileName.isEmpty) return false;
    return __fileName.startsWith(fix) || __fileName.endsWith(fix);
  }

  /// 获取缩略图文件路径
  String get thumbPath => nameContains(_thumb) ? _path : addFileNameSuffix(_thumb);

  /// 获取原文件路径
  String get originPath => nameContains(_thumb) ? removeFileNameSuffix(_thumb) : _path;

  /// 复制到指定文件夹
  String copyPath(String parent) => join(parent, __fileName);

  /// 获取文件类型
  MimeType get mimeType => mimeTypes[__extension] ?? MimeType.unknown;

  /// 是否是Gif图
  bool get isGif => __extension == 'gif';

  /// 是否是文件夹
  bool get isDirectory => __name.isEmpty;

  @override
  String toString() {
    return '$runtimeType='
        '{path: $path, '
        'parent: $parent, '
        'name: $name, '
        'fileName: $fileName, '
        'extension: $extension}';
  }
}

/// 用户目录
enum UserDirectory {
  messages('Messages'),
  databases('Databases'),
  favourites('Favourites'),
  files('Files'),
  crash('Crash'),
  temp('Temp');

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
