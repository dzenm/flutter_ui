import 'package:flutter/material.dart';

///  自定义 键盘 按钮
class CustomKbBtn extends StatefulWidget {
  final String text;
  final callback;

  CustomKbBtn({Key? key, this.text = '', this.callback}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ButtonState();
}

class ButtonState extends State<CustomKbBtn> {
  ///回调函数执行体
  var backMethod;

  void back() {
    widget.callback('$backMethod');
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    var _screenWidth = mediaQuery.size.width;
    return Container(
      height: 50.0,
      width: _screenWidth / 3,
      child: OutlineButton(
        // 直角
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
        // 边框颜色
        borderSide: BorderSide(color: Color(0x10333333)),
        child: Text(
          widget.text,
          style: TextStyle(color: Color(0xff333333), fontSize: 20.0),
        ),
        onPressed: back,
      ),
    );
  }
}
