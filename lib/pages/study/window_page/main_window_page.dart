import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';

import 'event_widget.dart';

///
/// Created by a0010 on 2023/12/28 16:00
///
class MainWindowPage extends StatefulWidget {
  const MainWindowPage({super.key});

  @override
  State<StatefulWidget> createState() => _MainWindowPageState();
}

class _MainWindowPageState extends State<MainWindowPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            TextButton(
              onPressed: () async {
                final window = await DesktopMultiWindow.createWindow(jsonEncode({
                  'args1': 'Sub window',
                  'args2': 100,
                  'args3': true,
                  'business': 'business_test',
                }));
                window
                  ..setFrame(const Offset(0, 0) & const Size(1280, 720))
                  ..center()
                  ..setTitle('Another window')
                  ..show();
              },
              child: const Text('Create a new World!'),
            ),
            TextButton(
              child: const Text('Send event to all sub windows'),
              onPressed: () async {
                final subWindowIds = await DesktopMultiWindow.getAllSubWindowIds();
                for (final windowId in subWindowIds) {
                  DesktopMultiWindow.invokeMethod(
                    windowId,
                    'broadcast',
                    'Broadcast from main window',
                  );
                }
              },
            ),
            Expanded(
              child: EventWidget(controller: WindowController.fromWindowId(0)),
            )
          ],
        ),
      ),
    );
  }
}
