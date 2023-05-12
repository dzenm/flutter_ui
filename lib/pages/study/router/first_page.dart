import 'package:flutter/material.dart';
import 'package:flutter_ui/base/res/local_model.dart';
import 'package:flutter_ui/base/res/app_theme.dart';
import 'package:flutter_ui/base/route/route_manager.dart';
import 'package:flutter_ui/pages/study/router/router_page.dart';
import 'package:provider/provider.dart';

///
/// Created by a0010 on 2023/2/3 16:59
///
class FirstPage extends StatefulWidget {
  final int type;
  final int index;

  FirstPage({
    required this.type,
    required this.index,
  });

  @override
  State<StatefulWidget> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  List<String> list = [];

  @override
  void initState() {
    super.initState();

    list = RouterPage.list[widget.type];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(list[0], style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 16),
            _buildNavigator(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigator() {
    AppTheme appTheme = context.watch<LocalModel>().appTheme;
    bool last = widget.index == list.length - 1;
    String text = last ? '返回' : '下一个页面';
    return MaterialButton(
      child: _text(text),
      textColor: Colors.white,
      color: appTheme.appbarColor,
      onPressed: navigator,
    );
  }

  void navigator() {
    bool last = widget.index == list.length - 1;
    if (!last) {
      // 直接进入下一个页面，例：A->B, 现在在A页面调用push进入B页面
      Navigator.push(
        context,
        RouteManager.createMaterialRoute(FirstPage(type: widget.type, index: widget.index + 1)),
      );
      return;
    }
    if (widget.type == 0) {
      // 返回上一个页面，例：A->B->C->D, 现在在D页面调用pop回到C页面
      Navigator.pop(context);
    } else if (widget.type == 1) {
      // 返回指定页面，例：A->B->C->D, 现在在D页面调用popUntil, 设置router.settings.name == 'A'，回到A页面
      Navigator.popUntil(context, (router) => router.settings.name == 'RouterPage');
    } else if (widget.type == 2) {
      //
      Navigator.pushReplacement(
        context,
        RouteManager.createMaterialRoute(FirstPage(type: widget.type, index: widget.index)),
      );
    } else if (widget.type == 3) {
      Navigator.pushAndRemoveUntil(
        context,
        RouteManager.createMaterialRoute(FirstPage(type: widget.type, index: widget.index)),
        (router) => router.settings.name == 'RouterPage',
      );
    }
  }

  Widget _text(String text) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(text)]);
  }
}
