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
      child: isVertical ? Column(mainAxisSize: MainAxisSize.min, children: widgets) : Row(mainAxisSize: MainAxisSize.min, children: widgets),
    ),
  );
}

/// 选择图片对话框
void showSelectImageBottomSheet(BuildContext context, {Function? onCameraClick, Function? onGalleryClick}) {
  showListBottomSheet(context, [S.of.camera, S.of.gallery], (item) async {
    if (item == 0) {
      if (onCameraClick != null) onCameraClick();
    } else if (item == 1) {
      if (onGalleryClick != null) onGalleryClick();
    }
  });
}

/// 列表选择对话框
void showListBottomSheet(BuildContext context, List<String> items, ItemClickCallback? onTap, {double height = 45.0}) {
  List<String> data = [];
  items.forEach((item) => data.add(item));
  data.add(S.of.cancel);

  double realHeight = (items.length + 1) * height;

  Widget _child(int index) {
    return TapLayout(
      height: height,
      onTap: () {
        Navigator.pop(context);
        if (onTap != null && index < data.length - 1) onTap(index);
      },
      child: Container(alignment: Alignment.center, child: Text(data[index])),
    );
  }

  Widget _listView() {
    return ListView.builder(
      itemCount: data.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) => _child(index),
    );
  }

  Widget _columns() {
    int index = -1;
    return Column(
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
        width: MediaQuery.of(context).size.width,
        child: PhysicalModel(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          clipBehavior: Clip.antiAlias,
          child: realHeight > MediaQuery.of(context).size.width / 2 ? _listView() : _columns(),
        ),
      );
    },
  );
}

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
        child: Column(mainAxisSize: MainAxisSize.min,children: [
          SizedBox(height: 20),
          title ?? Text(titleString ?? '', style: TextStyle(fontSize: 16)),
          content == null
              ? SizedBox(width: 0, height: 16)
              : Flexible(
            child: Padding(
              child: content,
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            ),
          ),
          BottomButton(
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
  final bool isTouchOutsideDismiss; // 点击弹窗外部，关闭弹窗，默认为true true：可以关闭 false：不可以关闭
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
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
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

class BottomButton extends StatelessWidget {
  final String? positiveText;
  final String? negativeText;

  final TextStyle? positiveStyle;
  final TextStyle? negativeStyle;

  final GestureTapCallback? onPositiveTap;
  final GestureTapCallback? onNegativeTap;

  BottomButton({
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
        divider(color: Color(0xffbababa), height: 0.5),
        Row(children: [
          Expanded(
            child: TapLayout(
              height: 45.0,
              onTap: () {
                Navigator.of(context).pop();
                if (onNegativeTap != null) onNegativeTap!();
              },
              child: Text(negativeText ?? S.of.cancel, style: negativeStyle),
            ),
          ),
          Container(height: 45.0, width: 0.5, color: Color(0xffbababa)),
          Expanded(
            child: TapLayout(
              height: 45.0,
              onTap: () {
                Navigator.of(context).pop();
                if (onPositiveTap != null) onPositiveTap!();
              },
              child: Text(positiveText ?? S.of.confirm, style: positiveStyle),
            ),
          ),
        ])
      ],
    );
  }
}
