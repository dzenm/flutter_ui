import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../base/base.dart';


///
/// Created by a0010 on 2023/6/9 10:16
/// 快速页面创建
class PopupPage extends StatefulWidget {
  const PopupPage({super.key});

  @override
  State<StatefulWidget> createState() => _PopupPageState();
}

class _PopupPageState extends State<PopupPage> {
  final GlobalKey _targetKey = GlobalKey();

  PopupDirection _direction = PopupDirection.bottom;
  bool _isCollapsed = false, _isPin = false, _enabledOffset = false, _enabledArrowOffset = false;
  double _offsetX = 0, _offsetY = 0, _offsetArrowX = 0, _offsetArrowY = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonBar(
        title: 'PopupWindow测试',
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Expanded(child: _buildMenuView()),
        ]),
      ),
    );
  }

  Widget _buildMenuView() {
    List<String> list = ['左下', '正左', '左上', '上左', '正上', '上右', '右上', '正右', '右下', '下右', '正下', '下左'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Flexible(
          child: CheckGroup(
        list: list,
        padding: const EdgeInsets.symmetric(vertical: 16),
        initialValue: 10,
        childAspectRatio: 2.2,
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        onChanged: (index) {
          for (var direct in PopupDirection.values) {
            if (direct.index == index) {
              _direction = direct;
            }
          }
        },
      )),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                color: Colors.grey,
                elevation: 4,
                offset: _enabledOffset ? Offset(_offsetX, _offsetY) : null,
                directOffset: _enabledArrowOffset ? Offset(_offsetArrowX, _offsetArrowY) : null,
                titles: ['全选', '复制', '粘贴', '测试'],
                onItemTap: (index) {
                  CommonDialog.showToast('第${index + 1}个Item');
                },
              );
            },
            color: Colors.amberAccent,
            child: const Text(
              "Custom",
              style: TextStyle(color: Colors.white),
            ),
          ),
        )
      ]),
      TapLayout(
        width: MediaQuery.of(context).size.width,
        height: 50.0,
        child: SingleTextView(
          title: 'Popup在Target所在的方向等大',
          suffix: CupertinoSwitch(value: _isCollapsed, onChanged: (value) => setState(() => _isCollapsed = value)),
        ),
      ),
      TapLayout(
        width: MediaQuery.of(context).size.width,
        height: 50.0,
        child: SingleTextView(
          title: '是否固定方向指示器',
          suffix: CupertinoSwitch(value: _isPin, onChanged: (value) => setState(() => _isPin = value)),
        ),
      ),
      TapLayout(
        width: MediaQuery.of(context).size.width,
        height: 50.0,
        child: SingleTextView(
          title: '开启自定义偏移量',
          suffix: CupertinoSwitch(value: _enabledOffset, onChanged: (value) => setState(() => _enabledOffset = value)),
        ),
      ),
      if (_enabledOffset)
        Row(children: [
          const Text('Popup偏移量X'),
          Expanded(
            child: Slider(
              value: _offsetX,
              onChanged: (data) {
                setState(() => _offsetX = data);
              },
              min: 0,
              max: 80,
              divisions: 80,
              label: '$_offsetX',
              activeColor: Colors.green,
              inactiveColor: Colors.grey,
            ),
          ),
        ]),
      if (_enabledOffset)
        Row(children: [
          const Text('Popup偏移量Y'),
          Expanded(
            child: Slider(
              value: _offsetY,
              onChanged: (data) {
                setState(() => _offsetY = data);
              },
              min: 0,
              max: 80,
              divisions: 80,
              label: '$_offsetY',
              activeColor: Colors.green,
              inactiveColor: Colors.grey,
            ),
          ),
        ]),
      TapLayout(
        width: MediaQuery.of(context).size.width,
        height: 50.0,
        child: SingleTextView(
          title: '开启自定义方向指示器偏移量',
          suffix: CupertinoSwitch(value: _enabledArrowOffset, onChanged: (value) => setState(() => _enabledArrowOffset = value)),
        ),
      ),
      if (_enabledArrowOffset)
        Row(children: [
          const Text('向指示器偏移量X'),
          Expanded(
            child: Slider(
              value: _offsetArrowX,
              onChanged: (data) {
                setState(() => _offsetArrowX = data);
              },
              min: 0,
              max: 80,
              divisions: 80,
              label: '$_offsetArrowX',
              activeColor: Colors.green,
              inactiveColor: Colors.grey,
            ),
          ),
        ]),
      if (_enabledArrowOffset)
        Row(children: [
          const Text('向指示器偏移量Y'),
          Expanded(
            child: Slider(
              value: _offsetArrowY,
              onChanged: (data) {
                setState(() => _offsetArrowY = data);
              },
              min: 0,
              max: 80,
              divisions: 80,
              label: '$_offsetArrowY',
              activeColor: Colors.green,
              inactiveColor: Colors.grey,
            ),
          ),
        ]),
    ]);
  }
}
