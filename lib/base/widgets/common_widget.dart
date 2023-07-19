import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CommonWidget {
  /// 分割线
  static Widget divider({
    bool isVertical = false,
    double height = 0.1,
    double left = 0,
    double right = 0,
    double width = 0,
    Color? color,
  }) {
    return Container(
      color: color ?? const Color(0xFFEFEFEF),
      child: isVertical
          ? const SizedBox()
          : Divider(
              height: height,
              indent: left,
              endIndent: right,
              color: Colors.transparent,
            ),
    );
  }

  static Widget? leadingView({bool isLight = true}) {
    return BackButton(color: brightnessTheme(isLight: isLight));
  }

  static Color brightnessTheme({bool isLight = true}) => isLight ? Colors.white : Colors.black87;

  /// 标题
  static Widget titleView(String title, {double left = 8, double top = 8, double right = 8, double bottom = 8}) {
    return Container(
      padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom),
      child: Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))]),
    );
  }

  /// 内容
  static Widget multipleTextView(String msg) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Row(
        children: [Expanded(child: Text(msg))],
      ),
    );
  }

  static CachedNetworkImage networkImage(
    String? url, {
    int? version,
    Widget? placeholder,
    BoxFit? fit,
    double? width,
    double? height,
  }) {
    String currentUrl = '';
    if (url != null && url.isNotEmpty) {
      currentUrl = '$url?${version ?? 0}';
    }
    return CachedNetworkImage(
      imageUrl: currentUrl,
      fit: fit,
      width: width,
      height: height,
      placeholder: placeholder != null
          ? (_, url) {
              return placeholder;
            }
          : null,
      errorWidget: placeholder != null
          ? (_, url, error) {
              return placeholder;
            }
          : null,
    );
  }

  static imagePlaceholder({required double width, double? height}) {
    return Container(
      width: width,
      height: height ?? width,
      color: const Color(0xffafafaf),
      alignment: Alignment.center,
      child: Icon(
        Icons.ac_unit_outlined,
        size: width * 0.5,
        color: Colors.white,
      ),
    );
  }
}

class FileImageExt extends FileImage {
  const FileImageExt(File file, {double scale = 1.0}) : super(file, scale: scale);

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final FileImageExt typedOther = other;
    int fileSize = file.existsSync() ? file.lengthSync() : 0; //l 文件不存在兼容
    return file.path == typedOther.file.path && scale == typedOther.scale && fileSize == typedOther.fileSize();
  }

  /// 文件不存在兼容
  int fileSize() {
    return file.existsSync() ? file.lengthSync() : 0;
  }

  @override
  int get hashCode => super.hashCode;
}
