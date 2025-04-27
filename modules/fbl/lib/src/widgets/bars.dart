import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tap.dart';

///
/// Created by a0010 on 2024/12/30 15:58
/// AppBar，BottomBar的通用组件
///

class Item {
  int index;
  String? title;
  IconData? icon;
  bool selected;

  Item(this.index, {this.title, this.icon, this.selected = true});
}

/// AppBar封装
class CommonBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Color? titleColor;
  final bool? centerTitle;
  final String? subTitle;
  final Color? subTitleColor;
  final Color? backgroundColor;
  final bool showLeading;
  final Widget? leading;
  final Function? onBackTap;
  final double? elevation;
  final double toolbarHeight;
  final PreferredSizeWidget? bottom;
  final SystemUiOverlayStyle systemOverlayStyle;
  final List<Widget>? actions;
  final double? titleSpacing;

  const CommonBar({
    super.key,
    this.title,
    this.titleColor = Colors.white,
    this.centerTitle = true,
    this.subTitle,
    this.subTitleColor,
    this.backgroundColor,
    this.showLeading = true,
    this.leading,
    this.onBackTap,
    this.elevation = 0.0,
    this.toolbarHeight = kToolbarHeight,
    this.bottom,
    this.systemOverlayStyle = SystemUiOverlayStyle.light,
    this.actions,
    this.titleSpacing = NavigationToolbar.kMiddleSpacing,
  });

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: titleSpacing,
      leading: _buildLeading(
        context,
        leading: leading,
        onBackTap: onBackTap,
      ),
      backgroundColor: backgroundColor,
      foregroundColor: titleColor,
      bottom: bottom,
      title: Text.rich(
        TextSpan(
          text: title,
          children: [
            TextSpan(
              text: subTitle ?? '',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      titleTextStyle: TextStyle(
        fontSize: 18.0,
        color: titleColor,
        fontWeight: FontWeight.bold,
      ),
      centerTitle: centerTitle,
      elevation: elevation,
      toolbarHeight: toolbarHeight,
      systemOverlayStyle: systemOverlayStyle,
      actions: actions,
    );
  }

  Widget? _buildLeading(
    BuildContext context,{
    Widget? leading,
    Function? onBackTap,
  }) {
    if (showLeading) return null;
    return TapLayout(
      width: 40,
      height: 40,
      isCircle: true,
      padding: const EdgeInsets.only(left: 12),
      child: leading ?? const BackButtonIcon(),
      onTap: () {
        if (onBackTap == null) {
          Navigator.pop(context);
        } else {
          onBackTap();
        }
      },
    );
  }

// Widget _buildToolbar(BuildContext context) {
//   return Semantics(
//     container: true,
//     child: AnnotatedRegion<SystemUiOverlayStyle>(
//       value: systemOverlayStyle,
//       child: Material(
//         color: backgroundColor,
//         child: Semantics(
//           explicitChildNodes: true,
//           child: Container(
//             color: backgroundColor,
//             child: Column(children: [
//               Container(height: 24, color: backgroundColor),
//               Container(
//                 height: kToolbarHeight,
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: Row(children: [
//                   TapLayout(
//                     isCircle: true,
//                     width: 40,
//                     height: 40,
//                     onTap: () {
//                       if (Navigator.canPop(context)) {
//                         Navigator.pop(context);
//                       }
//                     },
//                     child: BackButton(),
//                   ),
//                   const SizedBox(width: 32),
//                   Expanded(
//                     flex: 1,
//                     child: Row(mainAxisAlignment: centerTitle ?? false ? MainAxisAlignment.center : MainAxisAlignment.start, children: [
//                       Text.rich(
//                         TextSpan(text: title, children: [
//                           TextSpan(
//                             text: subTitle ?? '',
//                             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
//                           ),
//                         ]),
//                       ),
//                     ]),
//                   ),
//                   const SizedBox(width: 32),
//                 ]),
//               )
//             ]),
//           ),
//         ),
//       ),
//     ),
//   );
// }
}

const double _kMaxTitleTextScaleFactor = 1.34;

/// 自定义AppBar
class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final Widget? title;
  final Color backgroundColor;
  final Color? foregroundColor;
  final List<Widget>? actions;
  final double elevation;
  final double? toolbarHeight;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;
  @override
  final Size preferredSize;
  final SystemUiOverlayStyle? systemOverlayStyle;

  TopBar({
    super.key,
    this.leading,
    this.title,
    this.backgroundColor = Colors.white,
    this.foregroundColor,
    this.actions,
    this.elevation = 0,
    this.toolbarHeight,
    this.bottom,
    this.centerTitle = false,
    this.systemOverlayStyle,
  })  : assert(elevation >= 0.0),
        preferredSize = _PreferredAppBarSize(toolbarHeight, bottom?.preferredSize.height);

  static double preferredHeightFor(BuildContext context, Size preferredSize) {
    if (preferredSize is _PreferredAppBarSize && preferredSize.toolbarHeight == null) {
      return (AppBarTheme.of(context).toolbarHeight ?? kToolbarHeight) + (preferredSize.bottomHeight ?? 0);
    }
    return preferredSize.height;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final IconButtonThemeData iconButtonTheme = IconButtonTheme.of(context);
    final AppBarTheme appBarTheme = AppBarTheme.of(context);
    final AppBarTheme defaults = _AppBarDefaultsM2(context);
    final ScaffoldState? scaffold = Scaffold.maybeOf(context);

    final FlexibleSpaceBarSettings? settings = context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    final Set<WidgetState> states = <WidgetState>{
      if (settings?.isScrolledUnder ?? false) WidgetState.scrolledUnder,
    };

    final bool hasEndDrawer = scaffold?.hasEndDrawer ?? false;
    final double toolbarHeight = this.toolbarHeight ?? appBarTheme.toolbarHeight ?? kToolbarHeight;

    final Color backgroundColor = _resolveColor(
      states,
      this.backgroundColor,
      appBarTheme.backgroundColor,
      defaults.backgroundColor!,
    );

    final Color foregroundColor = this.foregroundColor ?? appBarTheme.foregroundColor ?? defaults.foregroundColor!;

    final double elevation = this.elevation;

    final double effectiveElevation = states.contains(WidgetState.scrolledUnder) ? appBarTheme.scrolledUnderElevation ?? defaults.scrolledUnderElevation ?? elevation : elevation;

    IconThemeData overallIconTheme = appBarTheme.iconTheme ?? defaults.iconTheme!.copyWith(color: foregroundColor);

    final Color? actionForegroundColor = this.foregroundColor ?? appBarTheme.foregroundColor;
    IconThemeData actionsIconTheme = appBarTheme.actionsIconTheme ?? appBarTheme.iconTheme ?? defaults.actionsIconTheme?.copyWith(color: actionForegroundColor) ?? overallIconTheme;

    TextStyle? toolbarTextStyle = appBarTheme.toolbarTextStyle ?? defaults.toolbarTextStyle?.copyWith(color: foregroundColor);

    TextStyle? titleTextStyle = appBarTheme.titleTextStyle ?? defaults.titleTextStyle?.copyWith(color: foregroundColor);

    Widget? title = this.title;

    if (title != null) {
      title = Semantics(
        namesRoute: switch (theme.platform) {
          TargetPlatform.android || TargetPlatform.fuchsia || TargetPlatform.linux || TargetPlatform.windows => true,
          TargetPlatform.iOS || TargetPlatform.macOS => null,
        },
        header: true,
        child: title,
      );

      title = DefaultTextStyle(
        style: titleTextStyle!,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        child: title,
      );

      title = MediaQuery.withClampedTextScaling(
        maxScaleFactor: _kMaxTitleTextScaleFactor,
        child: title,
      );
    }
    Widget? actions;
    if (this.actions != null && this.actions!.isNotEmpty) {
      actions = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: theme.useMaterial3 ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
        children: this.actions!,
      );
    } else if (hasEndDrawer) {
      actions = EndDrawerButton(
        style: IconButton.styleFrom(iconSize: overallIconTheme.size ?? 24),
      );
    }

    // Allow the trailing actions to have their own theme if necessary.
    if (actions != null) {
      final IconButtonThemeData effectiveActionsIconButtonTheme;
      if (actionsIconTheme == defaults.actionsIconTheme) {
        effectiveActionsIconButtonTheme = iconButtonTheme;
      } else {
        final ButtonStyle actionsIconButtonStyle = IconButton.styleFrom(
          foregroundColor: actionsIconTheme.color,
          iconSize: actionsIconTheme.size,
        );

        effectiveActionsIconButtonTheme = IconButtonThemeData(
            style: iconButtonTheme.style?.copyWith(
              foregroundColor: actionsIconButtonStyle.foregroundColor,
              overlayColor: actionsIconButtonStyle.overlayColor,
              iconSize: actionsIconButtonStyle.iconSize,
            ));
      }

      actions = IconButtonTheme(
        data: effectiveActionsIconButtonTheme,
        child: IconTheme.merge(
          data: actionsIconTheme,
          child: actions,
        ),
      );
    }

    final Widget toolbar = NavigationToolbar(
      leading: leading,
      middle: title,
      trailing: actions,
      centerMiddle: centerTitle,
      middleSpacing: appBarTheme.titleSpacing ?? NavigationToolbar.kMiddleSpacing,
    );

    // If the toolbar is allocated less than toolbarHeight make it
    // appear to scroll upwards within its shrinking container.
    Widget appBar = ClipRect(
      clipBehavior: Clip.hardEdge,
      child: CustomSingleChildLayout(
        delegate: _ToolbarContainerLayout(toolbarHeight),
        child: IconTheme.merge(
          data: overallIconTheme,
          child: DefaultTextStyle(
            style: toolbarTextStyle!,
            child: toolbar,
          ),
        ),
      ),
    );
    if (bottom != null) {
      appBar = Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: toolbarHeight),
              child: appBar,
            ),
          ),
          Opacity(
            opacity: const Interval(0.25, 1.0, curve: Curves.fastOutSlowIn).transform(1.0),
            child: bottom,
          ),
        ],
      );
    }

    appBar = Align(
      alignment: Alignment.topCenter,
      child: appBar,
    );

    final SystemUiOverlayStyle overlayStyle = systemOverlayStyle ??
        appBarTheme.systemOverlayStyle ??
        defaults.systemOverlayStyle ??
        _systemOverlayStyleForBrightness(
          ThemeData.estimateBrightnessForColor(backgroundColor),
          // Make the status bar transparent for M3 so the elevation overlay
          // color is picked up by the statusbar.
          theme.useMaterial3 ? const Color(0x00000000) : null,
        );

    return Semantics(
      container: true,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle,
        child: Material(
          color: backgroundColor,
          elevation: effectiveElevation,
          type: MaterialType.canvas,
          shadowColor: appBarTheme.shadowColor ?? defaults.shadowColor,
          surfaceTintColor: appBarTheme.surfaceTintColor ?? defaults.surfaceTintColor,
          shape: appBarTheme.shape ?? defaults.shape,
          child: Semantics(
            explicitChildNodes: true,
            child: appBar,
          ),
        ),
      ),
    );
  }

  Color _resolveColor(Set<WidgetState> states, Color? widgetColor, Color? themeColor, Color defaultColor) {
    return WidgetStateProperty.resolveAs<Color?>(widgetColor, states) ?? WidgetStateProperty.resolveAs<Color?>(themeColor, states) ?? WidgetStateProperty.resolveAs<Color>(defaultColor, states);
  }

  SystemUiOverlayStyle _systemOverlayStyleForBrightness(Brightness brightness, [Color? backgroundColor]) {
    final SystemUiOverlayStyle style = brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
    // For backward compatibility, create an overlay style without system navigation bar settings.
    return SystemUiOverlayStyle(
      statusBarColor: backgroundColor,
      statusBarBrightness: style.statusBarBrightness,
      statusBarIconBrightness: style.statusBarIconBrightness,
      systemStatusBarContrastEnforced: style.systemStatusBarContrastEnforced,
    );
  }
}

