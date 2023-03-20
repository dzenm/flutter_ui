import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'keyboard_manager.dart';

class KeyboardMediaQuery extends StatefulWidget {
  final Widget child;

  const KeyboardMediaQuery({super.key, required this.child});

  @override
  State<StatefulWidget> createState() => KeyboardMediaQueryState();
}

class KeyboardMediaQueryState extends State<KeyboardMediaQuery> {
  double keyboardHeight = 0;
  ValueNotifier<double> keyboardHeightNotifier = CoolKeyboard.keyboardHeightNotifier;

  @override
  void initState() {
    super.initState();
    CoolKeyboard.keyboardHeightNotifier.addListener(onUpdateHeight);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var data = MediaQuery.maybeOf(context);
    data ??= MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    var bottom = CoolKeyboard.keyboardHeightNotifier.value != 0
        ? CoolKeyboard.keyboardHeightNotifier.value
        : data.viewInsets.bottom;
    // TODO: implement build
    return MediaQuery(
      data: data.copyWith(viewInsets: data.viewInsets.copyWith(bottom: bottom)),
      child: widget.child,
    );
  }

  onUpdateHeight() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() => {});
      SchedulerBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.handleMetricsChanged();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    CoolKeyboard.keyboardHeightNotifier.removeListener(onUpdateHeight);
  }
}
