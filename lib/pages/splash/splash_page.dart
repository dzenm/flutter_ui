import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/router/navigator_manager.dart';

import '../root_route.dart';

class SplashPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () => NavigatorManager.navigateTo(context, RootRoute.main, clearStack: true));
    return Scaffold(body: Text(''));
  }
}