class _ToolbarContainerLayout extends SingleChildLayoutDelegate {
  const _ToolbarContainerLayout(this.toolbarHeight);

  final double toolbarHeight;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return constraints.tighten(height: toolbarHeight);
  }

  @override
  Size getSize(BoxConstraints constraints) {
    return Size(constraints.maxWidth, toolbarHeight);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - childSize.height);
  }

  @override
  bool shouldRelayout(_ToolbarContainerLayout oldDelegate) => toolbarHeight != oldDelegate.toolbarHeight;
}

class _AppBarDefaultsM2 extends AppBarTheme {
  _AppBarDefaultsM2(this.context)
      : super(
    elevation: 4.0,
    shadowColor: const Color(0xFF000000),
    titleSpacing: NavigationToolbar.kMiddleSpacing,
    toolbarHeight: kToolbarHeight,
  );

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;

  @override
  Color? get backgroundColor => _colors.brightness == Brightness.dark ? _colors.surface : _colors.primary;

  @override
  Color? get foregroundColor => _colors.brightness == Brightness.dark ? _colors.onSurface : _colors.onPrimary;

  @override
  IconThemeData? get iconTheme => _theme.iconTheme;

  @override
  TextStyle? get toolbarTextStyle => _theme.textTheme.bodyMedium;

