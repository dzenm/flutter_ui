import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';

import 'common_widget.dart';

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
  loadingTxt ??= '加载中';
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

void showSelectImageSheet(BuildContext context, {Function? onCameraClick, Function? onGalleryClick}) {
  showBottomSheetLayout(context, items: ['拍照', '从相册中选择'], onTapFunc: (item) async {
    if (item == '拍照') {
      if (onCameraClick != null) onCameraClick();
    } else {
      if (onGalleryClick != null) onGalleryClick();
    }
  });
}

void showBottomSheetLayout(BuildContext context, {List<String>? items, Function? onTapFunc}) {
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
            child: Column(
              children: items!.map((e) {
                int index = items.indexOf(e);
                if (index != items.length - 1) {
                  return Column(
                    children: [
                      TapLayout(
                          width: MediaQuery.of(context).size.width,
                          height: 45,
                          onTap: () {
                            Navigator.pop(context);
                            if (onTapFunc != null) onTapFunc(e);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(e),
                          )),
                      divider(),
                    ],
                  );
                } else {
                  return TapLayout(
                      width: MediaQuery.of(context).size.width,
                      height: 45,
                      onTap: () {
                        Navigator.pop(context);
                        if (onTapFunc != null) onTapFunc(e);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(e),
                      ));
                }
              }).toList(),
            ),
          ),
          TapLayout(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(top: 5, bottom: 2),
            height: 45,
            borderRadius: BorderRadius.circular(5),
            onTap: () => Navigator.pop(context),
            child: Container(alignment: Alignment.center, child: Text('取消')),
          ),
        ]);
      });
}
