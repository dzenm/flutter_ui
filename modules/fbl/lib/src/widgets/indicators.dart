import 'dart:math';

import 'package:flutter/material.dart';

import 'tap.dart';

///
/// Created by a0010 on 2024/12/30 15:58
/// 指示器的通用组件
///

/// An indicator showing the currently selected page of a PageController
class DotsIndicator extends AnimatedWidget {
  const DotsIndicator({
    super.key,
    required this.controller,
    this.itemCount = 0,
    required this.onPageSelected,
    this.color = Colors.white,
    this.dotsType = DotsType.dot,
    this.size = 8,
    this.icons,
  }) : super(listenable: controller);

  /// The PageController that this DotsIndicator is representing.
  final PageController controller;

  /// The number of items managed by the PageController
  final int itemCount;

  /// Called when a dot is tapped
  final ValueChanged<int> onPageSelected;

  /// The color of the dots.
  /// Defaults to `Colors.white`.
  final Color color;

  /// Dots展示的布局样式 @see [DotsType]
  final DotsType dotsType;

  /// Dots布局的大小
  final double size;

  /// 展示Dots的图标
  final List<Widget>? icons;

  @override
  Widget build(BuildContext context) {
    double page = controller.hasClients ? controller.page ?? 0 : 0;
    int selectedIndex = page.round();
    switch (dotsType) {
      case DotsType.dot:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(itemCount, (index) => _buildDot(index == selectedIndex)),
        );
      case DotsType.text:
        return _buildText(selectedIndex + 1);
      case DotsType.icon:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List<Widget>.generate(itemCount, (index) => _buildIconTitle(index, selectedIndex)),
        );
    }
  }

  Widget _buildDot(bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Colors.grey : Colors.white,
          border: Border.all(color: Colors.grey, width: 1),
        ),
      ),
    );
  }

  Widget _buildText(int index) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 3, bottom: 3),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
        color: Colors.grey.withOpacity(0.7),
      ),
      child: Text('$index / $itemCount', style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _buildIconTitle(int index, int selectedIndex) {
    bool isSelected = index == selectedIndex;
    return TapLayout(
      width: 36,
      height: 36,
      foreground: Colors.transparent,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(4),
      borderRadius: BorderRadius.circular(4),
      background: isSelected ? Colors.grey.shade300 : null,
      onTap: () => onPageSelected(index),
      child: icons![index],
    );
  }
}

/// 图标展示的样式
enum DotsType {
  dot,
  text,
  icon;
}

///
/// Created by a0010 on 2024/12/26 13:20
/// 风车指示器
/// 示例：
/// WindmillIndicator(
///   size: 40.0,
///   speed: 0.5,
///   direction: RotationDirection.clockwise,
/// )
class WindmillIndicator extends StatefulWidget {
  final double size;
  final double speed; // 旋转速度，默认：1转/秒
  final RotationDirection direction;

  const WindmillIndicator({
    super.key,
    this.size = 50.0,
    this.speed = 1.0,
    this.direction = RotationDirection.clockwise,
  })  : assert(speed > 0),
        assert(size > 0);

  @override
  State<WindmillIndicator> createState() => _WindmillIndicatorState();
}

class _WindmillIndicatorState extends State<WindmillIndicator> //
    with
        SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    int milliseconds = 1000 ~/ widget.speed;
    _controller = AnimationController(duration: Duration(milliseconds: milliseconds), vsync: this);
    _animation = Tween<double>(begin: 0, end: 1.0).animate(_controller)..addListener(_animatorListener);

    _controller.repeat();
  }

  void _animatorListener() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedWindmill(
      animation: _animation,
      size: widget.size,
      direction: widget.direction,
    );
  }

  @override
  void dispose() {
    if (![AnimationStatus.completed, AnimationStatus.dismissed].contains(_controller.status)) {
      _controller.stop();
    }
    _animation.removeListener(_animatorListener);
    _controller.dispose();
    super.dispose();
  }
}

class AnimatedWindmill extends AnimatedWidget {
  final double size;
  final RotationDirection direction;

