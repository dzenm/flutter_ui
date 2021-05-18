import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// 单行文本布局
class SingleTextLayout extends StatefulWidget {
  final IconData? icon; // 标题图标
  final Color? iconColor; // 标题图标颜色

  final String? title; // 标题文本
  final Color? titleColor; // 标题文本颜色

  final String? text; // 内容文本
  final Color? textColor; // 内容文本颜色

  final double fontSize; //字体大小
  final bool isTextLeft; // 内容是否靠左边显示

  final Widget? suffix; // 指向下一级按钮前的布局

  final bool isForward; // 是否显示指向下一级图标
  final Color? forwardColor; // 指向下一级图标颜色

  SingleTextLayout({
    Key? key,
    this.icon,
    this.iconColor,
    this.title,
    this.titleColor,
    this.text,
    this.textColor,
    this.fontSize = 14,
    this.isTextLeft = true,
    this.suffix,
    this.isForward = false,
    this.forwardColor,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SingleTextLayoutState();
}

class _SingleTextLayoutState extends State<SingleTextLayout> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 标题图标
        _titleIcon(),
        if (widget.icon != null) SizedBox(width: 8),
        // 标题文本
        _titleText(),
        if (widget.title != null) SizedBox(width: 8),
        // 文本内容
        _contentText(),
        if (widget.text != null) SizedBox(width: 8),
        // 后缀布局
        _suffixWidget(),
        if (widget.suffix != null && widget.isForward) SizedBox(width: 8),
        // 下一级图标
        _forwardIcon(),
      ],
    );
  }

  Widget _titleIcon() {
    return Offstage(
      offstage: widget.icon == null,
      child: Icon(widget.icon, color: widget.iconColor, size: widget.fontSize + 4),
    );
  }

  Widget _titleText() {
    return Offstage(
      offstage: widget.title == null,
      child: Text(
        widget.title!,
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

  Widget _suffixWidget() {
    bool isShowSuffix = widget.suffix != null;
    return Offstage(
      offstage: !isShowSuffix,
      child: widget.suffix,
    );
  }

  Widget _forwardIcon() {
    return Offstage(
      offstage: !widget.isForward,
      child: Icon(Icons.arrow_forward_ios_rounded, color: widget.forwardColor, size: 12),
    );
  }
}
