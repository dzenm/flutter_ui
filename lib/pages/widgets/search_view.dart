import 'package:flutter/material.dart';

import '../../base/base.dart';

/// 搜索布局
class SearchView extends StatelessWidget {
  final bool? isEdit;
  final Color focusedColor;
  final ValueChanged<String>? onChanged;

  const SearchView({
    super.key,
    this.isEdit,
    this.focusedColor = Colors.grey,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _buildSearchView(context);
  }

  /// 搜索群的布局
  Widget _buildSearchView(BuildContext context) {
    return Container(
      height: 40,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        Expanded(
          child: Container(
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            child: _buildEditSearchView(context),
          ),
        ),
        if (isEdit != null) const SizedBox(width: 8),
        if (isEdit != null) _buildCancelTap(context),
      ]),
    );
  }

  Widget _buildEditSearchView(BuildContext context) {
    bool isFocus = isEdit ?? false;
    return TextField(
      canRequestFocus: isFocus,
      onChanged: onChanged,
      autofocus: isFocus,
      cursorWidth: 0.5,
      cursorColor: focusedColor,
      textInputAction: TextInputAction.search,
      textAlignVertical: TextAlignVertical.center,
      onTap: () {
        if (isFocus) return;
      },
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        hintText: '搜索',
        hintStyle: const TextStyle(fontSize: 12),
        isDense: true,
        isCollapsed: true,
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent, width: 0),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: focusedColor, width: 0.5),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent, width: 0),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        disabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent, width: 0),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            Icons.search_sharp,
            size: 16,
            color: Colors.white30,
          ),
        ),
      ),
    );
  }

  Widget _buildCancelTap(BuildContext context) {
    String title = isEdit! ? '取消' : '新建';
    return TapLayout(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      child: Text(title, style: const TextStyle(color: Colors.blue)),
      onTap: () {
        if (isEdit!) {
        }
      },
    );
  }
}
