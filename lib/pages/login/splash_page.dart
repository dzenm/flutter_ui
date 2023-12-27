import 'package:flutter/material.dart';

import '../../base/base.dart';
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
    Future.delayed(Duration.zero, () => AppRouter.of(context).push(Routers.main, clearStack: true));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text(''));
  }
}
