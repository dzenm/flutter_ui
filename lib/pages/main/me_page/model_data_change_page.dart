import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  Person? person;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('测试', style: TextStyle(color: Colors.white)),
        systemOverlayStyle: SystemUiOverlayStyle.light,
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
    person = context.read<MeModel>().persons[0];
    return [
      SizedBox(height: 16),
      MaterialButton(
        child: Text('修改数据'),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () {
          person?.name = '修改后的名字';
          person?.age = 30;
          person?.address = '修改后的地址';
          context.read<MeModel>().updatePerson(0, person!);
        },
      ),
    ];
  }
}
