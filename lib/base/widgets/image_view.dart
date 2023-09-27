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
  final bool origin;
  final Widget? placeholder;
  final Widget? errorPlaceholder;

  const ImageView({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.origin = false,
    this.placeholder,
    this.errorPlaceholder,
  });

  @override
  Widget build(BuildContext context) {
    Widget defaultPlaceholder = placeholder ?? ImagePlaceholder(width: width ?? 50);
    String imageUrl = url;
    if (imageUrl.isEmpty) {
      return defaultPlaceholder;
    }

    bool isNetworkImage = imageUrl.startsWith('http');
    if (!isNetworkImage) {
      File? file;
      if (!origin) {
        file = File(imageUrl);
      }
      if (file == null || !file.existsSync()) {
        file = File(imageUrl);
      }
      if (file.existsSync()) {
        return Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          gaplessPlayback: true,
        );
      }
      return errorPlaceholder ?? defaultPlaceholder; // 无本地资源则返回默认图
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      alignment: alignment,
      placeholder: (_, url) => defaultPlaceholder,
      errorWidget: (_, url, error) => errorPlaceholder ?? _defaultErrorWidget(width, height: height),
      cacheManager: isNetworkImage ? ImageCacheManager() : null,
      placeholderFadeInDuration: const Duration(milliseconds: 100),
      matchTextDirection: true,
    );
  }

  Widget _defaultErrorWidget(double? width, {double? height}) {
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
