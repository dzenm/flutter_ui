import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 单行输入框布局
class SingleEditLayout extends StatefulWidget {
  final String? title; // 标题文本
  final String? hintText; // 提示文字
  final TextStyle? style; // 文本样式
  final double fontSize; // 字体大小
  final int? maxLength; // 设置最大字数长度
  final bool isShowMaxLength; // 是否显示最大长度
  final bool enabled; // 是否可用输入
  final TextInputType? keyboardType; // 文本输入类型
  final ValueChanged<String>? onChanged; // 输入监听器
  final TextEditingController? controller; // 输入控制器
  final List<TextInputFormatter>? inputFormatters; // 输入文本的类型
  final double horizontalPadding; // 左右的内边距

  const SingleEditLayout({
    super.key,
    this.title,
    this.onChanged,
    this.style,
    this.hintText,
    this.fontSize = 16,
    this.maxLength,
    this.isShowMaxLength = true,
    this.enabled = true,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.horizontalPadding = 16,
  });

  @override
  State<StatefulWidget> createState() => _SingleEditLayoutState();
}

class _SingleEditLayoutState extends State<SingleEditLayout> {
  int _currentLength = 0;

  // 判断和控制焦点的获取
  FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      _currentLength = widget.controller?.text.length ?? 0;
      setState(() => _hasFocus = _focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<TextInputFormatter> inputFormatters = [if (widget.maxLength != null) LengthLimitingTextInputFormatter(widget.maxLength)];
    widget.inputFormatters?.forEach((element) => inputFormatters.add(element));
    return Container(
      color: Colors.white,
      height: 50.0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: widget.horizontalPadding),
          // 标题文本
          if (widget.title != null)
            Text(
              widget.title!,
              style: widget.style ?? Theme.of(context).textTheme.subtitle1,
            ),
          if (widget.title != null) const SizedBox(width: 16),

          // 输入文本
          Expanded(
            child: textField(
              context,
              _focusNode,
              widget.fontSize,
              widget.hintText ?? '',
              (value) => _onChanged(value),
              style: widget.style,
              enabled: widget.enabled,
              keyboardType: widget.keyboardType,
              inputFormatters: inputFormatters.isNotEmpty ? inputFormatters : null,
              maxLength: widget.maxLength,
              controller: widget.controller,
            ),
          ),

          // 输入最大文本数量的提示
          Offstage(
            // 根据是否设置最大长度和是否获取焦点显示
            offstage: (widget.maxLength == null ? true : !_hasFocus),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Text(
                  '$_currentLength/${widget.maxLength}',
                  style: TextStyle(fontSize: widget.fontSize - 2, color: Colors.grey),
                ),
              ],
            ),
          ),

          SizedBox(width: widget.horizontalPadding),
        ],
      ),
    );
  }

  // 　输入改变时更新文本
  _onChanged(String value) {
    setState(() {
      if (widget.onChanged != null) {
        widget.onChanged!(value);
      }
      _currentLength = value.length;
    });
  }
}

// 输入框
textField(
  BuildContext context,
  FocusNode focusNode,
  double fontSize,
  String hintText,
  ValueChanged<String> onChanged, {
  bool? enabled,
  TextStyle? style,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
  int? maxLength,
  TextEditingController? controller,
}) {
  return TextField(
    enabled: enabled,
    focusNode: focusNode,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    style: style ?? Theme.of(context).textTheme.subtitle1,
    decoration: InputDecoration(
      // isCollapsed 去除默认的最小高度，然后添加一个top padding就能使输入文字居中显示
      contentPadding: const EdgeInsets.only(top: 8),
      isCollapsed: true,
      border: const OutlineInputBorder(borderSide: BorderSide.none),
      hintText: hintText,
      counter: const SizedBox(),
      isDense: true,
    ),
    maxLines: 1,
    maxLength: maxLength,
    maxLengthEnforcement: MaxLengthEnforcement.enforced,
    onChanged: onChanged,
    controller: controller,
  );
}

// 创建一个带初始文本的 TextEditingController
textEditingController({String text = ''}) {
  TextEditingController.fromValue(
    TextEditingValue(
      text: text,
      selection: TextSelection.fromPosition(TextPosition(offset: text.length, affinity: TextAffinity.downstream)),
    ),
  );
}
