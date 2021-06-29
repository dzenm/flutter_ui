import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/res/strings.dart';
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
      appBar: AppBar(brightness: Brightness.dark, title: Text(widget._title, style: TextStyle(color: Colors.white))),
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
        child: text(S.of.textAndInput),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => NavigatorManager.push(context, MeRouter.textPage),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: text(S.of.navigationBar),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => NavigatorManager.push(context, MeRouter.floatNavigator),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: text(S.of.charConvert),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => NavigatorManager.push(context, MeRouter.convert),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: text(S.of.httpRequest),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => NavigatorManager.push(context, MeRouter.http),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: text(S.of.pageIsNotFound),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => NavigatorManager.push(context, CommonRoute.notFound),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: text(S.of.listAndRefresh),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => NavigatorManager.push(context, MeRouter.list),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: text(S.of.setting),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => NavigatorManager.push(context, MeRouter.settingPage),
      ),
    ];
  }

  Widget text(String text) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(text)]);
  }
}
