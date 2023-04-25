import 'package:flutter/material.dart';

import '../../base/utils/route_manager.dart';
import '../main/main_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<StatefulWidget> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => RouteManager.push(context, MainPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text(''));
  }
}
