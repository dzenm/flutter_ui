import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';

///
/// Created by a0010 on 2024/12/30 15:58
/// 图标类的通用组件
class DeleteIcon extends StatelessWidget {
  final VoidCallback? onTap;

  const DeleteIcon({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return TapLayout(
      background: Colors.transparent,
      onTap: onTap,
      child: const Icon(
        Icons.cancel,
        size: 20,
        color: Colors.black,
      ),
    );
  }
}

/// 添加图标按钮
class AddView extends StatelessWidget {
  final String title;
  final Function()? onTap;
  final double padding;

  const AddView(this.title, this.onTap, {super.key, this.padding = 15});

  @override
  Widget build(BuildContext context) {
    return TapLayout(
      height: 40,
      background: Colors.white,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: padding),
      alignment: Alignment.centerLeft,
      onTap: onTap,
      child: Row(
        children: [
          const Icon(
            Icons.add_circle,
            color: Colors.blue,
            size: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          )
        ],
      ),
    );
  }
}

/// 指向下一级的图标布局
class ForwardView extends StatelessWidget {
  final Color? color;
  final double size;

  const ForwardView({super.key, this.color, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.keyboard_arrow_right, color: color, size: size);
  }
}
