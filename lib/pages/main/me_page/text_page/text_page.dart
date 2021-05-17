import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/widgets/common_view.dart';
import 'package:flutter_ui/widgets/single_edit_layout.dart';

class TextPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
  TextEditingController _controller = new TextEditingController(text: "初始化");
  String text = '';

  @override
  void initState() {
    super.initState();
    text = _controller.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(context: context, title: '文本和输入框'),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('无边框带字数控制的输入框: ', style: TextStyle(color: Colors.blue)),
              SingleEditLayout(
                '账户',
                (value) => setState(() => text = value),
                controller: _controller,
                maxLength: 12,
                fontSize: 14,
                horizontalPadding: 0,
              ),
              Container(
                color: Colors.blue,
                padding: EdgeInsets.all(8),
                height: 80,
                alignment: Alignment.topLeft,
                child: Row(children: [Text(text, maxLines: 4, style: TextStyle(color: Colors.white))]),
              ),
              SizedBox(height: 8),
              divider(),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(child: Text('Row包含一个文本，两个图标，给所有子widget设置Expand的，这是长文本的效果', maxLines: 1, overflow: TextOverflow.ellipsis)),
                  Icon(Icons.add_photo_alternate_outlined),
                  Icon(Icons.info),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(child: Text('短文本和图标', maxLines: 1, overflow: TextOverflow.ellipsis)),
                  Icon(Icons.add_photo_alternate_outlined),
                  Icon(Icons.info),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