  const AnimatedWindmill({
    super.key,
    required Animation<double> animation,
    required this.direction,
    this.size = 50.0,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;

    final rotationAngle = direction == RotationDirection.clockwise //
        ? 2 * pi * animation.value
        : -2 * pi * animation.value;
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        WindmillWing(
          size: size,
          color: Colors.blue,
          angle: 0 + rotationAngle,
        ),
        WindmillWing(
          size: size,
          color: Colors.yellow,
          angle: pi / 2 + rotationAngle,
        ),
        WindmillWing(
          size: size,
          color: Colors.green,
          angle: pi + rotationAngle,
        ),
        WindmillWing(
          size: size,
          color: Colors.red,
          angle: -pi / 2 + rotationAngle,
        ),
      ],
    );
  }
}

class WindmillWing extends StatelessWidget {
  final double size;
  final Color color;
  final double angle;

  const WindmillWing({
    super.key,
    required this.size,
    required this.color,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      transformAlignment: Alignment.bottomCenter,
      transform: Matrix4.translationValues(0, -size / 2, 0)..rotateZ(angle),
      child: ClipPath(
        clipper: WindWillClipPath(),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          color: color,
        ),
      ),
    );
  }
}

class WindWillClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path()
      ..moveTo(size.width / 3, size.height)
      ..arcToPoint(
        Offset(0, size.height * 2 / 3),
        radius: Radius.circular(size.width / 2),
      )
      ..arcToPoint(
        Offset(size.width, 0),
        radius: Radius.circular(size.width),
      )
      ..lineTo(size.width / 3, size.height);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

enum RotationDirection {
  clockwise,
  antiClockwise,
}

/// 线性百分比进度加载指示器
class LinearPercentIndicator extends StatefulWidget {
  ///Percent value between 0.0 and 1.0
  final double percent;
  final double? width;

  ///Height of the line
  final double lineHeight;

  ///Color of the background of the Line , default = transparent
  final Color fillColor;

  ///First color applied to the complete line
  final Color backgroundColor;

  ///Progress color applied to the progress line
  final Color? progressColor;

  ///true if you want the Line to have animation
  final bool animation;

  ///duration of the animation in milliseconds, It only applies if animation attribute is true
  final int animationDuration;

  ///widget at the left of the Line
  final Widget? leading;

  ///widget at the right of the Line
  final Widget? trailing;

  ///widget inside the Line
  final Widget? center;

  ///The kind of finish to place on the end of lines drawn, values supported: butt, round, roundAll
  final LinearStrokeCap? linearStrokeCap;

  ///alignment of the Row (leading-widget-center-trailing)
  final MainAxisAlignment alignment;

  ///padding to the LinearPercentIndicator
  final EdgeInsets padding;

  /// set true if you want to animate the linear from the last percent value you set
  final bool animateFromLastPercent;

  /// If present, this will make the progress bar colored by this gradient.
  ///
  /// This will override [progressColor]. It is an error to provide both.
  final LinearGradient? linearGradient;

  /// set false if you don't want to preserve the state of the widget
  final bool addAutomaticKeepAlive;

  /// set true if you want to animate the linear from the right to left (RTL)
  final bool isRTL;

  /// Creates a mask filter that takes the progress shape being drawn and blurs it.
  final MaskFilter? maskFilter;

  /// Set true if you want to display only part of [linearGradient] based on percent value
  /// (ie. create 'VU effect'). If no [linearGradient] is specified this option is ignored.
  final bool clipLinearGradient;

  /// set a linear curve animation type
  final Curve curve;

  /// set true when you want to restart the animation, it restarts only when reaches 1.0 as a value
  /// defaults to false
  final bool restartAnimation;