  @override
  TextStyle? get titleTextStyle => _theme.textTheme.titleLarge;
}

class _PreferredAppBarSize extends Size {
  _PreferredAppBarSize(this.toolbarHeight, this.bottomHeight)
      : super.fromHeight(
    (toolbarHeight ?? kToolbarHeight) + (bottomHeight ?? 0),
  );

  final double? toolbarHeight;
  final double? bottomHeight;
}

/// 浮动的BottomNavigationBar
/// 用法：
/// class FloatNavigationPage extends StatefulWidget {
//   @override
//   _FloatNavigationPageState createState() => _FloatNavigationPageState();
// }
//
// class _FloatNavigationPageState extends State<FloatNavigationPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0.0,
//         title: Text('Float Navigation'),
//         centerTitle: true,
//       ),
//       backgroundColor: Color(0xFFFF0035),
//       body: Center(child: Text('hello')),
//       bottomNavigationBar: FloatNavigationBar(),
//     );
//   }
// }
class FloatNavigationBar extends StatefulWidget {
  final int actionIndex; // 默认悬浮按钮的位置
  final double barHeight; // 正常显示的高度
  final Color? actionColor; // 选中的颜色
  final Color? inactionColor; // 未选中的颜色
  final List<IconData> icons; // 显示的图标
  final List<String>? title; // 显示的文本

