import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///
/// Created by a0010 on 2023/11/10 09:50
/// 自定义输入框
class EditLayout extends StatefulWidget {
  final Widget? title;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? editPadding;
  final double fontSize; // 字体大小
  final Color? textColor; // 文本颜色
  final String? hintText; // 提示文字
  final TextStyle? hintStyle; // 提示文字样式
  final Color color; // 背景颜色
  final int? maxLength; // 设置最大字数长度
  final int? maxLines; // 设置最大行数
  final bool enabled; // 是否可用输入
  final Color enabledBorderColor; // 未获取焦点的边框颜色
  final Color focusedBorderColor; // 获取焦点的边框颜色
  final double borderRadius; // 边框圆角
  final double borderWidth; // 边框宽度
  final TextInputType? keyboardType; // 文本输入类型
  final ValueChanged<String>? onChanged; // 输入监听器
  final String? initialText; // 标题文本
  final TextEditingController? controller; // 输入控制器
  final List<TextInputFormatter>? inputFormatters; // 输入文本的类型

  const EditLayout({
    super.key,
    this.title,
    this.padding,
    this.editPadding,
    this.fontSize = 14,
    this.textColor,
    this.hintText,
    this.hintStyle,
    this.color = Colors.transparent,
    this.maxLength,
    this.maxLines,
    this.enabled = true,
    this.enabledBorderColor = Colors.grey,
    this.focusedBorderColor = Colors.blue,
    this.borderRadius = 12,
    this.borderWidth = 1,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.initialText,
    this.controller,
    this.inputFormatters,
  });

  @override
  State<EditLayout> createState() => _EditLayoutState();
}

class _EditLayoutState extends State<EditLayout> {
  /// 判断和控制焦点的获取
  final FocusNode _focusNode = FocusNode();

  /// 是否获取焦点
  bool _hasFocus = false;

  /// 当前文本的长度
  int _currentLength = 0;

  /// 文本编辑控制器
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() => _hasFocus = _focusNode.hasFocus));
    _controller = widget.controller ?? TextEditingController(text: widget.initialText ?? '');
    _currentLength = _controller.text.length;
  }

  @override
  void dispose() {
    super.dispose();
    // 释放
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // 标题文本
        if (widget.title != null)
          Padding(
            padding: EdgeInsets.only(
              right: widget.editPadding?.horizontal ?? 16,
              top: widget.editPadding?.vertical ?? 12,
            ),
            child: widget.title!,
          ),
        Expanded(
          child: TextField(
            enabled: widget.enabled,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            style: TextStyle(
              fontSize: widget.fontSize,
              textBaseline: TextBaseline.alphabetic,
              color: widget.textColor,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: widget.color,
              // isCollapsed 去除默认的最小高度，然后添加一个top padding就能使输入文字居中显示
              contentPadding: widget.editPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              // 未获取焦点的边框
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: widget.enabledBorderColor, width: widget.borderWidth),
                borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
              ),
              // 获取焦点的边框
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: widget.focusedBorderColor, width: widget.borderWidth),
                borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
              ),
              hintText: widget.hintText,
              hintStyle: widget.hintStyle,
              counter: const SizedBox(),
              isDense: true,
            ),
            cursorColor: widget.focusedBorderColor,
            cursorWidth: widget.borderWidth,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            onChanged: widget.onChanged,
            controller: widget.controller,
          ),
        ),
      ]),
    );
  }
}
