import 'package:flutter/material.dart';
import 'package:flutter_ui/base/widgets/common_dialog.dart';
import 'package:flutter_ui/base/widgets/float_navigation_bar.dart';

import '../../../base/widgets/custom_popup_window.dart';

/// 浮动的导航栏和PopupWindow
class FloatNavigationPage extends StatefulWidget {
  @override
  _FloatNavigationPageState createState() => _FloatNavigationPageState();
}

class _FloatNavigationPageState extends State<FloatNavigationPage> {
  List<IconData> _navs = [
    Icons.search,
    Icons.ondemand_video,
    Icons.music_video,
    Icons.insert_comment,
    Icons.person,
  ]; // 导航项

  List<String> _title = [
    '搜索',
    '视频',
    '音乐',
    '评论',
    '我的',
  ];

  GlobalKey targetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text('NavigationBar', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Center(
        child: SizedBox(
          key: targetKey,
          width: 100,
          height: 42,
          child: MaterialButton(
            onPressed: () {
              CustomPopupWindow.showList(context, targetKey, ['全选', '复制', '粘贴'], onItemTap: (index) {
                CommonDialog.showToast('第${index + 1}个Item');
              });
            },
            color: Colors.amberAccent,
            child: Text(
              "Custom",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      bottomNavigationBar: FloatNavigationBar(_navs, title: _title),
    );
  }
}
