import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import 'common_widget.dart';
import 'tap_layout.dart';

typedef ItemClickCallback = void Function(int index);

const kMaxWidthInDialog = 520.0;
const kMaxHeightInDialog = 600.0;

class CommonDialog {
  static void init(BuildContext? context) {
    _context = context;
  }

  static BuildContext? _context;

  /// toast弹出提示框
  /// CommonDialog.showToast('hello')
  static CancelFunc showToast(String text, {int seconds = 2}) {
    return BotToast.showText(
      text: text,
      onlyOne: true,
      duration: Duration(seconds: seconds),
      textStyle: const TextStyle(fontSize: 14, color: Colors.white),
    );
  }

  /// 加载中对话框
  /// CommonDialog.loading()
  static CancelFunc loading({String? loadingTxt, bool isVertical = true, bool light = false}) {
    loadingTxt ??= S.of(_context!).loading;
    List<Widget> widgets = [
      const SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(strokeWidth: 2, backgroundColor: Colors.white),
      ),
      const SizedBox(width: 20, height: 20),
      Text(loadingTxt, style: const TextStyle(color: Colors.white, fontSize: 16)),
    ];
    return BotToast.showCustomLoading(
      align: Alignment.center,
      backgroundColor: light ? Colors.black26 : Colors.transparent,
      ignoreContentClick: true,
      clickClose: false,
      allowClick: false,
      crossPage: false,
      toastBuilder: (_) => Container(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
        decoration: const BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
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

  /// iOS风格底部选择图片对话框
  /// CommonDialog.showSelectImageBottomSheet(context)
  static Future<void> showSelectImageBottomSheet(
      BuildContext context, {
        Function? onCameraTap,
        Function? onGalleryTap,
      }) async {
    return await showListBottomSheet(context, [
      S.of(context).camera,
      S.of(context).gallery,
    ], (item) async {
      if (item == 0) {
        if (onCameraTap != null) onCameraTap();
      } else if (item == 1) {
        if (onGalleryTap != null) onGalleryTap();
      }
    });
  }

  /// iOS风格底部列表选择对话框
  /// CommonDialog.showListBottomSheet(context, data, (int index) {
  ///   RouteManager.pop(context);
  /// })
  static Future<void> showListBottomSheet(
      BuildContext context,
      List<String> items,
      ItemClickCallback? onTap, {
        double height = 45.0,
        bool isMaterial = false,
      }) async {
    List<String> data = [];
    for (var item in items) {
      data.add(item);
    }
    if (!isMaterial) data.add('CommonWidget.divider');
    data.add(S.of(context).cancel);

    double realHeight = (items.length + 1) * height;

    Widget buildChild(int index) {
      BorderRadius? borderRadius;
      if (!isMaterial) {
        if (index == items.length) return const SizedBox(height: 4); // 取消按钮和列表按钮之间的分隔条
        borderRadius = items.length == 1 // item只有一个按钮
            ? const BorderRadius.all(Radius.circular(8))
            : index == 0 || index == data.length - 1 // item的第一个按钮和取消按钮
            ? const BorderRadius.vertical(top: Radius.circular(8))
            : index == items.length - 1 // item的最后一个按钮
            ? const BorderRadius.vertical(bottom: Radius.circular(8))
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
            if (!isMaterial && index < items.length - 1) CommonWidget.divider(),
          ]),
        ),
      );
    }

