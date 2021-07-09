import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/res/strings.dart';

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
  List<Widget> _listItems() {
    List<Widget> list = [];
    int index = 0;
    items.add(S.of.cancel);
    items.forEach((item) {
      list.add(TapLayout(
        width: MediaQuery.of(context).size.width,
        height: height,
        onTap: () {
          Navigator.pop(context);
          if (onTap != null && index != items.length - 1) onTap(index);
        },
        child: Container(
          alignment: Alignment.center,
          child: Text(item),
        ),
      ));
      index++;
    });
    return list;
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    builder: (builder) {
      return Column(mainAxisSize: MainAxisSize.min, children: [
        PhysicalModel(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          clipBehavior: Clip.antiAlias,
          child: Column(children: _listItems()),
        ),
      ]);
    },
  );
}

class CustomDialog extends StatefulWidget {
  //------------------不带图片的dialog------------------------
  final String? title; //弹窗标题
  final String? content; //弹窗内容
  final String? confirmContent; //按钮文本
  final Color? confirmTextColor; //确定按钮文本颜色
  final bool isCancel; //是否有取消按钮，默认为true true：有 false：没有
  final Color? confirmColor; //确定按钮颜色
  final Color? cancelColor; //取消按钮颜色
  final bool outsideDismiss; //点击弹窗外部，关闭弹窗，默认为true true：可以关闭 false：不可以关闭
  final Function? confirmCallback; //点击确定按钮回调
  final Function? dismissCallback; //弹窗关闭回调
  final Widget? dialogWidget;
  final bool hideKeyboard;

  //------------------带图片的dialog------------------------
  final String? image; //dialog添加图片
  final String? imageHintText; //图片下方的文本提示

  const CustomDialog(
      {Key? key,
      this.title,
      this.content,
      this.confirmContent,
      this.confirmTextColor,
      this.isCancel = true,
      this.confirmColor,
      this.cancelColor,
      this.outsideDismiss = true,
      this.confirmCallback,
      this.dismissCallback,
      this.image,
      this.hideKeyboard = false,
      this.imageHintText,
      this.dialogWidget})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  StreamSubscription? onKeyboardChange;

  _dismissDialog() {
    if (widget.dismissCallback != null) {
      widget.dismissCallback!();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.hideKeyboard) {
      // onKeyboardChange = KeyboardVisibility.onChange.listen((bool visible) {
      //   if (!visible) FocusScope.of(context).unfocus();
      // });
    }
  }

  @override
  void dispose() {
    onKeyboardChange?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => widget.outsideDismiss ? _dismissDialog() : null,
        behavior: HitTestBehavior.opaque,
        child: Scaffold(backgroundColor: Colors.transparent, body: Center(child: widget.dialogWidget)));
//        return WillPopScope(
//        child: GestureDetector(
//          onTap: () => {widget.outsideDismiss ? _dismissDialog() : null},
//          child: Material(
//            type: MaterialType.transparency,
//            child: Scaffold(
//              backgroundColor: Colors.transparent,
//              body: Center(child: widget.dialogWidget)
//            ),
//          ),
//        ),
//        onWillPop: () async {
//          return widget.outsideDismiss;
//        });
  }
}
