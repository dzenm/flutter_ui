import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// 单行文本布局
class SingleTextLayout extends StatefulWidget {
  final String? title; // 标题文本
  final Color? titleColor; // 标题文本颜色

  final IconData? icon; // 标题图标
  final Color? iconColor; // 标题图标颜色

  final String? text; // 内容文本
  final Color? textColor; // 内容文本颜色
  final double fontSize; //字体大小
  final bool isLeft; // 内容是否靠左边显示

  final EdgeInsetsGeometry? padding; // 内边距

  final Widget? suffix; // 指向下一级按钮前的布局

  final bool isForward; // 是否显示指向下一级图标
  final Color? forwardColor; // 指向下一级图标颜色

  SingleTextLayout({
    Key? key,
    this.title,
    this.titleColor,
    this.icon,
    this.iconColor,
    this.text,
    this.textColor,
    this.fontSize = 12,
    this.isLeft = true,
    this.padding,
    this.suffix,
    this.isForward = false,
    this.forwardColor,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SingleTextLayout();
}

class _SingleTextLayout extends State<SingleTextLayout> {
  @override
  Widget build(BuildContext context) {
    bool isShowSuffix = widget.suffix != null;
    return Container(
      padding: widget.padding,
      child: Row(
        children: [
          // 标题图标
          Offstage(
            offstage: widget.icon == null,
            child: Icon(
              widget.icon,
              color: widget.iconColor,
            ),
          ),

          // 标题文本
          Offstage(
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
          ),

          // 文本内容, Expanded用于解决文本过长导致布局溢出的错误
          Expanded(
            child: Text(
              widget.text ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: widget.fontSize,
                color: widget.textColor,
              ),
            ),
          ),

          // 下一级图标前的布局
          Offstage(
            offstage: isShowSuffix,
            child: Row(
              children: [
                SizedBox(width: 8),
                if (isShowSuffix) widget.suffix!,
                SizedBox(width: 8),
              ],
            ),
          ),

          // 下一级图标
          Offstage(
            offstage: !widget.isForward,
            child: Row(
              children: [
                SizedBox(width: 16),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: widget.forwardColor,
                  size: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
