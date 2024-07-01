import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:scan/scan.dart';

import '../../base/base.dart';

class ImageUtil {
  static const String tinySuffix = '_tiny';
  static const String thumbSuffix = '_thumb';
  static const String sizeSuffix = 'size';
  static const String originImageSuffix = '_o';

  /// 根据图片链接后缀获取图片尺寸
  /// 示例：[https://192.168.1.129/images/app/circle/20231008094730669_o.jpg?size=720*1600]
  /// 注：请求接口 POST /fileUpload/upload/{type} 朋友圈、聊天文件的上传 返回的 图片、视频 都会携带 size 后缀，目前涉及场景应该只包括 朋友圈、聊天
  static Size? getImageSize(String url) {
    if (!url.startsWith("http")) {
      return null;
    }
    Uri uri = Uri.parse(url);
    var params = uri.queryParameters;
    String? value = params[sizeSuffix];
    if ((value ?? '').isNotEmpty) {
      int index = value!.indexOf('*');
      double width = double.parse(value.substring(0, index));
      double height = double.parse(value.substring(index + 1));
      return Size(width, height);
    }
    return null;
  }

  /// 根据视频url获取视频缩略图路径
  static String getVideoThumbPath(String path) {
    PathInfo info = PathInfo.parse(path);
    String imgPath = path;
    try {
      String sizeStr = '';
      bool isVideo = info.mimeType == MimeType.video;
      var sizeSuffix = '?size=';
      if (imgPath.contains(sizeSuffix)) {
        // 获取去除尺寸后缀的视频路径
        String noSizeSuffixPath = path.split(sizeSuffix)[0];
        isVideo = noSizeSuffixPath.endsWith('.mp4');
        // 获取尺寸后缀数据
        sizeStr = sizeSuffix + path.split(sizeSuffix)[1];
      }
      if (isVideo) {
        //朋友圈草稿的mp4文件可以不需要加_o
        imgPath = imgPath.substring(0, path.lastIndexOf('.'));
        if (imgPath.endsWith("_o")) {
          //_o后缀去除显示
          imgPath = imgPath.substring(0, path.lastIndexOf('_'));
        }
        imgPath += '.png';
        imgPath += sizeStr;
      }
    } catch (e) {
      Log.e('获取视频缩略图路径：$e');
    }
    return imgPath;
  }

  /// 获取小图展示图路径
  static String getTinyImagePath(String path) {
    try {
      List<String> list = splitPathSuffix(path);
      String replaceName = thumbSuffix; //l 小图后缀
      return '${list[0]}$replaceName${list[1]}';
    } catch (e) {
      Log.e('获取缩略图后缀错误：$e');
    }
    return path;
  }

  //l 点击查看原图 _o后缀拼接
  static String getOriginUrl(String path, {String suffix = originImageSuffix}) {
    String rootPath = path.substring(0, path.lastIndexOf('.'));
    if (!rootPath.endsWith(suffix)) {
      //不是原图 - 做拼接
      rootPath = "$rootPath$suffix";
      return "$rootPath${path.substring(path.lastIndexOf('.'), path.length)}"; //后缀拼接
    }
    return path; //已经是原图 - 直接返回即可
  }

  /// 判断是否是原图
  static bool isOriginPath(String path, {String suffix = originImageSuffix}) {
    String rootPath = path.substring(0, path.lastIndexOf('.'));
    return rootPath.endsWith(suffix);
  }

  /// 文件路径去除[suffix]后缀  保留了version后缀
  static String getThumbUrl(String path, {String suffix = originImageSuffix}) {
    String rootPath = path.substring(0, path.lastIndexOf('.'));
    if (rootPath.endsWith(suffix)) {
      //不是原图 - 做拼接
      rootPath = rootPath.substring(0, path.lastIndexOf('_'));
      return "$rootPath${path.substring(path.lastIndexOf('.'), path.length)}"; //后缀拼接
    }
    return path;
  }

  /// 移除路径的后缀
  static String removePathSuffix(String? path, {String suffix = originImageSuffix}) {
    if (path == null || path.isEmpty) return '';
    int index = path.lastIndexOf('.');
    String fileName = path.substring(0, index);
    if (fileName.endsWith(suffix)) {
      fileName = fileName.substring(0, path.lastIndexOf('_'));
    }
    return '$fileName.png';
  }

  /// 根据路径分割名称和后缀
  static List<String> splitPathSuffix(String? path) {
    List<String> list = List.generate(2, (index) => '');
    if (path == null || path.isEmpty) return list;
    int index = path.lastIndexOf('.');
    if (index > -1) {
      list[0] = path.substring(0, index); //路径名称
      list[1] = path.substring(path.lastIndexOf('.')); // 路径后缀
    } else {
      list[0] = path; //路径名称
    }
    return list;
  }

  ///l 判断图片是否是gif动图
  static bool isGif(String path) {
    if (path.lastIndexOf('.') <= 0) return false;
    String fileSuffix = path.substring(path.lastIndexOf('.') + 1);
    var result = fileSuffix.toLowerCase() == 'gif';
    return result;
  }

  static int getFileType(String path) {
    return PathInfo.parse(path).mimeType.value;
  }

