import 'package:flutter/material.dart';

class CommonWidget {
  /// 分割线
  static Widget divider({
    bool isVertical = false,
    double height = 0.1,
    double left = 0,
    double right = 0,
    double width = 0,
    Color? color,
  }) {
    return Container(
      color: color ?? const Color(0xFFEFEFEF),
      child: isVertical
          ? const SizedBox()
          : Divider(
              height: height,
              indent: left,
              endIndent: right,
              color: Colors.transparent,
            ),
    );
  }

  static Widget? leadingView({bool isLight = true}) {
    return BackButton(color: brightnessTheme(isLight: isLight));
  }

  static Color brightnessTheme({bool isLight = true}) => //
      isLight ? Colors.white : Colors.black87;

  /// 标题
  static Widget titleView(
    String title, {
    double left = 8,
    double top = 8,
    double right = 8,
    double bottom = 8,
  }) {
    return Container(
      padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom),
      child: Row(children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ]),
    );
  }

  /// 内容
  static Widget multipleTextView(String msg) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(children: [
        Expanded(child: Text(msg)),
      ]),
    );
  }

  /// highlight搜索字段
  static List<TextSpan> getHighlightTextSpans(
    String keyword,
    String searchText, {
    TextStyle? style,
  }) {
    List<TextSpan> spans = [];
    if (keyword.isEmpty) return spans;
    // 搜索关键字高亮忽略大小写
    String wordL = keyword.toLowerCase(), keywordL = searchText.toLowerCase();
    List<String> arr = wordL.split(keywordL);
    TextStyle normalStyle = style ?? const TextStyle(color: Colors.grey, fontSize: 12);
    TextStyle keywordStyle = normalStyle.copyWith(color: Colors.blue);
    int preIndex = 0;
    for (int i = 0; i < arr.length; i++) {
      if (i != 0) {
        // 搜索关键字高亮忽略大小写
        preIndex = wordL.indexOf(keywordL, preIndex);
        spans.add(
          TextSpan(
            text: keyword.substring(preIndex, preIndex + searchText.length),
            style: keywordStyle,
          ),
        );
      }
      String val = arr[i];
      if (val.isNotEmpty) {
        preIndex = wordL.indexOf(val, preIndex);
        spans.add(
          TextSpan(
            text: keyword.substring(preIndex, preIndex + val.length),
            style: normalStyle,
          ),
        );
      }
    }
    return spans;
  }

  /// 默认的阴影
  static List<BoxShadow> defaultShadows() {
    return [
      const BoxShadow(
        offset: Offset(0, 1),
        blurRadius: 10.0,
        spreadRadius: 0.0,
        color: Color(0x0D000000),
      ),
      const BoxShadow(
        offset: Offset(0, 1),
        blurRadius: 4.0,
        spreadRadius: 0.0,
        color: Color(0x14000000),
      ),
    ];
  }
}
