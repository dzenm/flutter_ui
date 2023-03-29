import 'package:flutter/material.dart';

import '../../generated/l10n.dart';

class NotFoundPage extends StatefulWidget {
  const NotFoundPage({super.key});

  @override
  State<StatefulWidget> createState() => _NotFoundPageState();
}

class _NotFoundPageState extends State<NotFoundPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(S.of(context).notFoundPage)),
    );
  }
}