  const FloatNavigationBar(
      this.icons, {
        super.key,
        this.actionIndex = 0,
        this.barHeight = 48.0,
        this.actionColor = Colors.blue,
        this.inactionColor = Colors.grey,
        this.title,
      });

  @override
  State<StatefulWidget> createState() => _FloatNavigatorState();
}

class _FloatNavigatorState extends State<FloatNavigationBar> with SingleTickerProviderStateMixin {
  int _itemCount = 0; // item数量
  int _activeIndex = 0; // 显示为悬浮按钮的位置
  final double _radiusPadding = 10.0;
  double _radius = 0; // 悬浮图标半径
  double _moveTween = 0.0; // 移动补间

  AnimationController? _animationController; // 动画控制器

  @override
  void initState() {
    _activeIndex = widget.actionIndex;
    _radius = widget.barHeight * 2 / 3;
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _itemCount = widget.icons.length;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [_activeNavigationItem(width), _inactiveNavigationItem()],
      ),
    );
  }

  // 浮动在底部导航栏的Item
  Widget _activeNavigationItem(double width) {
    double padding = _radiusPadding / 2;
    double itemWidth = width / _itemCount;

    // 顶部偏离的距离
    double top = getNavigationValue() <= 0.5
        ? (getNavigationValue() * widget.barHeight * padding) - _radius / 3 * 2
        : (1 - getNavigationValue()) * widget.barHeight * padding - _radius / 3 * 2;
    // 左边偏移的距离
    double left = _moveTween * itemWidth + (itemWidth - _radius) / 2 - padding;

    return Positioned(
      top: top,
      left: left,
      child: DecoratedBox(
        decoration: ShapeDecoration(shape: const CircleBorder(), shadows: [
          BoxShadow(
            blurRadius: padding,
            offset: Offset(0, padding),
            spreadRadius: 0,
            color: Colors.black26,
          ),
        ]),
        child: CircleAvatar(
          radius: _radius - _radiusPadding, // 浮动图标和圆弧之间设置 padding 间隙
          backgroundColor: Colors.white,
          child: Icon(widget.icons[_activeIndex], color: widget.actionColor),
        ),
      ),
    );
  }

  // 未被选中的导航栏Item
  Widget _inactiveNavigationItem() {
    return CustomPaint(
      painter: ArcPainter(navCount: _itemCount, moveTween: _moveTween, padding: _radiusPadding),
      child: SizedBox(
        height: widget.barHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widget.icons
              .asMap()
              .map(
                (i, v) => MapEntry(
                i, GestureDetector(child: getItem(i, _activeIndex == i), onTap: () => _switchNavigationItem(i))),
          )
              .values
              .toList(),
        ),
      ),
    );
  }

  Widget getItem(int index, bool selected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(widget.icons[index], color: selected ? Colors.transparent : widget.inactionColor),
        Offstage(
          offstage: widget.title == null || _activeIndex == index,
          child: Text(widget.title?[index] ?? '', style: TextStyle(color: widget.inactionColor)),
        ),
      ],
    );
  }

  // 切换导航
  _switchNavigationItem(int newIndex) {
    double oldPosition = _activeIndex.toDouble();
    double newPosition = newIndex.toDouble();
    if (oldPosition != newPosition && _animationController?.status != AnimationStatus.forward) {
      _animationController?.reset();
      Animation<double>? animation = Tween(begin: oldPosition, end: newPosition)
          .animate(CurvedAnimation(parent: _animationController!, curve: Curves.easeInCubic));
      animation
        ..addListener(() => setState(() => _moveTween = animation.value))
        ..addStatusListener((AnimationStatus status) {
          if (status == AnimationStatus.completed) {
            setState(() => _activeIndex = newIndex);
          }
        });
      _animationController?.forward();
    }
  }

  double getNavigationValue() => _animationController?.value ?? 0;

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
}

