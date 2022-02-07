import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/res/strings.dart';

import 'common_widget.dart';
import 'tap_layout.dart';

typedef ItemClickCallback = void Function(int index);

/// toast弹出提示框
CancelFunc showToast(String text, {int seconds = 2}) {
  return BotToast.showText(
    text: text,
    onlyOne: true,
    duration: Duration(seconds: seconds),
    textStyle: TextStyle(fontSize: 14, color: Colors.white),
  );
}

/// 加载中对话框
CancelFunc loadingDialog({String? loadingTxt, bool isVertical = true}) {
  loadingTxt ??= S.of.loading;
  List<Widget> widgets = [
    SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 2, backgroundColor: Colors.white)),
    SizedBox(width: 20, height: 20),
    Text(loadingTxt, style: TextStyle(color: Colors.white, fontSize: 16)),
  ];
  return BotToast.showCustomLoading(
    align: Alignment.center,
    backgroundColor: Colors.black26,
    ignoreContentClick: true,
    clickClose: false,
    allowClick: false,
    crossPage: false,
    toastBuilder: (_) => Container(
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 40),
      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.all(Radius.circular(8))),
      child: isVertical
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: widgets,
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: widgets,
            ),
    ),
  );
}

/// 选择图片对话框
void showSelectImageBottomSheet(BuildContext context, {Function? onCameraTap, Function? onGalleryTap}) {
  showListBottomSheet(context, [S.of.camera, S.of.gallery], (item) async {
    if (item == 0) {
      if (onCameraTap != null) onCameraTap();
    } else if (item == 1) {
      if (onGalleryTap != null) onGalleryTap();
    }
  });
}

/// 列表选择对话框
void showListBottomSheet(BuildContext context, List<String> items, ItemClickCallback? onTap, {double height = 45.0, bool isMaterial = false}) {
  List<String> data = [];
  items.forEach((item) => data.add(item));
  if (!isMaterial) data.add('divider');
  data.add(S.of.cancel);

  double realHeight = (items.length + 1) * height;

  Widget _child(int index) {
    BorderRadius? borderRadius;
    if (!isMaterial) {
      if (index == items.length) return SizedBox(height: 4); // 取消按钮和列表按钮之间的分隔条
      borderRadius = items.length == 1 // item只有一个按钮
          ? BorderRadius.all(Radius.circular(8))
          : index == 0 || index == data.length - 1 // item的第一个按钮和取消按钮
              ? BorderRadius.vertical(top: Radius.circular(8))
              : index == items.length - 1 // item的最后一个按钮
                  ? BorderRadius.vertical(bottom: Radius.circular(8))
                  : null;
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius,
      ),
      child: TapLayout(
        height: height,
        borderRadius: borderRadius,
        onTap: () {
          if (onTap != null && index < items.length) onTap(index);
          Navigator.pop(context);
        },
        child: Column(children: [
          Expanded(child: Container(alignment: Alignment.center, child: Text(data[index]))),
          if (!isMaterial && index < items.length - 1) divider(),
        ]),
      ),
    );
  }

  Widget _children() {
    int index = -1;
    return realHeight > MediaQuery.of(context).size.width / 2
        ? ListView.builder(
            itemCount: data.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) => _child(index),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: data.map((e) {
              index++;
              return _child(index);
            }).toList(),
          );
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    builder: (builder) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height / 2,
          minHeight: height,
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        width: MediaQuery.of(context).size.width,
        child: PhysicalModel(
          color: isMaterial ? Colors.white : Colors.transparent,
          clipBehavior: Clip.antiAlias,
          child: _children(),
        ),
      );
    },
  );
}

