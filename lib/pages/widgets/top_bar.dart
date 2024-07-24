import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const double _kMaxTitleTextScaleFactor = 1.34;

///
/// Created by a0010 on 2023/12/18 11:20
///
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
