import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/base/router/route_manager.dart';

import 'medicine_page/chinese_medicine_page.dart';
import 'model_data_listen_page.dart';

// 我的页面
class MePage extends StatefulWidget {
  final String _title;

  MePage(this._title);

  @override
  _MePageState createState() => _MePageState();
}

class _MePageState extends State<MePage> with AutomaticKeepAliveClientMixin {
  static const String _TAG = 'MePage';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Log.d('initState', tag: _TAG);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Log.d('didChangeDependencies', tag: _TAG);
  }

  @override
  void didUpdateWidget(covariant MePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    Log.d('didUpdateWidget', tag: _TAG);
  }

  @override
  void deactivate() {
    super.deactivate();
    Log.d('deactivate', tag: _TAG);
  }

  @override
  void dispose() {
    super.dispose();
    Log.d('dispose', tag: _TAG);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text(widget._title, style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(children: childrenButtons()),
        ),
      ),
    );
  }

  // 药
  List<Widget> childrenButtons() {
    return [
      SizedBox(height: 16),
      MaterialButton(
        child: Text('进入下一个页面'),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => RouteManager.push(ModelDataListenPage()),
      ),
      SizedBox(height: 16),
      MaterialButton(
        child: Text('中药药方'),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => RouteManager.push(ChineseMedicinePage(medicineName: '金银花',)),
      ),
    ];
  }
}
