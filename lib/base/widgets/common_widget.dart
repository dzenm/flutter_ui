import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// 分割线
Widget divider({
  bool isVertical = false,
  double height = 0.1,
  double left = 0,
  double right = 0,
  double width = 0,
  Color? color,
}) {
  return Container(
    color: color ?? Color(0xFFEFEFEF),
    child: isVertical
        ? SizedBox()
        : Divider(
            height: height,
            indent: left,
            endIndent: right,
            color: Colors.transparent,
          ),
  );
}

Widget? leadingView({bool isLight = true}) {
  return BackButton(color: brightnessTheme(isLight: isLight));
}

Color brightnessTheme({bool isLight = true}) => isLight ? Colors.white : Colors.black87;

// 标题
Widget titleView(String title, {double left = 8, double top = 8, double right = 8, double bottom = 8}) {
  return Container(
    padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom),
    child: Row(children: [Expanded(child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))]),
  );
}

// 内容
Widget multipleTextView(String msg) {
  return Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.all(Radius.circular(8))),
    child: Row(
      children: [Expanded(child: Text(msg))],
    ),
  );
}

networkImage(
  String? url, {
  int? version,
  Widget? placeholder,
  BoxFit? fit,
  double? width,
  double? height,
}) {
  String currentUrl = '';
  if (url != null && url.length > 0) {
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

imagePlaceholder({required double width, double? height}) {
  return Container(
    width: width,
    height: height ?? width,
    color: Color(0xffafafaf),
    alignment: Alignment.center,
    child: Icon(
      Icons.ac_unit_outlined,
      size: width * 0.5,
      color: Colors.white,
    ),
  );
}

class FileImageExt extends FileImage {
  late int fileSize;

  FileImageExt(File file, {double scale = 1.0}) : super(file, scale: scale) {
    fileSize = file.existsSync() ? file.lengthSync() : 0; //l 文件不存在兼容
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final FileImageExt typedOther = other;
    return file.path == typedOther.file.path && scale == typedOther.scale && fileSize == typedOther.fileSize;
  }

  @override
  int get hashCode => super.hashCode;
}
