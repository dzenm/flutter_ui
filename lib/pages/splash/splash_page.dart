import 'package:flutter/material.dart';
import 'package:flutter_ui/base/router/route_manager.dart';
import 'package:flutter_ui/pages/main/main_page.dart';

class SplashPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () => RouteManager.push(context, MainPage()));
    return Scaffold(body: Text(''));
  }
}
