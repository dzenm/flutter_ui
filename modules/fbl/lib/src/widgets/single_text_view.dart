import 'package:flutter/material.dart';

import 'badge_tag.dart';

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