import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'common_widget.dart';
import 'tap_layout.dart';

typedef ItemClickCallback = void Function(int index);

const kMaxWidthInDialog = 640.0;
const kMaxHeightInDialog = 600.0;

class CommonDialog {
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
  static CancelFunc loading({String loadingTxt = 'loading', bool isVertical = true, bool light = false}) {
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

  static void show(BuildContext context, String? title, dynamic body,
      {VoidCallback? callback}) {
    if (body is String) {
      body = Text(body);
    }
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: title == null || title.isEmpty ? null : Text(title),
        content: body,
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
              if (callback != null) {
                callback();
              }
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  static void confirm(BuildContext context, String? title, dynamic body,
      {String? okTitle, VoidCallback? okAction,
        String? cancelTitle, VoidCallback? cancelAction}) {
    okTitle ??= 'OK';
    cancelTitle ??= 'Cancel';
    if (body is String) {
      body = Text(body);
    }
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: title == null || title.isEmpty ? null : Text(title),
        content: body,
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
              if (okAction != null) {
                okAction();
              }
            },
            child: Text(okTitle!),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
              if (cancelAction != null) {
                cancelAction();
              }
            },
            isDestructiveAction: true,
            child: Text(cancelTitle!),
          ),
        ],
      ),
    );
  }

  static void actionSheet(BuildContext context, String? title, String? message,
      dynamic action1, VoidCallback callback1, [
        dynamic action2, VoidCallback? callback2,
        dynamic action3, VoidCallback? callback3,
      ]) => showCupertinoModalPopup(context: context,
    builder: (context) => CupertinoActionSheet(
      title: title == null || title.isEmpty ? null : Text(title),
      message: message == null || message.isEmpty ? null : Text(message),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            callback1();
          },
          child: action1 is String ? Text(action1) : action1,
        ),
        if (action2 != null)
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              if (callback2 != null) {
                callback2();
              }
            },
            child: action2 is String ? Text(action2) : action2,
          ),
        if (action3 != null)
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              if (callback3 != null) {
                callback3();
              }
            },
            child: action3 is String? Text(action3) : action3,
          ),
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDestructiveAction: true,
          child: Text('Cancel'),
        ),
      ],
    ),
  );

  /// iOS风格底部选择图片对话框
  /// CommonDialog.showSelectImageBottomSheet(context)
  static Future<void> showSelectImageBottomSheet(
    BuildContext context, {
    String cameraText = 'camera',
    String galleryText = 'gallery',
    Function? onCameraTap,
    Function? onGalleryTap,
  }) async {
    return await showListBottomSheet(context, [
      cameraText,
      galleryText,
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
  ///   AppRouterOldDelegate.pop(context);
  /// })
  static Future<void> showListBottomSheet(
    BuildContext context,
    List<String> items,
    ItemClickCallback? onTap, {
    double height = 45.0,
    String cancelText = 'cancel',
    bool isMaterial = false,
  }) async {
    List<String> data = [];
    for (var item in items) {
      data.add(item);
    }
    if (!isMaterial) data.add('CommonWidget.divider');
    data.add(cancelText);

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
    return await showCustomDialog(
      context,
      barrierDismissible: barrierDismissible,
      margin: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(height: content == null ? 36 : 20),
        title ??
            Text(
              titleString ?? '',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
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
  }

  /// 默认弹窗
  static Future<T?> showDefaultDialog<T>(
    BuildContext context, {
    Widget? mainWidget,
    String? contentText,
    bool oneBtn = false,
    String cancelText = 'cancel',
    String confirmText = 'confirm',
    Function? confirmCallback,
    Function? dismissCallback,
    Color? cancelColor, //l 取消按钮字体颜色
    bool dismissible = false,
  }) async {
    return await showCustomDialog<T>(
      context,
      barrierDismissible: dismissible,
      child: CupertinoAlertDialog(
        content: Container(
          alignment: Alignment.center,
          constraints: const BoxConstraints(minHeight: 50),
          child: mainWidget ?? Text(contentText!, style: const TextStyle(fontSize: 16)),
        ),
        actions: [
          if (!oneBtn)
            CupertinoDialogAction(
              child: Text(
                cancelText,
                style: TextStyle(fontSize: 15, color: cancelColor),
              ),
              onPressed: () {
                dismissCallback == null ? Navigator.of(context).pop() : dismissCallback();
              },
            ),
          CupertinoDialogAction(
            child: Text(
              confirmText,
              style: const TextStyle(fontSize: 15),
            ),
            onPressed: () {
              confirmCallback == null ? Navigator.of(context).pop() : confirmCallback();
            },
          ),
        ],
      ),
    );
  }

  static Future<T?> showCustomDialog<T>(
    BuildContext context, {
    bool barrierDismissible = true,
    Color? barrierColor,
    Widget? child,
    RoutePageBuilder? pageBuilder,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    TransitionType transitionType = TransitionType.fade,
    GestureTapCallback? barrierOnTap,
    Color? color,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    BoxConstraints? constraints,
  }) async {
    assert(debugCheckHasMaterialLocalizations(context));
    return await showGeneralDialog<T>(
      context: context,
      pageBuilder: pageBuilder ??
          (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
            return SafeArea(
              child: DialogWrapper(
                isTouchOutsideDismiss: barrierDismissible,
                barrierOnTap: barrierOnTap,
                color: color ?? Colors.white,
                margin: margin,
                borderRadius: borderRadius,
                constraints: constraints,
                child: child,
              ),
            );
          },
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: barrierColor ?? Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return buildTransitions(animation, secondaryAnimation, child, transitionType);
      },
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
    );
  }
}

/// Dialog设置是否可以点击外部取消显示
class DialogWrapper extends StatelessWidget {
  final bool isTouchOutsideDismiss; // 点击弹窗外部关闭弹窗，默认为true， true：可以关闭 false：不可以关闭
  final GestureTapCallback? barrierOnTap; // 弹窗关闭回调
  final Widget? child;
  final Color color;
  final EdgeInsetsGeometry margin;
  final BoxConstraints constraints;
  final BorderRadius borderRadius;

  const DialogWrapper({
    super.key,
    this.isTouchOutsideDismiss = false,
    this.barrierOnTap,
    this.child,
    Color? color,
    EdgeInsetsGeometry? margin,
    BoxConstraints? constraints,
    BorderRadius? borderRadius,
  })  : color = color ?? Colors.white,
        margin = margin ?? const EdgeInsets.symmetric(horizontal: 32),
        constraints = constraints ??
            const BoxConstraints(
              maxWidth: kMaxWidthInDialog,
              maxHeight: kMaxHeightInDialog,
            ),
        borderRadius = borderRadius ?? const BorderRadius.all(Radius.circular(16));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isTouchOutsideDismiss ? barrierOnTap ?? () => Navigator.of(context).pop() : null, // 外部触摸事件，关闭弹窗
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false, // 防止软键盘弹出像素溢出
        body: GestureDetector(
          onTap: () {}, // 内部触摸事件，防止触发外部触摸事件（阻断外部触摸事件的执行，所以不做处理）
          child: Center(
            child: Container(
              margin: margin,
              constraints: constraints,
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                color: color,
              ),
              clipBehavior: Clip.antiAlias,
              child: child,
            ),
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
    return Column(children: [
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
        if (!singleButton) Container(height: 45.0, width: 0.5, color: const Color(0xffbababa)),
        if (!singleButton)
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
      ]),
    ]);
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

/// 跳转动画
Widget buildTransitions(
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
  TransitionType type,
) {
  switch (type) {
    case TransitionType.left:
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
        ),
        child: child,
      );
    case TransitionType.top:
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(0.0, -1.0), end: Offset.zero).animate(
          CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
        ),
        child: child,
      );
    case TransitionType.right:
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
        ),
        child: child,
      );
    case TransitionType.bottom:
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(
          CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
        ),
        child: child,
      );
    case TransitionType.inLeftOutRight:
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
        ),
        child: SlideTransition(
          position: Tween<Offset>(begin: Offset.zero, end: const Offset(1.0, 0.0)).animate(
            CurvedAnimation(parent: secondaryAnimation, curve: Curves.fastOutSlowIn),
          ),
          child: child,
        ),
      );
    case TransitionType.inTopOutBottom:
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(0.0, -1.0), end: Offset.zero).animate(
          CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
        ),
        child: child,
      );
    case TransitionType.inRightOutLeft:
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
        ),
        child: child,
      );
    case TransitionType.inBottomOutTop:
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(
          CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
        ),
        child: child,
      );
    case TransitionType.scale:
      return ScaleTransition(
        scale: Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
        ),
        child: child,
      );
    case TransitionType.fade:
      return FadeTransition(
        // 从0开始到1
        opacity: Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            // 传入设置的动画
            parent: animation,
            // 设置效果，快进漫出   这里有很多内置的效果
            curve: Curves.fastOutSlowIn,
          ),
        ),
        child: child,
      );
    case TransitionType.rotation:
      return RotationTransition(
        turns: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.fastOutSlowIn,
        )),
        child: ScaleTransition(
          scale: Tween(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
          ),
          child: child,
        ),
      );
    case TransitionType.size:
      return SizeTransition(
        sizeFactor: Tween<double>(begin: 0.1, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.linear),
        ),
        axisAlignment: 1.0,
        child: child,
      );
  }
}

enum TransitionType {
  left, //从左边进从左边出
  top, //从上面进从上面出
  right, //从右边进从右边出
  bottom, //从下面进从下面出
  inLeftOutRight, //从左边进从右边出
  inTopOutBottom, //从上面进从下面出
  inRightOutLeft, //从右边进从左边出
  inBottomOutTop, //从下面进从上面出
  scale, // 从小缩放到正常比例
  fade, // 透明度变化
  rotation, // 旋转
  size,
}
