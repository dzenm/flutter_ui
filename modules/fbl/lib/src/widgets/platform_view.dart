import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///
/// Created by a0010 on 2024/12/2 13:30
/// 区分平台布局
class PlatformView extends StatelessWidget {
  final Widget? androidView;
  final Widget? iOSView;
  final Widget? windowsView;
  final Widget? macOSView;
  final Widget? linuxView;
  final Widget? webView;

  const PlatformView({
    super.key,
    this.androidView,
    this.iOSView,
    this.windowsView,
    this.macOSView,
    this.linuxView,
    this.webView,
  });

  const PlatformView.builder({
    super.key,
    Widget? mobileView,
    Widget? desktopView,
    Widget? webView,
  })  : androidView = mobileView,
        iOSView = mobileView,
        windowsView = desktopView,
        macOSView = desktopView,
        linuxView = desktopView,
        webView = webView ?? desktopView;

  @override
  Widget build(BuildContext context) {
    Widget? child;
    if (kIsWeb) {
      child = webView;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      child = androidView;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      child = iOSView;
    } else if (defaultTargetPlatform == TargetPlatform.windows) {
      child = windowsView;
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      child = macOSView;
    } else if (defaultTargetPlatform == TargetPlatform.linux) {
      child = linuxView;
    }
    return child ?? const Placeholder();
  }
}
