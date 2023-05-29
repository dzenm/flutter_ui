import 'package:flutter/material.dart';

import '../routers.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<StatefulWidget> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => Navigator.popAndPushNamed(context, Routers.main));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text(''));
  }
}
