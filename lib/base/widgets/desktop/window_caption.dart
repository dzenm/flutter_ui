import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:window_manager/window_manager.dart';

const kTitleBarHeight = 48.0;

class _MoveWindow extends StatelessWidget {
  _MoveWindow({Key? key, this.child, this.onDoubleTap}) : super(key: key);
  final Widget? child;
  final VoidCallback? onDoubleTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (details) {
          windowManager.startDragging();
        },
        onDoubleTap: onDoubleTap ?? () async => await windowManager.isMaximized() ? windowManager.unmaximize() : windowManager.maximize(),
        child: child ?? Container());
  }
}

class MoveWindow extends StatelessWidget {
  final Widget? child;
  final VoidCallback? onDoubleTap;

  MoveWindow({Key? key, this.child, this.onDoubleTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (child == null) return _MoveWindow(onDoubleTap: this.onDoubleTap);
    return _MoveWindow(
      onDoubleTap: this.onDoubleTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: this.child!)]),
    );
  }
}

class WindowTitleBarBox extends StatelessWidget {
  final Widget? child;

  WindowTitleBarBox({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Container();
    }
    const titleBarHeight = kTitleBarHeight;
    return SizedBox(height: titleBarHeight, child: child ?? Container());
  }
}
