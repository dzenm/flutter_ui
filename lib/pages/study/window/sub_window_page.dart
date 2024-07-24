import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';

import 'event_widget.dart';

///
/// Created by a0010 on 2023/12/28 15:55
///
class SubWindowPage extends StatelessWidget {
  const SubWindowPage({
    super.key,
    required this.windowController,
    required this.args,
  });

  final WindowController windowController;
  final Map? args;

  @override
  Widget build(BuildContext context) {
    Log.d('测试SubWindow');
    return MaterialApp(
      home: Scaffold(
        appBar: const CommonBar(
          title: 'Plugin example app',
        ),
        body: Column(
          children: [
            if (args != null)
              Text(
                'Arguments: ${args.toString()}',
                style: const TextStyle(fontSize: 20),
              ),
            TextButton(
              onPressed: () async {
                windowController.close();
              },
              child: const Text('Close this window'),
            ),
            Expanded(child: EventWidget(controller: windowController)),
          ],
        ),
      ),
    );
  }
}
