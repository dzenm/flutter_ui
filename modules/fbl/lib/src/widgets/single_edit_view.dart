import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///
/// 单行输入框布局
/// SingleEditView(
///   title: '账户',
///   onChanged: (value) => setState(() => newText = value),
///   controller: _controller,
///   maxLength: 12,
///   fontSize: 14,
///   horizontalPadding: 0,
///   keyboardType: CustomKeywordBoard.license,
/// ),
///
class SingleEditView extends StatefulWidget {
  final String? title; // 标题文本
  final Color? titleColor; // 标题文本颜色
  final String? initialText; // 标题文本
  final Color? color; // 文本颜色
  final String? hintText; // 提示文字
  final double fontSize; // 字体大小
  final int? maxLength; // 设置最大字数长度
  final bool enabled; // 是否可用输入
  final TextInputType? keyboardType; // 文本输入类型
  final ValueChanged<String>? onChanged; // 输入监听器
  final TextEditingController? controller; // 输入控制器
  final List<TextInputFormatter>? inputFormatters; // 输入文本的类型
  final double horizontalPadding; // 左右的内边距

  const SingleEditView({
    super.key,
    this.title,
    this.onChanged,
    this.initialText,
    this.titleColor,
    this.color,
    this.hintText,
    this.fontSize = 16,
    this.maxLength,
    this.enabled = true,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.horizontalPadding = 16,
  });

  // 输入框
  static Widget textField(
    FocusNode focusNode,
    double fontSize,
    String hintText,
    ValueChanged<String> onChanged, {
    bool? enabled,
    Color? textColor,
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
      style: TextStyle(
        fontSize: fontSize,
        textBaseline: TextBaseline.alphabetic,
        color: textColor,
      ),
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

  /// 创建一个带初始文本的 TextEditingController
  static TextEditingController textEditingController({String text = ''}) {
    return TextEditingController.fromValue(
      TextEditingValue(
        text: text,
        selection: TextSelection.fromPosition(
          TextPosition(
            offset: text.length,
            affinity: TextAffinity.downstream,
          ),
        ),
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _SingleEditViewState();
}

class _SingleEditViewState extends State<SingleEditView> {
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
    List<TextInputFormatter> inputFormatters = [if (widget.maxLength != null) LengthLimitingTextInputFormatter(widget.maxLength)];
    widget.inputFormatters?.forEach((element) => inputFormatters.add(element));
    return Container(
      height: 50.0,
      padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        // 标题文本
        if (widget.title != null)
          Text(
            widget.title ?? '',
            style: TextStyle(fontSize: widget.fontSize, color: widget.titleColor),
          ),
        if (widget.title != null) const SizedBox(width: 16),

        // 输入文本
        Expanded(
          child: SingleEditView.textField(
            _focusNode,
            widget.fontSize,
            widget.hintText ?? '',
            (value) => _onChanged(value),
            enabled: widget.enabled,
            textColor: widget.color,
            keyboardType: widget.keyboardType,
            inputFormatters: inputFormatters.isNotEmpty ? inputFormatters : null,
            maxLength: widget.maxLength,
            controller: _controller,
          ),
        ),

        // 输入最大文本数量的提示
        Offstage(
          // 根据是否设置最大长度和是否获取焦点显示
          offstage: (widget.maxLength == null ? true : !_hasFocus),
          child: Row(children: [
            const SizedBox(width: 12),
            Text(
              '$_currentLength/${widget.maxLength}',
              style: TextStyle(fontSize: widget.fontSize - 2, color: Colors.grey),
            ),
          ]),
        ),
      ]),
    );
  }

  // 　输入改变时更新文本
  void _onChanged(String value) {
    setState(() {
      if (widget.onChanged != null) {
        widget.onChanged!(value);
      }
      _currentLength = value.length;
    });
  }
}
