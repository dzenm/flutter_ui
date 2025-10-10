import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// 执行文件的进度
/// [currentPath] 当前执行的文件路径
/// [length] 当前执行的文件大小
/// [count] 已执行文件的总文件个数
/// [size] 已执行文件的总大小
typedef ProgressCallback = void Function(String currentPath, int length, int count, int size);

/// 执行文件已完成
/// [count] 已执行文件的总文件个数
/// [size] 已执行文件的总大小
typedef CompleteCallback = void Function(int count, int size);

///
/// Created by a0010 on 2022/9/1 11:56
/// 文件工具类
class LocalStorage with _DirMixin, _FileIOMixin, _FileHelperMixin {
  factory LocalStorage() => _instance; //
  static final LocalStorage _instance = LocalStorage._internal(); //
  LocalStorage._internal(); //
}

/// APP文件夹的具体实现
mixin class _DirMixin {
  late _DirPairs _dirs;

  Function? _logPrint;

  /// 初始化文件夹
  /// [rootDir] APP的根目录文件夹，可以切换指定文件夹路径进行存储数据
  /// [appDirName] 桌面端的APP文件名名称
  Future<void> init({
    Function? logPrint,
    String? rootDir,
    String appDirName = 'File',
  }) async {
    if (logPrint != null) {
      _logPrint = logPrint;
    }
    var dir = await _getAppRootDirectory(
      rootDir: rootDir,
      appDirName: appDirName,
    );
    _dirs = _DirPairs(dir);
    // 初始化非用户文件夹
    initLoginUserDirectory("");
  }

  /// 缓存文件夹路径 @see [init]、[_appDirs]
  /// Android：/data/user/0/<package_name>/files/[dir]/
  /// iOS：/var/mobile/Containers/Data/Application/{Random ID}/Library/Application Support/[dir]/
  /// macOS：/Users/a0010/Documents/[appDirName]/[dir]/
  /// Windows：C:\Users\Administrator\Documents\[appDirName]\[dir]\
  Future<Directory> _getAppRootDirectory({
    String? rootDir,
    String? appDirName,
    String? dir,
  }) async {
    String appRootDir; // 默认的APP存储路径
    if (Platform.isAndroid || Platform.isIOS) {
      // 移动端的存储路径
      Directory appDocDir = await getApplicationSupportDirectory();
      appRootDir = join(appDocDir.path);
    } else {
      // 桌面端的存储
      Directory appDocDir = await getApplicationDocumentsDirectory();
      appRootDir = join(appDocDir.path, appDirName);
    }
    String parent = join(rootDir ?? appRootDir, dir); // app root dir
    Directory result = Directory(parent);
    if (!result.existsSync()) {
      result.createSync(recursive: true);
    }
    return result;
  }

  Directory get appDir => _dirs.appDir; // APP文件夹
  Directory get userDir => _dirs.userDir; // 用户文件夹

  /// 初始化登录用户目录
  /// Android：/data/user/0/<package_name>/files/{dir}/{userId}/
  /// iOS：/var/mobile/Containers/Data/Application/{Random ID}/Library/Application Support/{dir}/{userId}/
  /// macOS：/Users/a0010/Documents/[_appDir]/{dir}/{userId}/
  /// Windows：C:\Users\Administrator\Documents\[_appDir]\{dir}\{userId}\
  void initLoginUserDirectory(String userId) {
    _dirs.setUserUid(userId);
    // 初始化常用文件夹
    for (var root in RootDir.values) {
      String parent = join(_dirs.appPath, root == RootDir.user ? userId : "global");
      if (root == RootDir.user && userId.isEmpty) continue;
      for (var dir in UserDir.values) {
        String dirName = join(parent, dir.dirName);
        Directory result = Directory(dirName);
        if (!result.existsSync()) {
          result.createSync(recursive: true);
        }
        _dirs.setDir(root, dir, result);
        _log('初始化用户存储目录：path=${result.path}');
      }
    }
  }

  /// 缓存文件夹路径 @see [init]、[_appDirs]
  /// Android：/data/user/0/<package_name>/files/{dir}/{userId}/Messages/
  /// iOS：/var/mobile/Containers/Data/Application/{Random ID}/Library/Application Support/{dir}/{userId}/Messages/
  /// macOS：/Users/a0010/Documents/[_appDir]/{dir}/{userId}/Messages/
  /// Windows：C:\Users\Administrator\Documents\[_appDir]\{dir}\{userId}\Messages\
  Directory get messagesDir => _dirs.getDir(RootDir.user, UserDir.messages);

  /// 缓存文件夹路径 @see [init]、[_appDirs]
  /// Android：/data/user/0/<package_name>/files/{dir}/{userId}/Files/
  /// iOS：/var/mobile/Containers/Data/Application/{Random ID}/Library/Application Support/{dir}/{userId}/Files/
  /// macOS：/Users/a0010/Documents/[_appDir]/{dir}/{userId}/Files/
  /// Windows：C:\Users\Administrator\Documents\[_appDir]\{dir}\{userId}\Files\
  Directory get filesDir => _dirs.getDir(RootDir.user, UserDir.files);

  /// @see [getUserDirectory]
  String getMessagesCategory(FileCategory category, {String? user}) {
    return getUserDirectory(UserDir.messages.dirName, user, category.dirName).path;
  }

  /// @see [getUserDirectory]
  String getFavouritesCategory(FileCategory category, {String? user}) {
    return getUserDirectory(UserDir.favourites.dirName, user, category.dirName).path;
  }

  /// 获取指定的文件夹
  String getDir({RootDir rootDir = RootDir.user, UserDir userDir = UserDir.files}) {
    Directory dir = _dirs.getDir(rootDir, userDir);
    return dir.path;
  }

  /// 获取缓存文件的子目录 @see [messagesDir]
  Directory getUserDirectory(
    String part1, [
    String? part2,
    String? part3,
    String? part4,
    String? part5,
    String? part6,
  ]) {
    String parent = join(_dirs.userPath, part1, part2, part3, part4, part5, part6);
    Directory result = Directory(parent);
    if (!result.existsSync()) {
      result.createSync(recursive: true);
    }
    return result;
  }

  String joins(
    String part1, [
    String? part2,
    String? part3,
    String? part4,
    String? part5,
    String? part6,
    String? part7,
    String? part8,
    String? part9,
    String? part10,
    String? part11,
    String? part12,
    String? part13,
    String? part14,
    String? part15,
    String? part16,
  ]) {
    return join(
      part1,
      part2,
      part3,
      part4,
      part5,
      part6,
      part7,
      part8,
      part9,
      part10,
      part11,
      part12,
      part13,
      part14,
      part15,
      part16,
    );
  }

  /// 根据原文件 [path] 获取复制后重命名 [fileName] 的文件地址
  /// path=/data/user/0/[_appDir]/document/1256381735362131.png
  /// fileName=hash123456789
  /// @return /data/user/0/[_appDir]/files/df662a0559204dd58d9c3441e0046763/Files/hash123456789.png
  String getCopyFilePath(String path, String fileName, {String? extension}) {
    String pathExtension = extension ?? '';
    if (pathExtension.isEmpty) {
      PathInfo info = PathInfo.parse(path);
      pathExtension = info.extension ?? '';
    }
    String copyPath = join(filesDir.path, '$fileName.$pathExtension');
    return copyPath;
  }

  void _log(String text) => _logPrint == null ? null : _logPrint!(text, tag: 'LocalStorage');
}

