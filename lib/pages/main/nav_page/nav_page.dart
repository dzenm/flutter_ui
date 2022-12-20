import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui/base/log/log.dart';

// 分类页面
class NavPage extends StatefulWidget {
  final String title;

  NavPage({required this.title});

  @override
  _NavPageState createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> with AutomaticKeepAliveClientMixin {
  static const String _TAG = 'NavPage';

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
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
        ),
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(),
      ),
    );
  }
}