  static String getFileIcon(String path) {
    var fileType = PathInfo.parse(path).mimeType;
    String icon = fileType.icon;
    if (icon == MimeType.apk.icon) {
      icon = MimeType.unknown.icon;
    }
    return '${Assets.iconsPath}$icon.png';
  }

  /// 识别图片二维码
  static Future<String?> parseQrCode(String filePath, Function callback) async {
    if (!File(filePath).existsSync()) {
      return '图片未找到';
    }
    String? result = await Scan.parse(filePath);
    if ((result ?? '').isEmpty) {
      return '无法识别';
    }
    callback(result);
    return null;
  }

  /// 解析二维码
  /// [qrCode] 二维码携带的信息
  /// @return 如果解析失败，返回失败的信息，List只含有一个信息，如果解析成功，返回解析后的结果，含有多个信息
  static List<String> decodeQrCode(String qrCode) {
    List<String> items = [];
    Log.d('识别后的二维码信息: qrCode=$qrCode');
    // qrCode = EncryptUtil.decryptAes(qrCode); // 先解密
    Log.d('解密后的二维码信息: qrCode=$qrCode');
    if (!qrCode.contains('md=') || !qrCode.contains('uid=')) {
      items.add('无效二维码');
      return items;
    }

    List<String> results = qrCode.split('&uid=');
    String clusterUid = results[0].substring(4);
    String userUid = results[1];
    String expireDate = ""; //l 群二维码失效时间
    if (clusterUid == 'cluster' && qrCode.contains('expire=')) {
      List<String> expires = qrCode.split('&expire=');
      String expireTime = '${expires[1]}000'; //l 有效时间 - 时间戳
      DateTime expire = DateTime.fromMicrosecondsSinceEpoch(int.parse(expireTime));
      expireDate = expire.toString();

    }
    items.add(clusterUid); // 分享的群ID
    items.add(userUid); // 分享二维码的用户ID
    items.add(expireDate); // 二维码失效时间
    return items;
  }

  /// 根据原图路径处理获取缩略图的尺寸
  static Future<Size?> getThumbImageSize(String path) async {
    if (PathInfo.parse(path).isGif) {
      // 如果文件不存在/Gif不处理
      return null;
    }

    Size? size = await decodeImageSize(path);
    return calculateShowImageSize(size);
  }

  /// 获取缩略图路径
  static Future<String> getThumbImage(String path, Size size) async {
    PathInfo info = PathInfo.parse(path);
    String thumbPath = info.addFileNameSuffix(thumbSuffix);
    final cmd = img.Command()
      ..decodeImageFile(path)
      ..copyResize(width: size.width.toInt(), height: size.height.toInt())
      ..writeToFile(thumbPath);

    try {
      await cmd.executeThread();
    } catch (e) {
      FileUtil().copy(path, thumbPath);
    }
    return thumbPath;
  }

  /// 解析图片获取尺寸大小
  /// [isZip] 是否需要压缩(如果值为true，超过1M需要压缩，反之则不压缩)
  static Future<Size?> decodeImageSize(String path, {bool isZip = true}) async {
    try {
      File originFile = File(path);
      if (isZip) {
        // 判断是否大于1M，是则压缩一次，防止分析图像过大产生内存溢出
        int fileSize = originFile.lengthSync();
        if (fileSize / 1024 / 1024 > 1) {}
      }

      // 根据路径获取本地图片的尺寸
      var image = await decodeImageFromList(originFile.readAsBytesSync());
      return Size(image.width.toDouble(), image.height.toDouble());
    } catch (e) {
      Log.i("获取小图失败：${e.toString()}");
    }
    return null;
  }

  /// 计算图片展示尺寸在指定范围内展示，[minSize] <= [size] <= [maxSize]
  static Size? calculateShowImageSize(Size? size, {Size minSize = const Size(60, 0), Size maxSize = const Size(145, 120)}) {
    if (size == null || size.height <= 0 || size.width <= 0) return size;
    double width = 0, height = 0;
    // 如果宽度大于长度
    if (size.width > size.height) {
      width = size.width < minSize.width ? minSize.width : min(size.width, maxSize.width);
      height = (size.height * width) / size.width;
      height = max(height, minSize.height);
    } else {
      height = min(size.height, maxSize.height);
      width = (size.width * height) / size.height;
      width = max(width, minSize.width);
    }
    return Size(width, height);
  }

  /// 将 [Uint8List] 转 [ui.Image]
  static Future<ui.Image> toImage(Uint8List list) async {
    ui.Codec codec = await ui.instantiateImageCodec(list);
    // 方式一
    ui.FrameInfo frame = await codec.getNextFrame();
    return frame.image;
    // 方式二
    // ui.Image? image;
    // // ui.decodeImageFromList(list, (ui.Image img) { image = img; });
    // return image!;
  }

  /// 将 [ui.Image] 转 [Uint8List]
  static Future<Uint8List?> toByte(ui.Image image) async {
    ByteData? byteData = await image.toByteData();
    if (byteData != null) {
      Uint8List bytes = byteData.buffer.asUint8List();
      return bytes;
    }
    return null;
  }
}
