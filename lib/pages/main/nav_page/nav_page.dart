import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/channels/native_channels.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/base/res/strings.dart';
import 'package:flutter_ui/base/router/route_manager.dart';
import 'package:flutter_ui/base/widgets/keyboard/keyboard_main.dart';
import 'package:flutter_ui/pages/main/nav_page/nav_model.dart';

import 'city_page/city_page.dart';
import 'convert_page/convert_page.dart';
import 'drag_list_page/drag_list_page.dart';
import 'float_navigation_page/float_navigation_page.dart';
import 'http_page/http_page.dart';
import 'list_page/list_page.dart';
import 'qr_page/qr_page.dart';
import 'setting_page/setting_page.dart';
import 'state_page/state_page.dart';
import 'text_page/text_page.dart';
import 'video_page/video_page.dart';

// 分类页面
class NavPage extends StatefulWidget {
  final String _title;

  NavPage(this._title);

  @override
  _NavPageState createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> with AutomaticKeepAliveClientMixin {
  static const String _TAG = 'NavPage';

  List<String> _titles = [];
  List<String> _images = [];
  List<String> _urls = [];

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
  void didUpdateWidget(covariant NavPage oldWidget) {
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

  List<Widget> childrenButtons() {
    return [
      SizedBox(height: 16),
      MaterialButton(
        child: _text(S.of(context).textAndInput),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => RouteManager.push(TextPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of(context).navigationBar),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => RouteManager.push(FloatNavigationPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of(context).charConvert),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => RouteManager.push(ConvertPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of(context).httpRequest),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => RouteManager.push(HTTPListPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of(context).listAndRefresh),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => RouteManager.push(ListPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of(context).dragList),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => RouteManager.push(DragListPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of(context).videoPlay),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => RouteManager.push(VideoPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of(context).qr),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => RouteManager.push(QRPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of(context).citySelected),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => RouteManager.push(CitySelectedPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of(context).setting),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => RouteManager.push(SettingPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of(context).state),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => RouteManager.push(StatePage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of(context).keyword),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => RouteManager.push(main_keyboard()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text(S.of(context).navigation),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => NativeChannels.startHomeActivity(),
      ),
      SizedBox(height: 8),
      Text(NavModel.of.value),
      SizedBox(height: 16),
    ];
  }

  Widget _text(String text) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(text)]);
  }
}
