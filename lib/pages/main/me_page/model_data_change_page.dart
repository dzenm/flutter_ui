import 'package:flutter/material.dart';
import 'package:flutter_ui/pages/main/me_page/me_model.dart';
import 'package:provider/provider.dart';

///
/// Created by a0010 on 2022/3/30 16:41
///
class ModelDataChangePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ModelDataChangePageState();
}

class _ModelDataChangePageState extends State<ModelDataChangePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text('测试', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(children: childrenButtons()),
        ),
      ),
    );
  }

  List<Widget> childrenButtons() {
    return [
      SizedBox(height: 16),
      MaterialButton(
        child: Text('修改数据'),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () {
          context.read<MeModel>().setChildValue('child init');
        },
      ),
    ];
  }
}