    int index = -1;
    Widget child = realHeight > MediaQuery.of(context).size.width / 2
        ? ListView.builder(
      itemCount: data.length,
      itemBuilder: (BuildContext context, int index) => buildChild(index),
    )
        : Column(
      mainAxisSize: MainAxisSize.min,
      children: data.map((e) {
        index++;
        return buildChild(index);
      }).toList(),
    );

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
            child: child,
          ),
        );
      },
    );
  }

  /// iOS风格提示对话框
  /// CommonDialog.showPromptDialog(
  ///   context,
  ///   titleString: '昵称',
  ///   content: Text('这是设置好的昵称'),
  ///   onPositiveTap: () => CommonDialog.showToast('修改成功'),
  /// )
  static Future<T> showPromptDialog<T>(
      BuildContext context, {
        bool barrierDismissible = false,
        String? titleString,
        Widget? title,
        Widget? content,
        String? positiveText,
        String? negativeText,
        TextStyle? positiveStyle,
        TextStyle? negativeStyle,
        GestureTapCallback? onPositiveTap,
        GestureTapCallback? onNegativeTap,
        bool singleButton = false,
      }) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return DialogWrapper(
          isTouchOutsideDismiss: barrierDismissible,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(height: content == null ? 36 : 20),
            title ?? Text(titleString ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content == null
                ? const SizedBox(width: 0, height: 36)
                : Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: content,
              ),
            ),
            CupertinoDialogButton(
              positiveText: positiveText,
              negativeText: negativeText,
              positiveStyle: positiveStyle,
              negativeStyle: negativeStyle,
              onPositiveTap: onPositiveTap,
              onNegativeTap: onNegativeTap,
              singleButton: singleButton,
            )
          ]),
        );
      },
    );
  }

  /// 默认弹窗
  static Future<T?> showDefaultDialog<T>(
      BuildContext context, {
        Widget? mainWidget,
        String? contentText,
        bool oneBtn = false,
        String? cancelTxt,
        String? confirmTxt,
        Function? confirmCallback,
        Function? dismissCallback,
        Color? cancelColor, //l 取消按钮字体颜色
        bool dismissible = false,
      }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) {
        return CupertinoAlertDialog(
          content: Container(
            alignment: Alignment.center,
            constraints: const BoxConstraints(minHeight: 50),
            child: mainWidget ?? Text(contentText!, style: const TextStyle(fontSize: 16)),
          ),
          actions: [
            if (!oneBtn)
              CupertinoDialogAction(
                child: Text(
                  cancelTxt ?? S.of(context).cancel,
                  style: TextStyle(fontSize: 15, color: cancelColor),
                ),
                onPressed: () {
                  dismissCallback == null ? Navigator.of(context).pop() : dismissCallback();
                },
              ),
            CupertinoDialogAction(
              child: Text(
                confirmTxt ?? S.of(context).confirm,
                style: const TextStyle(fontSize: 15),
              ),
              onPressed: () {
                confirmCallback == null ? Navigator.of(context).pop() : confirmCallback();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<T> showCustomDialog<T>(
      BuildContext context, {
        bool barrierDismissible = false,
        GestureTapCallback? dismissCallback,
        Widget? child,
        Color? barrierColor,
        Color? color,
        EdgeInsetsGeometry? padding,
        BoxConstraints? constraints,
        BorderRadius? borderRadius,
      }) async {
    return await showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black54,
      builder: (context) {
        return DialogWrapper(
          dismissCallback: dismissCallback,
          isTouchOutsideDismiss: barrierDismissible,
          color: color ?? Colors.white,
          padding: padding,
          constraints: constraints,
          borderRadius: borderRadius,
          child: child,
        );
      },
    );
  }
}

/// Dialog设置是否可以点击外部取消显示
class DialogWrapper extends StatelessWidget {
  final bool isTouchOutsideDismiss; // 点击弹窗外部关闭弹窗，默认为true， true：可以关闭 false：不可以关闭
  final GestureTapCallback? dismissCallback; // 弹窗关闭回调
  final Widget? child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final BoxConstraints constraints;
  final BorderRadius borderRadius;

  const DialogWrapper({
    super.key,
    this.isTouchOutsideDismiss = false,
    this.dismissCallback,
    this.child,
    Color? color,
    EdgeInsetsGeometry? padding,
    BoxConstraints? constraints,
    BorderRadius? borderRadius,
  })  : color = color ?? Colors.white,
        padding = padding ?? const EdgeInsets.symmetric(horizontal: 32),
        constraints = constraints ?? const BoxConstraints(maxWidth: kMaxWidthInDialog, maxHeight: kMaxHeightInDialog),
        borderRadius = borderRadius ?? const BorderRadius.all(Radius.circular(16));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isTouchOutsideDismiss ? dismissCallback ?? () => Navigator.of(context).pop() : null,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false, // 防止软键盘弹出像素溢出
        body: Center(
          child: Container(
            padding: padding,
            constraints: constraints,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              ClipRRect(
                borderRadius: borderRadius,
                child: Container(color: color, child: child),
              )
            ]),
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

  final bool singleButton;

  const CupertinoDialogButton({
    super.key,
    this.onPositiveTap,
    this.onNegativeTap,
    this.positiveStyle,
    this.negativeStyle,
    this.positiveText,
    this.negativeText,
    this.singleButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommonWidget.divider(color: const Color(0xFFBABABA), height: 0.5),
        Row(children: [
          Expanded(
            child: TapLayout(
              height: 45.0,
              onTap: () {
                Navigator.of(context).pop();
                if (onNegativeTap != null) onNegativeTap!();
              },
              child: Text(negativeText ?? '取消', style: negativeStyle),
            ),
          ),
          if (singleButton) Container(height: 45.0, width: 0.5, color: const Color(0xffbababa)),
          if (singleButton)
            Expanded(
              child: TapLayout(
                height: 45.0,
                onTap: () {
                  Navigator.of(context).pop();
                  if (onPositiveTap != null) onPositiveTap!();
                },
                child: Text(positiveText ?? '确定', style: positiveStyle),
              ),
            ),
        ])
      ],
    );
  }
}

/// Material居中列表显示的dialog
/// showDialog(
///   context: context,
///   builder: (BuildContext context) {
///     return ListDialog(
///       list: list,
///       onTap: (index) {},
///     );
///   },
/// )
class ListDialog extends Dialog {
  final List<String> list;
  final ItemClickCallback? onTap;

  const ListDialog({
    super.key,
    required this.list,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(2)),
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
        margin: const EdgeInsets.symmetric(horizontal: 24),
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
