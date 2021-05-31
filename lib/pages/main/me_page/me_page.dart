import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/pages/main/me_page/me_router.dart';
import 'package:flutter_ui/router/common_route.dart';
import 'package:flutter_ui/router/navigator_manager.dart';

// 子页面
class MePage extends StatefulWidget {
  final String _title;

  MePage(this._title);

  @override
  _MePageState createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget._title)),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: childrenButtons()),
      ),
    );
  }

  //
  List<Widget> childrenButtons() {
    return [
      MaterialButton(
        child: text('文本和输入框'),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => NavigatorManager.push(context, MeRouter.textPage),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: text('NavigationBar'),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => NavigatorManager.push(context, MeRouter.floatNavigator),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: text('字符转化'),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => NavigatorManager.push(context, MeRouter.convert),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: text('Http请求'),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => NavigatorManager.push(context, MeRouter.http),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: text('未找到对应的页面'),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => NavigatorManager.push(context, CommonRoute.notFound),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: text('列表和刷新'),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => NavigatorManager.push(context, MeRouter.list),
      ),
    ];
  }

  Widget text(String text) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(text)]);
  }
}
