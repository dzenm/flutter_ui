import 'package:flutter/widgets.dart';

import 'keyboard_manager.dart';
import 'keyboard_media_query.dart';

class KeyboardRootWidget extends StatefulWidget {
  final Widget child;

  /// The text direction for this subtree.
  final TextDirection textDirection;

  const KeyboardRootWidget({Key? key, required this.child, this.textDirection = TextDirection.ltr}) : super(key: key);

  @override
  State<StatefulWidget> createState() => KeyboardRootState();
}

class KeyboardRootState extends State<KeyboardRootWidget> {
  WidgetBuilder? _keyboardBuilder;

  bool get hasKeyboard => _keyboardBuilder != null;

  @override
  Widget build(BuildContext context) {
    return KeyboardMediaQuery(
      child: Builder(builder: (context) {
        CoolKeyboard.init(this, context);

        List<Widget> children = [widget.child];
        if (_keyboardBuilder != null) {
          children.add(Builder(builder: _keyboardBuilder!));
        }
        return Directionality(
          textDirection: widget.textDirection,
          child: Stack(children: children),
        );
      }),
    );
  }

  setKeyboard(WidgetBuilder keyboardBuilder) {
    setState(() => _keyboardBuilder = keyboardBuilder);
  }

  clearKeyboard() {
    if (this._keyboardBuilder != null) {
      this._keyboardBuilder = null;
      setState(() {});
    }
  }
}
