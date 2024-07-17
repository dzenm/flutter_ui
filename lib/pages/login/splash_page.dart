import 'package:flutter/material.dart';
import 'package:flutter_ui/base/a_router/misc/extensions.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text(''));
  }
}
