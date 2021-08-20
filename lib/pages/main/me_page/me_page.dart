import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/base/res/strings.dart';
import 'package:flutter_ui/base/router/navigator_manager.dart';
import 'package:flutter_ui/pages/main/me_page/me_model.dart';
import 'package:flutter_ui/pages/main/me_page/me_router.dart';

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
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: childrenButtons()),
      ),
    );
  }

  List<Widget> childrenButtons() {
    return [
      MaterialButton(
        child: text(S.of.textAndInput),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => NavigatorManager.navigateTo(context, MeRouter.textPage),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: text(S.of.navigationBar),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => NavigatorManager.navigateTo(context, MeRouter.floatNavigatorPage),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: text(S.of.charConvert),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => NavigatorManager.navigateTo(context, MeRouter.convertPage),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: text(S.of.httpRequest),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => NavigatorManager.navigateTo(context, MeRouter.httpPage),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: text(S.of.listAndRefresh),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => NavigatorManager.navigateTo(context, MeRouter.listPage),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: text(S.of.qr),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => NavigatorManager.navigateTo(context, MeRouter.qrPage),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: text(S.of.citySelected),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => NavigatorManager.navigateTo(context, MeRouter.citySelectedPage),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: text(S.of.setting),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => NavigatorManager.navigateTo(context, MeRouter.settingPage),
      ),
      SizedBox(height: 8),
      Text(MeModel.of.value),
    ];
  }

  Widget text(String text) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(text)]);
  }
}
