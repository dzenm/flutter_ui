import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui/base/base.dart';

///
/// Created by a0010 on 2023/11/10 09:50
/// 自定义输入框
class EditLayout extends StatefulWidget {
  final Widget? title;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry editPadding;
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
  final TextInputType keyboardType; // 文本输入类型
  final ValueChanged<String>? onChanged; // 输入监听器
  final String? initialText; // 标题文本
  final TextEditingController? controller; // 输入控制器
  final List<TextInputFormatter>? inputFormatters; // 输入文本的类型

  const EditLayout({
    super.key,
    this.title,
    this.padding,
    EdgeInsetsGeometry? editPadding,
    double? fontSize,
    this.textColor,
    this.hintText,
    this.hintStyle,
    Color? color,
    this.maxLength,
    this.maxLines,
    bool? enabled,
    Color? enabledBorderColor,
    Color? focusedBorderColor,
    double? borderRadius,
    double? borderWidth,
    TextInputType? keyboardType,
    this.onChanged,
    this.initialText,
    this.controller,
    this.inputFormatters,
  })  : editPadding = editPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        fontSize = fontSize ?? 14,
        color = color ?? Colors.transparent,
        enabled = enabled ?? true,
        enabledBorderColor = enabledBorderColor ?? Colors.grey,
        focusedBorderColor = focusedBorderColor ?? Colors.blue,
        borderRadius = borderRadius ?? 12,
        borderWidth = borderWidth ?? 1,
        keyboardType = keyboardType ?? TextInputType.text;

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

  final GlobalKey _key = GlobalKey();
  final GlobalKey _targetKey = GlobalKey();
  double padding = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculatorTextFieldHeight());

    _focusNode.addListener(() => setState(() => _hasFocus = _focusNode.hasFocus));
    _controller = widget.controller ?? TextEditingController(text: widget.initialText ?? '');
    _currentLength = _controller.text.length;
  }

  void _calculatorTextFieldHeight() {
    RenderBox? view = _key.currentContext?.findRenderObject() as RenderBox?;
    RenderBox? targetView = _targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (view == null || targetView == null) return;
    EdgeInsets edgeInsets = widget.editPadding as EdgeInsets;
    Size size = view.size;
    Size targetSize = targetView.size;
    // 总高度
    double height = targetSize.height;
    // 行数
    int lines = widget.maxLines ?? 1;
    // 上下间距
    double vertical = edgeInsets.top + edgeInsets.bottom;
    // item高度
    double itemHeight = (height - vertical) / lines;
    // 行高+间距-文本高度
    padding = itemHeight + edgeInsets.top - size.height;
    Log.d('文本高度：itemHeight=$itemHeight, top=${edgeInsets.top}, height=${size.height}, padding=$padding');
    setState(() {});
  }

  @override
  void dispose() {
    // 释放
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
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
              right: widget.editPadding.horizontal / 2,
              top: widget.editPadding.vertical / 2,
            ),
            child: Container(
              key: _key,
              child: widget.title!,
            ),
          ),

        Expanded(
          child: TextField(
            key: _targetKey,
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
              contentPadding: widget.editPadding,
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