/// 文件IO操作
mixin class _FileIOMixin {
  /// 读取文件的字符串
  /// [path] 读取的文件路径
  Future<String> readString(String? path) async {
    if (path == null || path.isEmpty) {
      return "";
    }
    File file = File(path);
    if (!await file.exists()) {
      return "";
    }
    return file.readAsString();
  }

  /// 写入字符串到文件
  /// [path] 写入的文件路径
  /// [text] 写入的文件内容
  Future<File?> writeString(String? path, String? text) async {
    if (path == null || path.isEmpty) {
      return null;
    }
    if (text == null || text.isEmpty) {
      return null;
    }
    File file = File(path);
    if (!await file.exists()) {
      Directory dir = file.parent;
      await dir.create(recursive: true);
    }
    return file.writeAsString(text);
  }

  /// 读取文件的二进制流并转化为字符串
  /// [path] 读取的文件路径
  Future<String> readBinaryAsString(String? path) async {
    try {
      if (path == null || path.isEmpty) {
        return "";
      }
      File file = File(path);
      if (!await file.exists()) {
        return "";
      }
      final sink = file.openRead();
      var contents = sink.transform(utf8.decoder).transform(const LineSplitter());
      StringBuffer sb = StringBuffer();
      await for (var text in contents) {
        sb.write(text);
      }
      return sb.toString();
    } catch (err) {
      return "";
    }
  }

  /// 字符串转化为二进制流写入到文件
  /// [path] 写入的文件路径
  /// [text] 写入的文件内容
  Future<File?> writeStringAsBinary(String? path, String? text) async {
    try {
      if (path == null || path.isEmpty) {
        return null;
      }
      if (text == null || text.isEmpty) {
        return null;
      }
      File file = File(path);
      if (!await file.exists()) {
        Directory dir = file.parent;
        await dir.create(recursive: true);
      }
      List<String> lines = text.split("\n");
      final sink = file.openWrite(mode: FileMode.write);
      final encoder = utf8.encoder;
      for (var line in lines) {
        sink.add(encoder.convert('$line\n')); // 写入每一行数据，并添加换行符
      }
      await sink.close(); // 写入完成关闭流
      return file;
    } catch (err) {
      return null;
    }
  }

  /// 删除文件（根据路径删除）
  /// [path] 删除的文件路径
  void delete(String? path) {
    try {
      if ((path ?? '').isEmpty) return;
      File file = File(path!);
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (err) {
      print(err);
    }
  }

  /// 拷贝文件
  /// [oldPath] 拷贝的文件旧路径
  /// [newPath] 拷贝的文件新路径
  void copy(String oldPath, String newPath) {
    File oldFile = File(oldPath);
    try {
      oldFile.copySync(newPath);
    } catch (err) {
      print(err);
    }
  }

  /// 拷贝文件夹
  /// [oldDir] 拷贝的旧文件夹
  /// [newDir] 拷贝的新文件夹
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

  /// 保存文本至指定的文件夹
  /// [dir] 文件所在的文件夹路径
  /// [fileName] 文件名称
  /// [text] 文件存储的内容
  Future<String?> save(String dir, String fileName, String text) async {
    try {
      Directory parent = Directory(dir);
      File file = File('${parent.path}${Platform.pathSeparator}$fileName');
      if (!file.existsSync()) {
        await file.create();
      }
      IOSink slink = file.openWrite(mode: FileMode.append);
      slink.write(text);
      await slink.close();
      return Future.value(file.path);
    } catch (e) {
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
}

/// 文件工具操作
mixin class _FileHelperMixin {
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
  Future<String> getMD5(String path) async => await _calculateFileMd5(path);

  /// 计算文件的MD5值
  Future<String> _calculateFileMd5(String path) async {
    final file = File(path);
    if (file.existsSync()) {
      final bytes = await file.readAsBytes();
      return md5.convert(bytes).toString();
    }
    return '';
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

/// 文件夹表
class _DirPairs {
  String get appPath => _dir.path; // APP文件夹路径
  Directory get appDir => _dir; // APP文件夹
  final Directory _dir; // APP文件夹
  String get userPath => userDir.path; // 用户文件夹路径
  Directory get userDir => _dirs[RootDir.user]!.values.first.parent; // 用户文件夹

  _DirPairs(this._dir);

  String _userUid = ""; // 用户ID
  void setUserUid(String userUid) => _userUid = userUid; // 设置用户ID
  final Map<RootDir, Map<UserDir, Directory>> _dirs = {}; // 文件夹集合
  Directory getDir(RootDir rootDir, UserDir userDir) => _dirs[rootDir]![userDir]!; // 获取指定的文件夹
  // 设置指定的文件夹
  void setDir(RootDir rootDir, UserDir key, Directory value) {
    Map<UserDir, Directory>? myDirs = _dirs[rootDir];
    if (myDirs == null) {
      myDirs = {key: value};
      _dirs[rootDir] = myDirs;
    } else {
      myDirs[key] = value;
    }
  }

  Map<String, dynamic> toJson() => {
        "appPath": appPath,
        "userPath": userPath,
        ..._dirs.map((key, value) => MapEntry(key.toString(), value)),
      };
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
  /// 原图路径对应的缩略图路径区分
  static const _thumb = '_thumb';

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
    return '${objectRuntimeType(this, 'PathInfo')}='
        '{path: $path, '
        'parent: $parent, '
        'name: $name, '
        'fileName: $fileName, '
        'extension: $extension}';
  }
}

/// 文件扫描
class FileScanner {
  FileScanner(this._path);

  final String _path;

  int _count = 0;
  int _size = 0;

  bool _refreshing = false;
  bool _scanning = false;

  void scan({
    ProgressCallback? onProgress,
    CompleteCallback? onComplete,
  }) async {
    if (_refreshing) {
      return;
    }
    _refreshing = true;

    _count = 0;
    _size = 0;
    try {
      _scanning = true;
      await _scanDir(Directory(_path), onProgress: onProgress);
      _scanning = false;
    } catch (e, st) {
      assert(false, 'Failed to scan directory: path=$_path, $e, $st');
    }
    _refreshing = false;
    if (onComplete != null) {
      onComplete(_count, _size);
    }
  }

  void dispose() {
    _scanning = false;
  }

  Future<void> _scanDir(
    Directory dir, {
    ProgressCallback? onProgress,
  }) async {
    Stream<FileSystemEntity> files = dir.list(recursive: true, followLinks: true);
    LocalStorage()._log('Scanning directory: $dir');
    await files.forEach((item) async {
      if (!_scanning) return;
      // directories, files, and links
      // does not include the special entries `'.'` and `'..'`.
      if (item is Directory) {
        await _scanDir(item);
      } else if (item is File) {
        try {
          int length = await item.length();
          if (length < 0) {
            LocalStorage()._log('File check error: file=$item, length=$length');
          } else {
            _count += 1;
            _size += length;
            if (onProgress != null) {
              onProgress(item.path, length, _count, _size);
            }
          }
        } catch (e, st) {
          assert(false, 'Failed to check file: file=$_path, $e, $st');
        }
      } else {
        assert(false, 'Ignore link: $item');
      }
    });
  }
}

/// 根目录文件夹
enum RootDir {
  global,
  user;
}

/// 用户目录
enum UserDir {
  messages('Messages'),
  databases('Databases'),
  favourites('Favourites'),
  files('Files'),
  crash('Crash'),
  temp('Temp');

  final String dirName; //
  const UserDir(this.dirName); //
}

/// 文件类别
enum FileCategory {
  images('Images'),
  videos('Videos'),
  audios('Audios'),
  files('Files'),
  others('Others');

  final String dirName; //
  const FileCategory(this.dirName); //
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

  final int value; //
  final String icon; //
  const MimeType({required this.value, required this.icon}); //
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
  'mov': MimeType.video,
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
  'docx': MimeType.word,
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
