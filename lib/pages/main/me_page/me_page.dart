import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/base/res/strings.dart';
import 'package:flutter_ui/base/router/route_manager.dart';
import 'package:flutter_ui/base/widgets/keyboard/keyboard_main.dart';

import 'city_page/city_page.dart';
import 'convert_page/convert_page.dart';
import 'drag_list_page/drag_list_page.dart';
import 'float_navigation_page/float_navigation_page.dart';
import 'http_page/http_page.dart';
import 'list_page/list_page.dart';
import 'me_model.dart';
import 'qr_page/qr_page.dart';
import 'setting_page/setting_page.dart';
import 'state_page/state_page.dart';
import 'text_page/text_page.dart';
import 'video_page/video_page.dart';

// 子页面
class MePage extends StatefulWidget {
  final String _title;

  MePage(this._title);

  @override
  _MePageState createState() => _MePageState();
}

class _MePageState extends State<MePage> with AutomaticKeepAliveClientMixin {
  String _tag = 'MePage';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Log.d('initState', tag: _tag);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Log.d('didChangeDependencies', tag: _tag);
  }

  @override
  void didUpdateWidget(covariant MePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    Log.d('didUpdateWidget', tag: _tag);
  }

  @override
  void deactivate() {
    super.deactivate();
    Log.d('deactivate', tag: _tag);
  }

  @override
  void dispose() {
    super.dispose();
    Log.d('dispose', tag: _tag);
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

  List<Widget> childrenButtons() {
    return [
      SizedBox(height: 16),
      MaterialButton(
        child: _text(S.of.textAndInput),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => RouteManager.push(TextPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of.navigationBar),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => RouteManager.push(FloatNavigationPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of.charConvert),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => RouteManager.push(ConvertPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of.httpRequest),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => RouteManager.push(HTTPListPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of.listAndRefresh),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => RouteManager.push(ListPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of.dragList),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => RouteManager.push(DragListPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of.videoPlay),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => RouteManager.push(VideoPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of.qr),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => RouteManager.push(QRPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of.citySelected),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => RouteManager.push(CitySelectedPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of.setting),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => RouteManager.push(SettingPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of.state),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => RouteManager.push(StatePage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of.state),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => RouteManager.push(main_keyboard ()),
      ),
      SizedBox(height: 8),
      Text(MeModel.of.value),
      SizedBox(height: 16),
    ];
  }

  Widget _text(String text) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(text)]);
  }
}
