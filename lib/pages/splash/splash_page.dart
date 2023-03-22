import 'package:flutter/material.dart';

import '../../base/router/route_manager.dart';
import '../main/main_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

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
