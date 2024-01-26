import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///
/// Created by a0010 on 2023/7/5 16:22
///
typedef BuildCustomRoute<T extends Object?> = Route<T> Function(BuildContext context, CustomPage page);

PageTransitionsBuilder defaultTransitionsBuilder() {
  if (kIsWeb) return const NoTransitionBuilder();
  switch (Platform.operatingSystem) {
    case 'android':
    case 'fuchsia':
    case 'windows':
      return const SlideTransitionsBuilder();
    case 'ios':
    case 'macos':
    case 'linux':
      return const SlideTransitionsBuilder();
  }
  return const SlideTransitionsBuilder();
}

/// 从左边进入，从右边退出的动画
class SlideTransitionsBuilder extends PageTransitionsBuilder {
  const SlideTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    var position = CurvedAnimation(
      parent: animation,
      curve: Curves.linearToEaseOut,
      reverseCurve: Curves.easeInToLinear,
    ).drive(
      Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
    );
    var secondaryPosition = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.linearToEaseOut,
      reverseCurve: Curves.easeInToLinear,
    ).drive(
      Tween(begin: Offset.zero, end: const Offset(-1.0, 0.0)),
    );
    var shadowAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.linearToEaseOut,
    ).drive(
      _CupertinoEdgeShadowDecoration.kTween,
    );
    final TextDirection textDirection = Directionality.of(context);
    return SlideTransition(
      position: secondaryPosition,
      textDirection: textDirection,
      transformHitTests: false,
      child: SlideTransition(
        position: position,
        textDirection: textDirection,
        child: DecoratedBoxTransition(
          decoration: shadowAnimation,
          child: child,
        ),
      ),
    );
  }
}

// A custom [Decoration] used to paint an extra shadow on the start edge of the
// box it's decorating. It's like a [BoxDecoration] with only a gradient except
// it paints on the start side of the box instead of behind the box.
class _CupertinoEdgeShadowDecoration extends Decoration {
  const _CupertinoEdgeShadowDecoration._([this._colors]);

  static DecorationTween kTween = DecorationTween(
    begin: const _CupertinoEdgeShadowDecoration._(), // No decoration initially.
    end: const _CupertinoEdgeShadowDecoration._(
      [
        Color(0x04000000),
        Color(0x00000000),
      ],
    ),
  );

  final List<Color>? _colors;

  static _CupertinoEdgeShadowDecoration? lerp(
    _CupertinoEdgeShadowDecoration? a,
    _CupertinoEdgeShadowDecoration? b,
    double t,
  ) {
    if (identical(a, b)) {
      return a;
    }
    if (a == null) {
      return b!._colors == null ? b : _CupertinoEdgeShadowDecoration._(b._colors!.map<Color>((Color color) => Color.lerp(null, color, t)!).toList());
    }
    if (b == null) {
      return a._colors == null ? a : _CupertinoEdgeShadowDecoration._(a._colors?.map<Color>((Color color) => Color.lerp(null, color, 1.0 - t)!).toList());
    }
    assert(b._colors != null || a._colors != null);
    // If it ever becomes necessary, we could allow decorations with different
    // length' here, similarly to how it is handled in [LinearGradient.lerp].
    assert(b._colors == null || a._colors == null || a._colors?.length == b._colors?.length);
    return _CupertinoEdgeShadowDecoration._(
      <Color>[
        for (int i = 0; i < b._colors!.length; i += 1) Color.lerp(a._colors?[i], b._colors?[i], t)!,
      ],
    );
  }

  @override
  _CupertinoEdgeShadowDecoration lerpFrom(Decoration? a, double t) {
    if (a is _CupertinoEdgeShadowDecoration) {
      return _CupertinoEdgeShadowDecoration.lerp(a, this, t)!;
    }
    return _CupertinoEdgeShadowDecoration.lerp(null, this, t)!;
  }

  @override
  _CupertinoEdgeShadowDecoration lerpTo(Decoration? b, double t) {
    if (b is _CupertinoEdgeShadowDecoration) {
      return _CupertinoEdgeShadowDecoration.lerp(this, b, t)!;
    }
    return _CupertinoEdgeShadowDecoration.lerp(this, null, t)!;
  }

  @override
  _CupertinoEdgeShadowPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CupertinoEdgeShadowPainter(this, onChanged);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is _CupertinoEdgeShadowDecoration && other._colors == _colors;
  }

  @override
  int get hashCode => _colors.hashCode;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<Color>('colors', _colors));
  }
}

/// A [BoxPainter] used to draw the page transition shadow using gradients.
class _CupertinoEdgeShadowPainter extends BoxPainter {
  _CupertinoEdgeShadowPainter(
    this._decoration,
    super.onChanged,
  ) : assert(_decoration._colors == null || _decoration._colors!.length > 1);

  final _CupertinoEdgeShadowDecoration _decoration;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final List<Color>? colors = _decoration._colors;
    if (colors == null) {
      return;
    }

    // The following code simulates drawing a [LinearGradient] configured as
    // follows:
    //
    // LinearGradient(
    //   begin: AlignmentDirectional(0.90, 0.0), // Spans 5% of the page.
    //   colors: _decoration._colors,
    // )
    //
    // A performance evaluation on Feb 8, 2021 showed, that drawing the gradient
    // manually as implemented below is more performant than relying on
    // [LinearGradient.createShader] because compiling that shader takes a long
    // time. On an iPhone XR, the implementation below reduced the worst frame
    // time for a cupertino page transition of a newly installed app from ~95ms
    // down to ~30ms, mainly because there's no longer a need to compile a
    // shader for the LinearGradient.
    //
    // The implementation below divides the width of the shadow into multiple
    // bands of equal width, one for each color interval defined by
    // `_decoration._colors`. Band x is filled with a gradient going from
    // `_decoration._colors[x]` to `_decoration._colors[x + 1]` by drawing a
    // bunch of 1px wide rects. The rects change their color by lerping between
    // the two colors that define the interval of the band.

