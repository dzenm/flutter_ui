import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

///
/// Created by a0010 on 2023/8/15 15:23
///
class ImageView extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Alignment alignment;
  final bool isOrigin;
  final Widget? placeholder;
  final Widget? errorPlaceholder;

  const ImageView({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.isOrigin = false,
    this.placeholder,
    this.errorPlaceholder,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;

    Widget defaultPlaceholder = placeholder ?? ImagePlaceholder(width: width ?? 50);
    String imageUrl = url;
    if (imageUrl.isEmpty) {
      // 图片为空，使用默认的占位图
      child = defaultPlaceholder;
    } else {
      bool isNetworkImage = imageUrl.startsWith('https://') || imageUrl.startsWith('http://');
      // /Users/dzenm/
      bool isPath = imageUrl.startsWith(Platform.pathSeparator);
      if (Platform.isWindows) {
        // 适配Windows的路径问题
        // C:\Users\dzenm
        isPath = imageUrl.contains(Platform.pathSeparator);
      }
      if (isNetworkImage) {
        // 网络图片文件
        child = CachedNetworkImage(
          imageUrl: imageUrl,
          fit: fit,
          width: width,
          height: height,
          alignment: alignment,
          placeholder: (_, url) => defaultPlaceholder,
          errorWidget: (_, url, error) => errorPlaceholder ?? _defaultErrorPlaceholder(width, height: height),
          cacheManager: isNetworkImage ? ImageCacheManager() : null,
          placeholderFadeInDuration: const Duration(milliseconds: 100),
          matchTextDirection: true,
        );
      } else if (isPath) {
        // 本地图片文件
        File? file;
        if (!isOrigin) {
          file = File(imageUrl); //展示取出缩略图
        }
        // 展示原图/缩略图不存在
        if (file == null || !file.existsSync()) {
          file = File(imageUrl); //展示原图
        }
        if (file.existsSync()) {
          // 文件存在
          child = Image.file(
            file,
            fit: fit,
            width: width,
            height: height,
            alignment: alignment,
            gaplessPlayback: true,
          );
        } else {
          // 文件不存在，先展示错误提醒的占位图，没有再展示默认图
          child = errorPlaceholder ?? defaultPlaceholder;
        }
      } else {
        // 资源图片文件
        child = Image.asset(
          imageUrl,
          fit: fit,
          width: width,
          height: height,
          alignment: alignment,
          gaplessPlayback: true,
        );
      }
    }
    return child;
  }

  Widget _defaultErrorPlaceholder(double? width, {double? height}) {
    double w = width ?? 50;
    double h = height ?? w;
    return ImagePlaceholder(
      width: w,
      height: h,
      color: Colors.grey,
      child: Column(children: [
        Icon(Icons.broken_image_rounded, color: Colors.white, size: min(w, h) / 2),
        SizedBox(height: h / 20),
        Text("无法加载此图片", style: TextStyle(color: Colors.white, fontSize: min(w, h) / 10)),
      ]),
    );
  }
}

/// 占位图
class ImagePlaceholder extends StatelessWidget {
  final double width;
  final double? height;
  final Widget? child;
  final Color color;

  const ImagePlaceholder({
    super.key,
    required this.width,
    this.height,
    this.child,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height ?? width,
      color: color,
      alignment: Alignment.center,
      child: child,
    );
  }
}

/// 缓存管理
class ImageCacheManager extends CacheManager {
  static const key = 'CustomImageCacheManager';

  static ImageCacheManager? _instance;

  factory ImageCacheManager() {
    _instance ??= ImageCacheManager._();
    return _instance!;
  }

  ImageCacheManager._() : super(Config(key, fileService: CustomHttpFileService()));
}

/// 自定义文件下载处理
class CustomHttpFileService extends FileService {
  HttpClient? _httpClient;

  CustomHttpFileService() {
    _httpClient = HttpClient();
    _httpClient!.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }

  @override
  Future<FileServiceResponse> get(String url, {Map<String, String>? headers = const {}}) async {
    final Uri resolved = Uri.base.resolve(url);
    final HttpClientRequest req = await _httpClient!.getUrl(resolved);
    headers?.forEach((key, value) {
      req.headers.add(key, value);
    });
    final HttpClientResponse httpResponse = await req.close();
    final http.StreamedResponse response = http.StreamedResponse(
      httpResponse.timeout(const Duration(seconds: 60)),
      httpResponse.statusCode,
      contentLength: httpResponse.contentLength,
      reasonPhrase: httpResponse.reasonPhrase,
      isRedirect: httpResponse.isRedirect,
    );
    return HttpGetResponse(response);
  }
}

/// 文件图片扩展
class FileImageExt extends FileImage {
  const FileImageExt(super.file, {super.scale});

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is FileImageExt &&
        file.path == other.file.path &&
        scale == other.scale //l 文件不存在兼容
        &&
        (file.existsSync() ? file.lengthSync() : 0) == (other.file.existsSync() ? other.file.lengthSync() : 0);
  }

  @override
  int get hashCode => Object.hash(file.path, scale);
}
