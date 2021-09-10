import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../license_keyboard.dart';
import '../tap_layout.dart';

class LicenseKeyboard extends StatefulWidget {
  static double getHeight(BuildContext ctx) {
    MediaQueryData mediaQuery = MediaQuery.of(ctx);
    double itemWidth = (mediaQuery.size.width - 6 * 11) / 10;
    double height = 5.6 * itemWidth + 66;

    return height;
  }

  final KeyboardController controller;

  LicenseKeyboard({required this.controller});

  @override
  State<StatefulWidget> createState() => _LicenseKeyboardState();
}

class _LicenseKeyboardState extends State<LicenseKeyboard> {
  List<List<String>> _provinces = [
    ['京', '津', '冀', '鲁', '晋', '蒙', '辽', '吉', '黑', '沪'],
    ['苏', '浙', '皖', '闽', '赣', '豫', '鄂', '湘', '粤', '桂'],
    ['渝', '川', '贵', '云', '藏', '陕', '甘', '青'],
    ['ABC', '琼', '新', '宁', '港', '澳', '台', '删除']
  ];
  List<List<String>> _characters = [
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['省份', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '删除']
  ];
  double _itemWidth = 0, _itemHeight = 0;

  bool _showProvinces = true;

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    _itemWidth = (mediaQuery.size.width - 6 * 11) / 10;
    _itemHeight = _itemWidth * 1.4;
    return Container(
      height: _itemHeight * 4 + 4 * 6 + 40,
      width: mediaQuery.size.width,
      padding: EdgeInsets.only(left: 6),
      decoration: BoxDecoration(
        color: Color(0xffd9d9d9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TapLayout(
            height: 40,
            width: 50,
            padding: EdgeInsets.only(right: 10),
            alignment: Alignment.centerRight,
            onTap: () => widget.controller.doneAction(),
            child: RotatedBox(
              quarterTurns: 3,
              child: Icon(Icons.west_sharp, size: 20),
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildRow(_showProvinces ? _provinces[index] : _characters[index]),
                );
              },
              itemCount: 4,
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildRow(List<String> list) {
    return list.map((text) {
      if (text == 'ABC' || text == '省份') {
        return _buildItem(
          width: _itemWidth * 1.4,
          onTap: () => setState(() => _showProvinces = !_showProvinces),
          child: Text(text, style: TextStyle(color: Colors.white, fontSize: 18.0)),
        );
      } else if (text == '删除') {
        return _buildItem(
          width: _itemWidth * 1.4,
          onTap: () => widget.controller.deleteOne(),
          child: Icon(Icons.close_sharp, size: 25, color: Colors.white),
        );
      } else {
        return _buildItem(
          width: _itemWidth,
          onTap: () => widget.controller.addText(text),
          child: Text(text, style: TextStyle(color: Colors.black, fontSize: 18.0)),
        );
      }
    }).toList();
  }

  Widget _buildItem({double? width, Widget? child, GestureTapCallback? onTap}) {
    return TapLayout(
      height: _itemHeight,
      width: width,
      margin: EdgeInsets.only(right: 6, bottom: 6),
      borderRadius: BorderRadius.circular(5),
      onTap: onTap,
      child: child,
    );
  }
}
