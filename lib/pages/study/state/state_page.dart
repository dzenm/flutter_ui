import 'package:flutter/material.dart';

import '../../../base/base.dart';

/// 加载状态页面
class StatePage extends StatefulWidget {
  const StatePage({super.key});

  @override
  State<StatefulWidget> createState() => _StatePageState();
}

class _StatePageState extends State<StatePage> {
  final List<Item> _items = [
    Item(0, title: '展示加载页面'),
    Item(1, title: '展示失败页面'),
    Item(2, title: '展示空白页面'),
    Item(3, title: '展示成功页面'),
    Item(4, title: '展示新页面'),
    Item(5, title: '展示咩有页面'),
  ];

  String _image = 'a.jpg';

  final StateController _controller = StateController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('文本和输入框', style: TextStyle(color: Colors.white)),
        actions: [
          PopupMenuButton<Item>(
            elevation: 4.0,
            onSelected: (Item item) {
              setState(() {
                if (item.index == 0) {
                  _controller.loading();
                } else if (item.index == 1) {
                  _controller.loadFailed();
                  _image = Assets.a;
                } else if (item.index == 2) {
                  _controller.loadEmpty();
                  _image = Assets.b;
                } else if (item.index == 3) {
                  _controller.loadSuccess();
                  _image = Assets.c;
                } else if (item.index == 4) {
                  _controller.loadComplete();
                } else {
                  _controller.loadNone();
                  _image = Assets.d;
                }
              });
            },
            itemBuilder: (BuildContext context) {
              return _items.map((value) => PopupMenuItem<Item>(value: value, child: Text(value.title ?? ''))).toList();
            },
          ),
        ],
      ),
      body: StateView(
        controller: _controller,
        image: Image.asset(_image, fit: BoxFit.cover, width: 96, height: 96),
        child: const Center(
          child: Text('展示成功页面'),
        ),
      ),
    );
  }
}