  LinearPercentIndicator(
      {super.key,
      this.fillColor = Colors.transparent,
      this.percent = 0.0,
      this.lineHeight = 5.0,
      this.width,
      this.backgroundColor = const Color(0xFFB8C7CB),
      this.linearGradient,
      this.progressColor = Colors.red,
      this.animation = false,
      this.animationDuration = 500,
      this.animateFromLastPercent = false,
      this.isRTL = false,
      this.leading,
      this.trailing,
      this.center,
      this.addAutomaticKeepAlive = true,
      this.linearStrokeCap,
      this.padding = const EdgeInsets.symmetric(horizontal: 10.0),
      this.alignment = MainAxisAlignment.start,
      this.maskFilter,
      this.clipLinearGradient = false,
      this.curve = Curves.linear,
      this.restartAnimation = false}) {
    if (linearGradient != null) {
      throw ArgumentError('Cannot provide both linearGradient and progressColor');
    }

    if (percent < 0.0 || percent > 1.0) {
      throw Exception("Percent value must be a double between 0.0 and 1.0");
    }
  }

  @override
  State<StatefulWidget> createState() => _LinearPercentIndicatorState();
}

class _LinearPercentIndicatorState extends State<LinearPercentIndicator> //
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin {
  AnimationController? _animationController;
  Animation? _animation;
  double _percent = 0.0;

  @override
  void dispose() {
    if (_animationController != null) {
      _animationController?.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    if (widget.animation) {
      _animationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: widget.animationDuration),
      );
      _animation = Tween(begin: 0.0, end: widget.percent).animate(
        CurvedAnimation(parent: _animationController!, curve: widget.curve),
      )..addListener(() {
          setState(() {
            _percent = _animation?.value;
          });
          if (widget.restartAnimation && _percent == 1.0) {
            _animationController?.repeat(min: 0, max: 1.0);
          }
        });
      _animationController?.forward();
    } else {
      _updateProgress();
    }
    super.initState();
  }

  @override
  void didUpdateWidget(LinearPercentIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percent != widget.percent) {
      if (_animationController != null) {
        _animationController?.duration = Duration(milliseconds: widget.animationDuration);
        _animation = Tween(
          begin: widget.animateFromLastPercent ? oldWidget.percent : 0.0,
          end: widget.percent,
        ).animate(
          CurvedAnimation(parent: _animationController!, curve: widget.curve),
        );
        _animationController?.forward(from: 0.0);
      } else {
        _updateProgress();
      }
    }
  }

  _updateProgress() {
    setState(() {
      _percent = widget.percent;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var items = <Widget>[];
    if (widget.leading != null) {
      items.add(widget.leading!);
    }
    final hasSetWidth = widget.width != null;
    var containerWidget = Container(
      width: hasSetWidth ? widget.width : double.infinity,
      height: widget.lineHeight,
      padding: widget.padding,
      child: CustomPaint(
        painter: LinearPainter(
          isRTL: widget.isRTL,
          progress: _percent,
          center: widget.center,
          progressColor: widget.progressColor!,
          linearGradient: widget.linearGradient,
          backgroundColor: widget.backgroundColor,
          linearStrokeCap: widget.linearStrokeCap,
          lineWidth: widget.lineHeight,
          maskFilter: widget.maskFilter,
          clipLinearGradient: widget.clipLinearGradient,
        ),
        child: (widget.center != null) ? Center(child: widget.center) : const SizedBox.shrink(),
      ),
    );

    if (hasSetWidth) {
      items.add(containerWidget);
    } else {
      items.add(Expanded(
        child: containerWidget,
      ));
    }
    if (widget.trailing != null) {
      items.add(widget.trailing!);
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        color: widget.fillColor,
        child: Row(
          mainAxisAlignment: widget.alignment,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: items,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => widget.addAutomaticKeepAlive;
}

class LinearPainter extends CustomPainter {
  final Paint _paintBackground = Paint();
  final Paint _paintLine = Paint();
  final double lineWidth;
  final double progress;
  final Widget? center;
  final bool isRTL;
  final Color progressColor;
  final Color backgroundColor;
  final LinearStrokeCap? linearStrokeCap;
  final LinearGradient? linearGradient;
  final MaskFilter? maskFilter;
  final bool clipLinearGradient;

  LinearPainter({
    this.lineWidth = 0,
    this.progress = 0,
    this.center,
    this.isRTL = false,
    required this.progressColor,
    required this.backgroundColor,
    this.linearStrokeCap = LinearStrokeCap.butt,
    this.linearGradient,
    this.maskFilter,
    this.clipLinearGradient = false,
  }) {
    _paintBackground.color = backgroundColor;
    _paintBackground.style = PaintingStyle.stroke;
    _paintBackground.strokeWidth = lineWidth;

    _paintLine.color = progress.toString() == "0.0" ? progressColor.withOpacity(0.0) : progressColor;
    _paintLine.style = PaintingStyle.stroke;
    _paintLine.strokeWidth = lineWidth;

    if (linearStrokeCap == LinearStrokeCap.round) {
      _paintLine.strokeCap = StrokeCap.round;
    } else if (linearStrokeCap == LinearStrokeCap.butt) {
      _paintLine.strokeCap = StrokeCap.butt;
    } else {
      _paintLine.strokeCap = StrokeCap.round;
      _paintBackground.strokeCap = StrokeCap.round;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final start = Offset(0.0, size.height / 2);
    final end = Offset(size.width, size.height / 2);
    canvas.drawLine(start, end, _paintBackground);

    if (maskFilter != null) {
      _paintLine.maskFilter = maskFilter;
    }

    if (isRTL) {
      final xProgress = size.width - size.width * progress;
      if (linearGradient != null) {
        _paintLine.shader = _createGradientShaderRightToLeft(size, xProgress);
      }
      canvas.drawLine(end, Offset(xProgress, size.height / 2), _paintLine);
    } else {
      final xProgress = size.width * progress;
      if (linearGradient != null) {
        _paintLine.shader = _createGradientShaderLeftToRight(size, xProgress);
      }
      canvas.drawLine(start, Offset(xProgress, size.height / 2), _paintLine);
    }
  }

  Shader? _createGradientShaderRightToLeft(Size size, double xProgress) {
    Offset shaderEndPoint = clipLinearGradient ? Offset.zero : Offset(xProgress, size.height);
    return linearGradient?.createShader(
      Rect.fromPoints(Offset(size.width, size.height), shaderEndPoint),
    );
  }

  Shader? _createGradientShaderLeftToRight(Size size, double xProgress) {
    Offset shaderEndPoint = clipLinearGradient ? Offset(size.width, size.height) : Offset(xProgress, size.height);
    return linearGradient?.createShader(
      Rect.fromPoints(Offset.zero, shaderEndPoint),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

enum LinearStrokeCap { butt, round, roundAll }

/// 圆形百分比进度加载指示器
class CircularPercentIndicator extends StatefulWidget {
  ///Percent value between 0.0 and 1.0
  final double percent;

  final double radius;

  ///Width of the progress bar of the circle
  final double lineWidth;

  ///Width of the unfilled background of the progress bar
  final double backgroundWidth;

  ///Color of the background of the circle , default = transparent
  final Color fillColor;

  ///First color applied to the complete circle
  final Color backgroundColor;

  ///Progress Color
  final Color progressColor;

  ///true if you want the circle to have animation
  final bool animation;

  ///duration of the animation in milliseconds, It only applies if animation attribute is true
  final int animationDuration;

  ///widget at the top of the circle
  final Widget? header;

  ///widget at the bottom of the circle
  final Widget? footer;

  ///widget inside the circle
  final Widget? center;

  final LinearGradient? linearGradient;

  ///The kind of finish to place on the end of lines drawn, values supported: butt, round, square
  final CircularStrokeCap? circularStrokeCap;

  ///the angle which the circle will start the progress (in degrees, eg: 0.0, 45.0, 90.0)
  final double startAngle;

  /// set true if you want to animate the linear from the last percent value you set
  final bool animateFromLastPercent;

  /// set false if you don't want to preserve the state of the widget
  final bool addAutomaticKeepAlive;

  /// set the arc type
  final ArcType? arcType;

  /// set a circular background color when use the arcType property
  final Color? arcBackgroundColor;

  /// set true when you want to display the progress in reverse mode
  final bool reverse;

  /// Creates a mask filter that takes the progress shape being drawn and blurs it.
  final MaskFilter? maskFilter;

  /// set a circular curve animation type
  final Curve curve;

  /// set true when you want to restart the animation, it restarts only when reaches 1.0 as a value
  /// defaults to false
  final bool restartAnimation;

  const CircularPercentIndicator(
      {super.key,
      this.percent = 0.0,
      this.lineWidth = 5.0,
      this.startAngle = 0.0,
      required this.radius,
      this.fillColor = Colors.transparent,
      this.backgroundColor = const Color(0xFFB8C7CB),
      Color? progressColor,
      this.backgroundWidth = -1, //negative values ignored, replaced with lineWidth
      this.linearGradient,
      this.animation = false,
      this.animationDuration = 500,
      this.header,
      this.footer,
      this.center,
      this.addAutomaticKeepAlive = true,
      this.circularStrokeCap,
      this.arcBackgroundColor,
      this.arcType,
      this.animateFromLastPercent = false,
      this.reverse = false,
      this.curve = Curves.linear,
      this.maskFilter,
      this.restartAnimation = false})
      : assert(
          linearGradient == null || progressColor == null,
          'Cannot provide both linearGradient and progressColor',
        ),
        assert(
          0.0 <= startAngle && startAngle <= 1.0,
          'Percent value must be a double between 0.0 and 1.0',
        ),
        assert(
          arcBackgroundColor == null || arcType != null,
          'arcType is required when you arcBackgroundColor',
        ),
        progressColor = progressColor ?? Colors.red;

  @override
  State<CircularPercentIndicator> createState() => _CircularPercentIndicatorState();
}

class _CircularPercentIndicatorState extends State<CircularPercentIndicator> //
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin {
  AnimationController? _animationController;
  Animation? _animation;
  double _percent = 0.0;

  @override
  void dispose() {
    if (_animationController != null) {
      _animationController?.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    if (widget.animation) {
      _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: widget.animationDuration));
      _animation = Tween(begin: 0.0, end: widget.percent).animate(
        CurvedAnimation(parent: _animationController!, curve: widget.curve),
      )..addListener(() {
          setState(() {
            _percent = _animation!.value;
          });
          if (widget.restartAnimation && _percent == 1.0) {
            _animationController!.repeat(min: 0, max: 1.0);
          }
        });
      _animationController!.forward();
    } else {
      _updateProgress();
    }
    super.initState();
  }

  @override
  void didUpdateWidget(CircularPercentIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percent != widget.percent || oldWidget.startAngle != widget.startAngle) {
      if (_animationController != null) {
        _animationController!.duration = Duration(milliseconds: widget.animationDuration);
        _animation = Tween(begin: widget.animateFromLastPercent ? oldWidget.percent : 0.0, end: widget.percent).animate(
          CurvedAnimation(parent: _animationController!, curve: widget.curve),
        );
        _animationController!.forward(from: 0.0);
      } else {
        _updateProgress();
      }
    }
  }

  _updateProgress() {
    setState(() {
      _percent = widget.percent;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var items = <Widget>[];
    if (widget.header != null) {
      items.add(widget.header!);
    }
    items.add(Container(
        height: widget.radius + widget.lineWidth,
        width: widget.radius,
        child: CustomPaint(
          painter: CirclePainter(
              progress: _percent * 360,
              progressColor: widget.progressColor,
              backgroundColor: widget.backgroundColor,
              startAngle: widget.startAngle,
              circularStrokeCap: widget.circularStrokeCap,
              radius: (widget.radius / 2) - widget.lineWidth / 2,
              lineWidth: widget.lineWidth,
              backgroundWidth: //negative values ignored, replaced with lineWidth
                  widget.backgroundWidth >= 0.0 ? (widget.backgroundWidth) : widget.lineWidth,
              arcBackgroundColor: widget.arcBackgroundColor,
              arcType: widget.arcType,
              reverse: widget.reverse,
              linearGradient: widget.linearGradient,
              maskFilter: widget.maskFilter),
          child: (widget.center != null) ? Center(child: widget.center) : Container(),
        )));

    if (widget.footer != null) {
      items.add(widget.footer!);
    }

    return Material(
      color: widget.fillColor,
      child: Container(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: items,
      )),
    );
  }

  @override
  bool get wantKeepAlive => widget.addAutomaticKeepAlive;
}

class CirclePainter extends CustomPainter {
  final Paint _paintBackground = Paint();
  final Paint _paintLine = Paint();
  final Paint _paintBackgroundStartAngle = Paint();
  final double lineWidth;
  final double backgroundWidth;
  final double progress;
  final double radius;
  final Color progressColor;
  final Color backgroundColor;
  final CircularStrokeCap? circularStrokeCap;
  final double startAngle;
  final LinearGradient? linearGradient;
  final Color? arcBackgroundColor;
  final ArcType? arcType;
  final bool reverse;
  final MaskFilter? maskFilter;

  CirclePainter(
      {required this.lineWidth,
      required this.backgroundWidth,
      required this.progress,
      required this.radius,
      required this.progressColor,
      required this.backgroundColor,
      this.startAngle = 0.0,
      this.circularStrokeCap = CircularStrokeCap.round,
      this.linearGradient,
      required this.reverse,
      this.arcBackgroundColor,
      this.arcType,
      this.maskFilter}) {
    _paintBackground.color = backgroundColor;
    _paintBackground.style = PaintingStyle.stroke;
    _paintBackground.strokeWidth = backgroundWidth;

    if (arcBackgroundColor != null) {
      _paintBackgroundStartAngle.color = arcBackgroundColor!;
      _paintBackgroundStartAngle.style = PaintingStyle.stroke;
      _paintBackgroundStartAngle.strokeWidth = lineWidth;
      if (circularStrokeCap == CircularStrokeCap.round) {
        _paintBackgroundStartAngle.strokeCap = StrokeCap.round;
      } else if (circularStrokeCap == CircularStrokeCap.butt) {
        _paintBackgroundStartAngle.strokeCap = StrokeCap.butt;
      } else {
        _paintBackgroundStartAngle.strokeCap = StrokeCap.square;
      }
    }

    _paintLine.color = progressColor;
    _paintLine.style = PaintingStyle.stroke;
    _paintLine.strokeWidth = lineWidth;
    if (circularStrokeCap == CircularStrokeCap.round) {
      _paintLine.strokeCap = StrokeCap.round;
    } else if (circularStrokeCap == CircularStrokeCap.butt) {
      _paintLine.strokeCap = StrokeCap.butt;
    } else {
      _paintLine.strokeCap = StrokeCap.square;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius, _paintBackground);

    if (maskFilter != null) {
      _paintLine.maskFilter = maskFilter;
    }
    if (linearGradient != null) {
      _paintLine.shader = linearGradient!.createShader(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
      );
    }

    double fixedStartAngle = startAngle;

    double startAngleFixedMargin = 1.0;
    if (arcType != null) {
      if (arcType == ArcType.FULL) {
        fixedStartAngle = 220;
        startAngleFixedMargin = 172 / fixedStartAngle;
      } else {
        fixedStartAngle = 270;
        startAngleFixedMargin = 135 / fixedStartAngle;
      }
    }

    if (arcBackgroundColor != null) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        radians(-90.0 + fixedStartAngle),
        radians(360 * startAngleFixedMargin),
        false,
        _paintBackgroundStartAngle,
      );
    }

    if (reverse) {
      final start = radians(360 * startAngleFixedMargin - 90.0 + fixedStartAngle);
      final end = radians(-progress * startAngleFixedMargin);
      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
        start,
        end,
        false,
        _paintLine,
      );
    } else {
      final start = radians(-90.0 + fixedStartAngle);
      final end = radians(progress * startAngleFixedMargin);
      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
        start,
        end,
        false,
        _paintLine,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  double radians(double deg) => deg * (pi / 180.0);
}

enum ArcType {
  HALF,
  FULL,
}

enum CircularStrokeCap { butt, round, square }
