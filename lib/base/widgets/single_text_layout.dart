import 'package:flutter/material.dart';

import 'badge_tag.dart';

/// 单行文本布局
class SingleTextLayout extends StatelessWidget {
  final IconData? icon; // 标题图标
  final Color? iconColor; // 标题图标颜色

  final Widget? image; // 标题图像
  final String? title; // 标题文本
  final Color? titleColor; // 标题文本颜色
  final double padding; // 内容两边的间距

  final Widget? prefix; // 标题后内容前的布局
  final bool isDense; // 标题和内容是否存在间距

  final Widget? content; // 内容布局
  final String? text; // 内容文本
  final Color? textColor; // 内容文本颜色

  final String? summary; // 概要文本
  final Color? summaryColor; // 概要文本颜色

  final double fontSize; //字体大小
  final bool isTextLeft; // 内容是否靠左边显示

  final Widget? suffix; // 指向下一级按钮前的布局

  final bool isShowForward; // 是否显示指向下一级图标
  final int badgeCount; // 小红点数量
  final Color? forwardColor; // 指向下一级图标颜色

  SingleTextLayout({
    Key? key,
    this.icon,
    this.iconColor,
    this.image,
    this.title,
    this.titleColor,
    this.padding = 0,
    this.prefix,
    this.isDense = false,
    this.text,
    this.content,
    this.textColor,
    this.summary,
    this.summaryColor,
    this.fontSize = 14,
    this.isTextLeft = true,
    this.suffix,
    this.isShowForward = false,
    this.badgeCount = -1,
    this.forwardColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              // 标题图标
              _titleIcon(),
              if ((icon != null || image != null) && title != null) SizedBox(width: 8 + padding),
              // 标题文本
              _titleText(),
              if (prefix != null) SizedBox(width: 8),
              // 前缀布局
              Offstage(offstage: prefix == null, child: prefix),
              if ((icon != null || title != null) && !isDense) SizedBox(width: 16),
              // 文本内容
              _contentText(),
              if (text != null) SizedBox(width: 8 + padding),
            ]),
            if (summary != null) SizedBox(height: 8),
            // 概要文本
            _summaryText(),
          ],
        ),
      ),
      // 后缀布局
      Offstage(offstage: suffix == null, child: suffix),
      if (suffix != null && isShowForward) SizedBox(width: 8),
      // 小红点
      Offstage(offstage: badgeCount < 0, child: BadgeTag(count: badgeCount)),
      // 下一级图标
      _forwardIcon(),
    ]);
  }

  Widget _titleIcon() {
    Widget? child = icon != null ? Icon(icon, color: iconColor, size: fontSize + 4) : image ?? Container();
    return Offstage(
      offstage: icon == null && image == null,
      child: child,
    );
  }

  Widget _titleText() {
    return Offstage(
      offstage: title == null,
      child: Text(
        title ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: fontSize,
          color: titleColor,
        ),
      ),
    );
  }

  Widget _contentText() {
    // Expanded用于解决文本过长导致布局溢出的错误
    return text == null
        ? Expanded(
            child: Row(children: [content ?? SizedBox(width: 0)]),
          )
        : Expanded(
            flex: 1,
            child: Text(
              text ?? '',
              textAlign: isTextLeft ? TextAlign.left : TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                color: textColor,
              ),
            ),
          );
  }

  Widget _summaryText() {
    return Offstage(
      offstage: summary == null,
      child: Text(
        summary ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: fontSize - 2,
          color: summaryColor,
        ),
      ),
    );
  }

  Widget _forwardIcon() {
    return Offstage(
      offstage: !isShowForward,
      child: Icon(Icons.keyboard_arrow_right, color: forwardColor, size: 16),
    );
  }
}
