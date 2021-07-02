import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/main.dart';

class RouteManager {
  static NavigatorState get _state => navigator.currentState!;

  static Future<dynamic> push(Widget widget, {bool isMaterial = false}) {
    return _state.push(_getPageRoute(widget, isMaterial));
  }

  static Future<dynamic> pushReplace(Widget widget, {bool isMaterial = false}) {
    return _state.pushReplacement(_getPageRoute(widget, isMaterial));
  }

  static PageRoute _getPageRoute(Widget widget, bool isMaterial) {
    if (isMaterial) {
      return MaterialPageRoute(
        builder: (BuildContext context) => widget,
        settings: new RouteSettings(name: widget.toStringShort()),
      );
    } else {
      return CupertinoPageRoute(
        builder: (BuildContext context) => widget,
        settings: new RouteSettings(name: widget.toStringShort()),
      );
    }
  }

  // Future<dynamic> routeFadePush(Widget widget) {
  //   final route = new FadeRoute(widget);
  //   return _state.push(route);
  // }
  //
  // Future<dynamic> routeRotationPush(Widget widget) {
  //   final route = new RotationRoute(widget);
  //   return _state.push(route);
  // }

  static Future<dynamic> routePushAndRemove(Widget widget) {
    final CupertinoPageRoute route = CupertinoPageRoute(
      builder: (BuildContext context) => widget,
      settings: new RouteSettings(
        name: widget.toStringShort(),
      ),
    );
    return _state.pushAndRemoveUntil(route, (route) => route == null);
  }

  static popToPage(Widget page) {
    _state.pushAndRemoveUntil(new MaterialPageRoute<dynamic>(
      builder: (BuildContext context) {
        return page;
      },
    ), (Route<dynamic> route) => false);
  }

  static pushReplacement(Widget page) {
    _state.pushReplacement(new MaterialPageRoute<dynamic>(
      builder: (BuildContext context) {
        return page;
      },
    ));
  }
}