    // Shadow spans 5% of the page.
    final double shadowWidth = 0.05 * configuration.size!.width;
    final double shadowHeight = configuration.size!.height;
    final double bandWidth = shadowWidth / (colors.length - 1);

    final TextDirection? textDirection = configuration.textDirection;
    assert(textDirection != null);
    final double start;
    final double shadowDirection; // -1 for ltr, 1 for rtl.
    switch (textDirection!) {
      case TextDirection.rtl:
        start = offset.dx + configuration.size!.width;
        shadowDirection = 1;
      case TextDirection.ltr:
        start = offset.dx;
        shadowDirection = -1;
    }

    int bandColorIndex = 0;
    for (int dx = 0; dx < shadowWidth; dx += 1) {
      if (dx ~/ bandWidth != bandColorIndex) {
        bandColorIndex += 1;
      }
      final Paint paint = Paint()..color = Color.lerp(colors[bandColorIndex], colors[bandColorIndex + 1], (dx % bandWidth) / bandWidth)!;
      final double x = start + shadowDirection * dx;
      canvas.drawRect(Rect.fromLTWH(x - 1.0, offset.dy, 1.0, shadowHeight), paint);
    }
  }
}

class CustomPage<T extends Object?> extends Page<T> {
  CustomPage({
    required this.child,
    required this.buildCustomRoute,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.barrierColor,
    this.barrierLabel,
    this.opaque = true,
    this.filter,
    this.semanticsDismissible = true,
    this.barrierDismissible = true,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  }) : completerResult = Completer();

  final BuildCustomRoute<T> buildCustomRoute;

  /// The content to be shown in the [Route] created by this page.
  final Widget child;

  /// {@macro flutter.widgets.ModalRoute.maintainState}
  final bool maintainState;

  /// {@macro flutter.widgets.PageRoute.fullscreenDialog}
  final bool fullscreenDialog;

  final Completer completerResult;

  final Duration transitionDuration;

  final Color? barrierColor;

  final String? barrierLabel;

  final bool opaque;

  final ui.ImageFilter? filter;

  final bool semanticsDismissible;

  final bool barrierDismissible;

  @override
  Route<T> createRoute(BuildContext context) {
    return buildCustomRoute(context, this);
  }
}

/// Navigator 2.0
class DefaultPageRoute2<T> extends PageRoute<T> {
  DefaultPageRoute2({
    required CustomPage<T> page,
    this.pageTransitionsBuilder,
  }) : super(settings: page);
  final PageTransitionsBuilder? pageTransitionsBuilder;

  CustomPage<T> get _page => settings as CustomPage<T>;

  Widget buildContent(BuildContext context) {
    return _page.child;
  }

  @override
  ui.ImageFilter? get filter => _page.filter;

  @override
  bool get opaque => _page.opaque;

  @override
  Color? get barrierColor => _page.barrierColor;

  @override
  String? get barrierLabel => _page.barrierLabel;

  @override
  bool get barrierDismissible => _page.barrierDismissible;

  @override
  bool get semanticsDismissible => _page.semanticsDismissible;

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';

  @override
  Duration get transitionDuration => _page.transitionDuration;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final Widget result = buildContent(context);
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: result,
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    if (pageTransitionsBuilder == null) {
      return child;
    }
    return pageTransitionsBuilder!.buildTransitions<T>(this, context, animation, secondaryAnimation, child);
  }
}

mixin CustomRouteTransitionMixin<T> on PageRoute<T> {
  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    // Don't perform outgoing animation if the next route is a fullscreen dialog.
    return (nextRoute is CustomRouteTransitionMixin && !nextRoute.fullscreenDialog) || (nextRoute is CupertinoRouteTransitionMixin && !nextRoute.fullscreenDialog);
  }
}

class PageBasedCustomPageRoute = DefaultPageRoute2 with CustomRouteTransitionMixin;

class CupertinoModalPopupRoute2 = DefaultPageRoute2 with CupertinoModalPopupRouteMixin;

mixin CupertinoModalPopupRouteMixin<T> on PageRoute<T> {
  Animation<double>? _animation;

  late Tween<Offset> _offsetTween;

  Widget buildContent(BuildContext context);

  @override
  Animation<double> createAnimation() {
    assert(_animation == null);
    _animation = CurvedAnimation(
      parent: super.createAnimation(),

      // These curves were initially measured from native iOS horizontal page
      // route animations and seemed to be a good match here as well.
      curve: Curves.linearToEaseOut,
      reverseCurve: Curves.linearToEaseOut.flipped,
    );
    _offsetTween = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    );
    return _animation!;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return CupertinoUserInterfaceLevel(
      data: CupertinoUserInterfaceLevelData.elevated,
      child: Builder(builder: buildContent),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionalTranslation(
        translation: _offsetTween.evaluate(_animation!),
        child: child,
      ),
    );
  }
}

/// if run web, this transition will be default.
class NoTransitionBuilder extends PageTransitionsBuilder {
  const NoTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
