import 'package:flutter/material.dart';
import 'package:flutter_ui/base/res/lang/strings.dart';

/// 可拖动ListView
class DragListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DragListPageState();
}

class _DragListPageState extends State<DragListPage> {
  List<Color> _list = [
    Colors.blue,
    Colors.pink,
    Colors.amber,
    Colors.green,
    Colors.teal,
    Colors.cyan,
    Colors.purple,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).dragList, style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ReorderableListView(
                children: _list.map((color) {
                  return Card(
                    key: Key(color.toString()),
                    color: color,
                    child: Container(
                      height: 100,
                    ),
                  );
                }).toList(),
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) newIndex -= 1;
                    var data = _list.removeAt(oldIndex);
                    _list.insert(newIndex, data);
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
