import 'package:flutter/material.dart';
import 'package:flutter_ui/utils/taost.dart';

/// 应用全局悬浮框
class AppFloatBox extends StatefulWidget {
  @override
  _AppFloatBoxState createState() => _AppFloatBoxState();
}

class _AppFloatBoxState extends State<AppFloatBox> {
  Offset offset = Offset(10, kToolbarHeight + 40);

  Offset _calOffset(Size size, Offset offset, Offset nextOffset) {
    double dx = 0;
    if (offset.dx + nextOffset.dx <= 0) {
      dx = 0;
    } else if (offset.dx + nextOffset.dx >= (size.width - 50)) {
      dx = size.width - 50;
    } else {
      dx = offset.dx + nextOffset.dx;
    }
    double dy = 0;
    if (offset.dy + nextOffset.dy >= (size.height - 100)) {
      dy = size.height - 100;
    } else if (offset.dy + nextOffset.dy <= kToolbarHeight) {
      dy = kToolbarHeight;
    } else {
      dy = offset.dy + nextOffset.dy;
    }
    return Offset(
      dx,
      dy,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        highlightColor: Colors.transparent,
        appBarTheme: AppBarTheme.of(context).copyWith(
          brightness: Brightness.dark,
        ),
      ),
      child: Positioned(
        left: offset.dx,
        top: offset.dy,
        child: GestureDetector(
          onPanUpdate: (detail) {
            setState(() {
              offset = _calOffset(MediaQuery.of(context).size, offset, detail.delta);
            });
          },
          onTap: () {
            showToast('你戳到我了');
          },
          onPanEnd: (detail) {},
          child: Container(
            alignment: Alignment.center,
            height: 64,
            width: 64,
            child: Text('悬浮窗',  style: TextStyle(fontSize: 14)),
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle, // 可以设置角度，BoxShape.circle 直接圆形
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 8)
              ]
            ),
          ),
        ),
      ),
    );
  }
}