/// 绘制圆弧背景
class ArcPainter extends CustomPainter {
  final int navCount; // 导航总数
  final double moveTween; // 移动补间
  final double padding; // 间隙
  ArcPainter({this.navCount = 0, this.moveTween = 0, this.padding = 0});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = (Colors.white)
      ..style = PaintingStyle.stroke;

    double width = size.width; // 导航栏总宽度，即canvas宽度
    double height = size.height; // 导航栏总高度，即canvas高度
    double itemWidth = width / navCount; // 单个导航项宽度
    double arcRadius = height * 2 / 3; // 选中导航栏的圆弧半径
    double restSpace = (itemWidth - arcRadius * 2) / 2; // 单个导航项减去圆弧直径后单边剩余宽度

    Path path = Path()
      ..relativeLineTo(moveTween * itemWidth, 0)
      ..relativeCubicTo(restSpace + padding, 0, restSpace + padding / 2, arcRadius, itemWidth / 2, arcRadius) // 圆弧左半边
      ..relativeCubicTo(arcRadius, 0, arcRadius - padding, -arcRadius, restSpace + arcRadius, -arcRadius) // 圆弧右半边
      ..relativeLineTo(width - (moveTween + 1) * itemWidth, 0)
      ..relativeLineTo(0, height)
      ..relativeLineTo(-width, 0)
      ..relativeLineTo(0, -height)
      ..close();

    paint.style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}