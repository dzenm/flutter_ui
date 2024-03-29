import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'db_page.dart';
import 'http_entity.dart';
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
  final List<HTTPEntity> _list = [];

  @override
  void initState() {
    super.initState();
    Naughty().dismiss();

    _getData();
  }

  //列表要展示的数据
  Future<void> _getData() async {
    Future.delayed(Duration.zero, () {
      _list.clear();
      setState(() => _list.addAll(Naughty().httpRequests));
    });
  }

  @override
  void dispose() {
    super.dispose();
    Naughty().show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Mode', style: TextStyle(color: Colors.white)),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: [
          PopupMenuButton<String>(
            elevation: 4.0,
            onSelected: (String item) {
              int index = _items.indexWhere((e) => e == item);
              if (index == 0) {
                Naughty().push(context, const DBPage());
              } else if (index == 1) {
              } else if (index == 2) {
              } else if (index == 3) {
                setState(() => _list.clear());
              } else if (index == 4) {
                Naughty().dispose();
                Navigator.pop(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return _items.map((value) => PopupMenuItem(value: value, child: Text(value))).toList();
            },
          )
        ],
      ),
      body: Column(children: [
        Expanded(
          child: HTTPListWidget(
            list: _list,
            onRefresh: _getData,
          ),
        ),
      ]),
    );
  }
}