/// 提示对话框
void showPromptDialog(
  BuildContext context, {
  bool isTouchOutsideDismiss = false,
  String? titleString,
  Widget? title,
  Widget? content,
  String? positiveText,
  String? negativeText,
  TextStyle? positiveStyle,
  TextStyle? negativeStyle,
  GestureTapCallback? onPositiveTap,
  GestureTapCallback? onNegativeTap,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return DialogWrapper(
        isTouchOutsideDismiss: isTouchOutsideDismiss,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(height: content == null ? 36 : 20),
          title ?? Text(titleString ?? '', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content == null
              ? SizedBox(width: 0, height: 36)
              : Flexible(
                  child: Padding(
                    child: content,
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                  ),
                ),
          CupertinoDialogButton(
            positiveText: positiveText,
            negativeText: negativeText,
            positiveStyle: positiveStyle,
            negativeStyle: negativeStyle,
            onPositiveTap: onPositiveTap,
            onNegativeTap: onNegativeTap,
          )
        ]),
      );
    },
  );
}

/// Dialog设置是否可以点击外部取消显示
class DialogWrapper extends StatefulWidget {
  final bool isTouchOutsideDismiss; // 点击弹窗外部，关闭弹窗，默认为true， true：可以关闭 false：不可以关闭
  final GestureTapCallback? dismissCallback; // 弹窗关闭回调
  final Widget? child;
  final Color color;
  final BorderRadius borderRadius;

  const DialogWrapper({
    Key? key,
    this.isTouchOutsideDismiss = false,
    this.dismissCallback,
    this.child,
    this.color = Colors.white,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DialogWrapperState();
}

class _DialogWrapperState extends State<DialogWrapper> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isTouchOutsideDismiss
          ? widget.dismissCallback == null
              ? () => Navigator.of(context).pop()
              : widget.dismissCallback
          : null,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: widget.borderRadius,
                child: Container(
                  width: MediaQuery.of(context).size.width - 40 * 2,
                  color: widget.color,
                  child: widget.child,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// 底部按钮区域
class CupertinoDialogButton extends StatelessWidget {
  final String? positiveText;
  final String? negativeText;

  final TextStyle? positiveStyle;
  final TextStyle? negativeStyle;

  final GestureTapCallback? onPositiveTap;
  final GestureTapCallback? onNegativeTap;

  CupertinoDialogButton({
    Key? key,
    this.onPositiveTap,
    this.onNegativeTap,
    this.positiveStyle,
    this.negativeStyle,
    this.positiveText,
    this.negativeText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        divider(color: Color(0xFFBABABA), height: 0.5),
        Row(children: [
          Expanded(
            child: TapLayout(
              height: 45.0,
              isRipple: false,
              onTap: () {
                Navigator.of(context).pop();
                if (onNegativeTap != null) onNegativeTap!();
              },
              child: Text(negativeText ?? S.of.cancel, style: negativeStyle ?? TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
          ),
          Container(color: Color(0xFFBABABA), height: 45.0, width: 0.5),
          Expanded(
            child: TapLayout(
              height: 45.0,
              isRipple: false,
              onTap: () {
                Navigator.of(context).pop();
                if (onPositiveTap != null) onPositiveTap!();
              },
              child: Text(positiveText ?? S.of.confirm, style: positiveStyle ?? TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
          ),
        ])
      ],
    );
  }
}

/// 列表显示的dialog
class ListDialog extends Dialog {
  final List<String> list;
  final ItemClickCallback? onTap;

  ListDialog({
    required this.list,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 40),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(2)),
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _buildListView(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 创建List
  List<Widget> _buildListView(BuildContext context) {
    List<Widget> listView = [];
    listView.add(Container(color: Colors.white, height: 8));
    for (int i = 0; i < list.length; i++) {
      listView.add(_buildItemView(context, i));
    }
    listView.add(Container(color: Colors.white, height: 8));
    return listView;
  }

  /// 创建Item
  Widget _buildItemView(BuildContext context, int index) {
    return TapLayout(
      background: Colors.white,
      isRipple: false,
      child: Container(
        height: 48,
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.symmetric(horizontal: 24),
        width: double.infinity,
        child: Text(list[index]),
      ),
      onTap: () {
        if (onTap != null) onTap!(index);
        Navigator.pop(context, list[index]);
      },
    );
  }
}
