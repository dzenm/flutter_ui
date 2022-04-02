import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'badge_view.dart';

/// 单行文本布局
class SingleTextLayout extends StatefulWidget {
  final IconData? icon; // 标题图标
  final Color? iconColor; // 标题图标颜色

  final Widget? image; // 标题图像
  final String? title; // 标题文本
  final Color? titleColor; // 标题文本颜色

  final Widget? prefix; // 标题后内容前的布局
  final bool isDense; // 标题和内容是否存在间距

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
    this.prefix,
    this.isDense = false,
    this.text,
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
  State<StatefulWidget> createState() => _SingleTextLayoutState();
}

class _SingleTextLayoutState extends State<SingleTextLayout> {
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
              if ((widget.icon != null || widget.image != null) && widget.title != null) SizedBox(width: 8),
              // 标题文本
              _titleText(),
              if (widget.prefix != null) SizedBox(width: 8),
              // 前缀布局
              Offstage(offstage: widget.prefix == null, child: widget.prefix),
              if ((widget.icon != null || widget.title != null) && !widget.isDense) SizedBox(width: 16),
              // 文本内容
              _contentText(),
              if (widget.text != null) SizedBox(width: 8),
            ]),
            if (widget.summary != null) SizedBox(height: 8),
            // 概要文本
            _summaryText(),
          ],
        ),
      ),
      // 后缀布局
      Offstage(offstage: widget.suffix == null, child: widget.suffix),
      if (widget.suffix != null && widget.isShowForward) SizedBox(width: 8),
      // 小红点
      Offstage(offstage: widget.badgeCount < 0, child: BadgeView(count: widget.badgeCount)),
      // 下一级图标
      _forwardIcon(),
    ]);
  }

  Widget _titleIcon() {
    Widget? child = widget.icon != null ? Icon(widget.icon, color: widget.iconColor, size: widget.fontSize + 4) : widget.image ?? Container();
    return Offstage(
      offstage: widget.icon == null && widget.image == null,
      child: child,
    );
  }

  Widget _titleText() {
    return Offstage(
      offstage: widget.title == null,
      child: Text(
        widget.title ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: widget.fontSize,
          color: widget.titleColor,
        ),
      ),
    );
  }

  Widget _contentText() {
    // Expanded用于解决文本过长导致布局溢出的错误
    return widget.text == null
        ? Expanded(child: SizedBox(width: 0))
        : Expanded(
            flex: 1,
            child: Text(
              widget.text ?? '',
              textAlign: widget.isTextLeft ? TextAlign.left : TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: widget.fontSize,
                color: widget.textColor,
              ),
            ),
          );
  }

  Widget _summaryText() {
    return Offstage(
      offstage: widget.summary == null,
      child: Text(
        widget.summary ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: widget.fontSize - 2,
          color: widget.summaryColor,
        ),
      ),
    );
  }

  Widget _forwardIcon() {
    return Offstage(
      offstage: !widget.isShowForward,
      child: Icon(Icons.keyboard_arrow_right, color: widget.forwardColor, size: 16),
    );
  }
}
