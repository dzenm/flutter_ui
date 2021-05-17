import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SlidePageTransition extends PageTransitionsBuilder {
  SlideDirect slideDirect;

  SlidePageTransition({this.slideDirect = SlideDirect.rightToLeft});

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    switch (slideDirect) {
      case SlideDirect.left:
        break;
      case SlideDirect.top:
        break;
      case SlideDirect.right:
        break;
      case SlideDirect.bottom:
        return SlideTransition(
          position: CurvedAnimation(parent: animation, curve: Curves.ease).drive(Tween(begin: Offset(0.0, 1.0), end: Offset.zero)),
          child: child,
        );
      case SlideDirect.leftToRight:
        break;
      case SlideDirect.topToBottom:
        break;
      case SlideDirect.rightToLeft:
        return SlideTransition(
          position: animation.drive(CurveTween(curve: Curves.fastOutSlowIn)).drive(Tween(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0))),
          child: child,
        );
      case SlideDirect.bottomToTop:
        break;
    }
    return SlideTransition(
      position: animation.drive(CurveTween(curve: Curves.fastOutSlowIn)).drive(Tween(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0))),
      child: child,
    );
  }
}

enum SlideDirect {
  left,
  top,
  right,
  bottom,
  leftToRight,
  rightToLeft,
  topToBottom,
  bottomToTop,
}
