import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/widgets/tap_layout.dart';

/// 单行输入框布局
class SingleEditLayout extends StatefulWidget {
  final String title; // 标题文本
  final Color? titleColor; // 标题文本颜色
  final Color? textColor; // 文本颜色
  final String? hintText; // 提示文字
  final double fontSize; // 字体大小
  final int? maxLength; // 设置最大字数长度
  final bool isShowMaxLength; // 是否显示最大长度
  final bool enabled; // 是否可用输入
  final ValueChanged<String>? onChanged; // 输入监听器
  final TextEditingController? controller; // 输入控制器
  final List<TextInputFormatter>? inputFormatters; // 输入文本的类型
  final double horizontalPadding; // 左右的内边距

  SingleEditLayout(
    this.title,
    this.onChanged, {
    Key? key,
    this.titleColor,
    this.textColor,
    this.hintText,
    this.fontSize = 16,
    this.maxLength,
    this.isShowMaxLength = true,
    this.enabled = true,
    this.controller,
    this.inputFormatters,
    this.horizontalPadding = 16,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SingleEditLayout();
}

class _SingleEditLayout extends State<SingleEditLayout> {
  var currentLength;

  // 判断和控制焦点的获取
  var focusNode = FocusNode();
  var hasFocus = false;

  @override
  void initState() {
    super.initState();
    currentLength = widget.controller?.text.length ?? '0';
    focusNode.addListener(() {
      setState(() {
        hasFocus = focusNode.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: widget.horizontalPadding),
          // 标题文本
          Text(widget.title, style: TextStyle(fontSize: widget.fontSize, color: widget.titleColor)),
          SizedBox(width: 16),

          // 输入文本
          Expanded(
            child: textField(focusNode, widget.fontSize, widget.hintText ?? '', (value) => _onChanged(value),
                enabled: widget.enabled,
                textColor: widget.textColor,
                inputFormatters: widget.inputFormatters,
                maxLength: widget.maxLength,
                controller: widget.controller),
          ),

          // 输入最大文本数量的提示
          Offstage(
            // 根据是否设置最大长度和是否获取焦点显示
            offstage: (widget.maxLength == null ? true : !hasFocus),
            child: Row(
              children: [
                SizedBox(width: 12),
                Text(
                  '$currentLength/${widget.maxLength}',
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
      currentLength = value.length;
    });
  }
}

// 多级文本选择
class SingleTextSelectionLayout extends StatefulWidget {
  final String title;
  final String text;
  final String hintText;
  final VoidCallback? onTap;
  final Widget? child;

  SingleTextSelectionLayout(
    this.title,
    this.text,
    this.hintText, {
    this.onTap,
    this.child,
  });

  @override
  State<StatefulWidget> createState() => _SingleTextSelectionLayout();
}

class _SingleTextSelectionLayout extends State<SingleTextSelectionLayout> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(width: 16),
          // 标题文本
          Text(widget.title, style: TextStyle(fontSize: 16)),
          SizedBox(width: 8),

          // 显示的内容文本
          Flexible(
            child: TapLayout(
              height: 40,
              child: Text(
                widget.text.length == 0 ? widget.hintText : widget.text,
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              onTap: widget.onTap,
            ),
          ),
          Offstage(offstage: widget.child == null, child: Row(children: [SizedBox(width: 8), if (widget.child != null) widget.child!])),
          SizedBox(width: 16),
        ],
      ),
    );
  }
}

// 输入框
textField(
  FocusNode focusNode,
  double fontSize,
  String hintText,
  ValueChanged<String> onChanged, {
  bool? enabled,
  Color? textColor,
  List<TextInputFormatter>? inputFormatters,
  int? maxLength,
  TextEditingController? controller,
}) {
  return TextField(
    enabled: enabled,
    focusNode: focusNode,
    keyboardType: TextInputType.text,
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

// 创建一个带初始文本的 TextEditingController
textEditingController({String text = ''}) {
  TextEditingController.fromValue(
    TextEditingValue(
      text: text,
      selection: TextSelection.fromPosition(TextPosition(offset: text.length, affinity: TextAffinity.downstream)),
    ),
  );
}
