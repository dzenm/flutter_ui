import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 单行输入框布局
class SingleEditLayout extends StatefulWidget {
  final String? title; // 标题文本
  final Color? titleColor; // 标题文本颜色
  final Color? textColor; // 文本颜色
  final String? hintText; // 提示文字
  final double fontSize; // 字体大小
  final int? maxLength; // 设置最大字数长度
  final bool enabled; // 是否可用输入
  final TextInputType? keyboardType; // 文本输入类型
  final ValueChanged<String>? onChanged; // 输入监听器
  final TextEditingController? controller; // 输入控制器
  final List<TextInputFormatter>? inputFormatters; // 输入文本的类型
  final double horizontalPadding; // 左右的内边距

  SingleEditLayout({
    Key? key,
    this.title,
    this.onChanged,
    this.titleColor,
    this.textColor,
    this.hintText,
    this.fontSize = 16,
    this.maxLength = 0,
    this.enabled = true,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.horizontalPadding = 16,
  }) : super(key: key);

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
        contentPadding: EdgeInsets.only(top: 8),
        isCollapsed: true,
        border: OutlineInputBorder(borderSide: BorderSide.none),
        hintText: hintText,
        counter: SizedBox(),
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
  State<StatefulWidget> createState() => _SingleEditLayoutState();
}

class _SingleEditLayoutState extends State<SingleEditLayout> {
  var currentLength;

  // 判断和控制焦点的获取
  var focusNode = FocusNode();
  var hasFocus = false;

  @override
  void initState() {
    super.initState();
    currentLength = widget.controller?.text.length ?? 0;
    focusNode.addListener(() => setState(() => hasFocus = focusNode.hasFocus));
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
        if (widget.title != null) SizedBox(width: 16),

        // 输入文本
        Expanded(
          child: SingleEditLayout.textField(
            focusNode,
            widget.fontSize,
            widget.hintText ?? '',
            (value) => _onChanged(value),
            enabled: widget.enabled,
            textColor: widget.textColor,
            keyboardType: widget.keyboardType,
            inputFormatters: inputFormatters.isNotEmpty ? inputFormatters : null,
            maxLength: widget.maxLength,
            controller: widget.controller,
          ),
        ),

        // 输入最大文本数量的提示
        Offstage(
          // 根据是否设置最大长度和是否获取焦点显示
          offstage: (widget.maxLength == null ? true : !hasFocus),
          child: Row(children: [
            SizedBox(width: 12),
            Text(
              '$currentLength/${widget.maxLength}',
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
      currentLength = value.length;
    });
  }
}
