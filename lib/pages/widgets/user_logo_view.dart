import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:fbl/fbl.dart';

const kRatio = 1.125;

class UserLogoView extends StatelessWidget {
  final String? url;
  final double width;
  final double? height;
  final Color? color;
  final Widget? defaultIcon;
  final Widget? placeHolder;
  final BoxFit fit;
  final bool isRadius;
  final bool canClick;
  final bool isCircle;

  const UserLogoView({
    super.key,
    required this.url,
    this.width = 50,
    this.height,
    this.color,
    this.defaultIcon,
    this.placeHolder,
    this.fit = BoxFit.fill,
    this.isRadius = true,
    this.canClick = false,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    double h;
    if (isCircle) {
      h = width;
    } else {
      h = height ?? width * kRatio;
    }
    final borderRadius = isRadius ? const BorderRadius.all(Radius.circular(4)) : null;
    Widget defaultHolder = placeHolder ?? _buildDefaultPlaceHolder(h, borderRadius);
    Widget image = ImageView(
      url: url ?? '',
      width: width,
      height: h,
      fit: fit,
      placeholder: defaultHolder,
      errorPlaceholder: Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(color: Color(0xffafafaf), borderRadius: null),
        alignment: Alignment.center,
        clipBehavior: Clip.hardEdge,
        child: Icon(
          CustomIcons.tag,
          size: width * 0.5,
          color: Colors.white,
        ),
      ),
    );

    Widget child = Container(
      decoration: BoxDecoration(borderRadius: borderRadius),
      clipBehavior: Clip.antiAlias,
      child: image, //l 抗锯齿
    );
    if (canClick) {
      return TapLayout(
        foreground: Colors.transparent,
        onTap: () {
          String path = '?pathList=${Uri.encodeComponent(jsonEncode([url]))}';
          // NavigatorUtils.push(context, ConversationRouter.viewMediaPage + path);
        },
        child: child,
      );
    }
    if (isCircle) {
      child = ClipOval(child: child);
    }
    return child;
  }

  Widget _buildDefaultPlaceHolder(double height, BorderRadiusGeometry? borderRadius) {
    bool isEmptyUrl = (url ?? '').isEmpty;
    final size = isCircle ? width * 0.45 : width * 0.5;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isEmptyUrl
            ? (defaultIcon == null ? const Color(0xffafafaf) : (color ?? const Color(0xffafafaf))) //l 有默认图标，默认为蓝色背景
            : Colors.white,
        borderRadius: borderRadius,
      ),
      alignment: Alignment.center,
      clipBehavior: Clip.hardEdge,
      child: isEmptyUrl ? (defaultIcon ?? Icon(CustomIcons.tag, size: size, color: Colors.white)) : null,
    );
  }
}
