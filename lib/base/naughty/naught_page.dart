import 'package:flutter/material.dart';

import 'db_page.dart';
import 'http_list_widget.dart';
import 'naughty.dart';

///
/// Created by a0010 on 2023/3/24 11:13
///
/// naughty 主页
class NaughtPage extends StatefulWidget {
  const NaughtPage({super.key});

  @override
  State<StatefulWidget> createState() => _NaughtPageState();
}

class _NaughtPageState extends State<NaughtPage> {
  final List<String> _items = [
    'Database',
    'SharedPreference',
    'Setting',
    'Clear',
    'Quit',
  ];

  @override
  void initState() {
    super.initState();
    Naughty.instance.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Mode'),
        actions: [
          PopupMenuButton<String>(
            elevation: 4.0,
            onSelected: (String item) {
              int index = _items.indexWhere((e) => e == item);
              if (index == 0) {
                Naughty.instance.push(context, const DBPage());
              } else if (index == 1) {
              } else if (index == 2) {
              } else if (index == 3) {
                Naughty.instance.httpRequests.clear();
              } else if (index == 4) {
                Navigator.pop(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return _items.map((value) => PopupMenuItem(value: value, child: Text(value))).toList();
            },
          )
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(child: HTTPListWidget()),
          ],
        ),
      ),
    );
  }
}
