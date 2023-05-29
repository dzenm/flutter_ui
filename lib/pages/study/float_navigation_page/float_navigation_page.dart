import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/base/widgets/check_box.dart';
import 'package:flutter_ui/base/widgets/common_dialog.dart';
import 'package:flutter_ui/base/widgets/float_navigation_bar.dart';

import '../../../base/widgets/custom_popup_window.dart';
import '../../../base/widgets/single_text_layout.dart';
import '../../../base/widgets/tap_layout.dart';

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

  List<String> _title = ['搜索', '视频', '音乐', '评论', '我的'];

  GlobalKey _targetKey = GlobalKey();

  PopupDirection _direction = PopupDirection.bottom;
  bool _isCollapsed = false, _isPin = false, _enabledOffset = false, _enabledArrowOffset = false;
  double _offsetX = 0, _offsetY = 0, _offsetArrowX = 0, _offsetArrowY = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text('导航栏', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: _buildMenuView(),
      ),
      bottomNavigationBar: FloatNavigationBar(_navs, title: _title),
    );
  }

  Widget _buildMenuView() {
    List<String> list = ['左上', '正左', '左下', '上左', '正上', '上右', '右上', '正右', '右下', '下右', '正下', '下左'];
    return Column(children: [
      Container(
        child: CheckGroup(
          list: list,
          padding: EdgeInsets.symmetric(vertical: 16),
          initialValue: 10,
          childAspectRatio: 2.2,
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          onChanged: (index) {
            PopupDirection.values.forEach((direct) {
              if (direct.index == index) {
                _direction = direct;
              }
            });
          },
        ),
      ),
      SizedBox(
        key: _targetKey,
        width: 120,
        height: 48,
        child: MaterialButton(
          onPressed: () {
            CustomPopupWindow.showList(
              context,
              targetKey: _targetKey,
              direction: _direction,
              isCollapsed: _isCollapsed,
              isPin: _isPin,
              offset: _enabledOffset ? Offset(_offsetX, _offsetY) : null,
              arrowOffset: _enabledArrowOffset ? Offset(_offsetArrowX, _offsetArrowY) : null,
              titles: ['全选', '复制', '粘贴', '测试'],
              onItemTap: (index) {
                CommonDialog.showToast('第${index + 1}个Item');
              },
            );
          },
          color: Colors.amberAccent,
          child: Text(
            "Custom",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      TapLayout(
        width: MediaQuery.of(context).size.width,
        height: 50.0,
        child: SingleTextLayout(
          title: 'Popup在Target所在的方向等大',
          suffix: CupertinoSwitch(value: _isCollapsed, onChanged: (value) => setState(() => _isCollapsed = value)),
        ),
      ),
      if (_isCollapsed)
        TapLayout(
          width: MediaQuery.of(context).size.width,
          height: 50.0,
          child: SingleTextLayout(
            title: '是否固定箭头(在上一个选项基础上)',
            suffix: CupertinoSwitch(value: _isPin, onChanged: (value) => setState(() => _isPin = value)),
          ),
        ),
      TapLayout(
        width: MediaQuery.of(context).size.width,
        height: 50.0,
        child: SingleTextLayout(
          title: '开启自定义偏移量',
          suffix: CupertinoSwitch(value: _enabledOffset, onChanged: (value) => setState(() => _enabledOffset = value)),
        ),
      ),
      if (_enabledOffset)
        Row(children: [
          Text('Popup偏移量X'),
          Expanded(
            child: Slider(
              value: _offsetX,
              onChanged: (data) {
                setState(() => _offsetX = data);
              },
              min: -30,
              max: 30,
              divisions: 60,
              label: '$_offsetX',
              activeColor: Colors.green,
              inactiveColor: Colors.grey,
            ),
          ),
        ]),
      if (_enabledOffset)
        Row(children: [
          Text('Popup偏移量Y'),
          Expanded(
            child: Slider(
              value: _offsetY,
              onChanged: (data) {
                setState(() => _offsetY = data);
              },
              min: -30,
              max: 30,
              divisions: 60,
              label: '$_offsetY',
              activeColor: Colors.green,
              inactiveColor: Colors.grey,
            ),
          ),
        ]),
      TapLayout(
        width: MediaQuery.of(context).size.width,
        height: 50.0,
        child: SingleTextLayout(
          title: '开启自定义箭头偏移量',
          suffix: CupertinoSwitch(value: _enabledArrowOffset, onChanged: (value) => setState(() => _enabledArrowOffset = value)),
        ),
      ),
      if (_enabledArrowOffset)
        Row(children: [
          Text('Popup偏移量X'),
          Expanded(
            child: Slider(
              value: _offsetArrowX,
              onChanged: (data) {
                setState(() => _offsetArrowX = data);
              },
              min: -30,
              max: 30,
              divisions: 60,
              label: '$_offsetArrowX',
              activeColor: Colors.green,
              inactiveColor: Colors.grey,
            ),
          ),
        ]),
      if (_enabledArrowOffset)
        Row(children: [
          Text('Popup偏移量Y'),
          Expanded(
            child: Slider(
              value: _offsetArrowY,
              onChanged: (data) {
                setState(() => _offsetArrowY = data);
              },
              min: -30,
              max: 30,
              divisions: 60,
              label: '$_offsetArrowY',
              activeColor: Colors.green,
              inactiveColor: Colors.grey,
            ),
          ),
        ]),
    ]);
  }
}
