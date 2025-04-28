import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tags.dart';

///
/// Created by a0010 on 2024/12/30 15:58
/// 单行占满的布局的通用组件
///

///
/// Created by a0010 on 2025/1/2 15:14
///

///
/// 单行文本布局
/// SingleTextView(
///   icon: Icons.language,
///   title: S.of(context).language,
///   isShowForward: true,
///   text: _convertLocale(locale),
///   isTextLeft: false,
/// )
class SingleTextView extends StatelessWidget {
  final IconData? icon; // 标题图标
  final Color? iconColor; // 标题图标颜色

  final Widget? image; // 标题图像
  final String? title; // 标题文本
  final Color? titleColor; // 标题文本颜色
  final double contentDistance; // 内容两边的间距

  final Widget? prefix; // 标题后内容前的布局
  final bool isDense; // 标题和内容是否存在间距

  final Widget? child; // 内容布局
  final String? text; // 内容文本
  final Color? textColor; // 内容文本颜色

  final String? summary; // 概要文本
  final Color? summaryColor; // 概要文本颜色

  final double fontSize; //字体大小
  final TextAlign textAlign; // 内容展示的起始位置

  final Widget? suffix; // 指向下一级按钮前的布局

  final bool isShowForward; // 是否显示指向下一级图标
  final int badgeCount; // 小红点数量
  final Color? forwardColor; // 指向下一级图标颜色

  const SingleTextView({
    super.key,
    this.icon,
    this.iconColor,
    this.image,
    this.title,
    this.titleColor,
    this.contentDistance = 0,
    this.prefix,
    this.isDense = false,
    this.text,
    this.child,
    this.textColor,
    this.summary,
    this.summaryColor,
    this.fontSize = 14,
    this.textAlign = TextAlign.left,
    this.suffix,
    this.isShowForward = false,
    this.badgeCount = -1,
    this.forwardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
          TitleView(
            icon: icon,
            iconColor: iconColor,
            image: image,
            title: title,
            titleColor: titleColor,
            contentDistance: contentDistance,
            prefix: prefix,
            isDense: isDense,
            text: text,
            textColor: textColor,
            fontSize: fontSize,
            textAlign: textAlign,
            child: child,
          ),
          if (summary != null) const SizedBox(height: 8),
          // 概要文本
          _buildSummaryText(),
        ]),
      ),
      if (text != null) SizedBox(width: 8 + contentDistance),
      // 后缀布局
      Offstage(offstage: suffix == null, child: suffix),
      if (suffix != null && isShowForward) const SizedBox(width: 8),
      // 小红点
      Offstage(offstage: badgeCount < 0, child: BadgeTag(count: badgeCount)),
      // 下一级图标
      _buildForwardIcon(),
    ]);
  }

  Widget _buildSummaryText() {
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

  Widget _buildForwardIcon() {
    return Offstage(
      offstage: !isShowForward,
      child: Icon(Icons.keyboard_arrow_right, color: forwardColor, size: 16),
    );
  }
}

///
/// TitleView(
///   title: '地区：',
///   text: '${user?.provinceCode ?? ''} ${user?.cityCode ?? ''}',
///   fontSize: 12,
///   isDense: true,
///   mainAxisSize: MainAxisSize.min,
/// )
class TitleView extends StatelessWidget {
  final IconData? icon; // 标题图标
  final Color? iconColor; // 标题图标颜色

  final Widget? image; // 标题图像
  final String? title; // 标题文本
  final Color? titleColor; // 标题文本颜色
  final double contentDistance; // 内容两边的间距

  final Widget? prefix; // 标题后内容前的布局
  final bool isDense; // 标题和内容是否存在间距

  final Widget? child; // 内容布局
  final String? text; // 内容文本
  final Color? textColor; // 内容文本颜色

  final double fontSize; //字体大小
  final TextAlign textAlign; // 内容展示的起始位置
  final MainAxisSize mainAxisSize;

  const TitleView({
    super.key,
    this.icon,
    this.iconColor,
    this.image,
    this.title,
    this.titleColor,
    this.contentDistance = 0,
    this.prefix,
    this.isDense = false,
    this.text,
    this.child,
    this.textColor,
    this.fontSize = 14,
    this.textAlign = TextAlign.left,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: mainAxisSize, children: [
      // 标题图标
      _buildTitleIcon(),
      if ((icon != null || image != null) && title != null) SizedBox(width: 8 + contentDistance),
      // 标题文本
      _buildTitleText(),
      if (prefix != null) const SizedBox(width: 8),
      // 前缀布局
      Offstage(offstage: prefix == null, child: prefix),
      if ((icon != null || title != null) && !isDense) const SizedBox(width: 16),
      // 文本内容(Expanded用于解决文本过长导致布局溢出的错误)
      mainAxisSize == MainAxisSize.max ? Expanded(child: _buildContentText()) : _buildContentText(),
    ]);
  }

  Widget _buildTitleIcon() {
    Widget? child = icon != null ? Icon(icon, color: iconColor, size: fontSize + 4) : image ?? const SizedBox.shrink();
    return Offstage(
      offstage: icon == null && image == null,
      child: child,
    );
  }

  Widget _buildTitleText() {
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

  Widget _buildContentText() {
    if (text == null) {
      return Row(children: [child ?? const SizedBox(width: 0)]);
    }
    return Text(
      text ?? '',
      textAlign: textAlign,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontSize,
        color: textColor,
      ),
    );
  }
}

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

  /// 文本编辑控制器
  late TextEditingController _controller;

  final GlobalKey _key = GlobalKey();
  final GlobalKey _targetKey = GlobalKey();
  double padding = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculatorTextFieldHeight());

    _controller = widget.controller ?? TextEditingController(text: widget.initialText ?? '');
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
            onTapOutside: (event) {
              _focusNode.unfocus();
            },
            onChanged: widget.onChanged,
            controller: widget.controller,
          ),
        ),
      ]),
    );
  }
}
