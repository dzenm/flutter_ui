import 'package:flutter/material.dart';

class DragLayout extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DragLayoutState();
}

class _DragLayoutState extends State<DragLayout> {
  Offset offset = Offset(100, 100);

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double appBarHeight = kToolbarHeight;
    return Stack(
      children: [
        Positioned(
          left: offset.dx,
          top: offset.dy,
          child: Draggable(
            child: Text('悬浮窗'),
            childWhenDragging: Container(),
            feedback: Text('悬浮窗反馈内容'),
            // 拖动开始
            onDragStarted: () {
              print("Draggable onDragStarted");
            },
            // 拖动结束
            onDragEnd: (detail) {
              print('Draggable onDragEnd ${detail.velocity.toString()} ${detail.offset.toString()}');
            },
            // 拖动结束时拖拽到DragTarget
            onDragCompleted: () {
              print("Draggable onDragCompleted");
            },
            // 拖动结束时未拖拽到DragTarget
            onDraggableCanceled: (Velocity velocity, Offset offset) {
              print("Draggable onDraggableCanceled ${velocity.toString()} ${offset.toString()}");
              //松手的时候
              //计算偏移量需要注意减去toobar高度和全局topPadding高度
              setState(() {
                this.offset = Offset(offset.dx, offset.dy - appBarHeight - statusBarHeight);
              });
            },
          ),
        ),
      ],
    );
  }
}
