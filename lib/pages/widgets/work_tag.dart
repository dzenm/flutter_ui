import 'package:flutter/material.dart';

import 'center_text.dart';

///
/// Created by a0010 on 2023/4/26 15:39
/// 工作中标签
class WorkTag extends StatelessWidget {
  final bool small;

  const WorkTag({
    super.key,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 5 : 10, vertical: small ? 1 : 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: const Color(0xffe75d58),
      ),
      child: CenterText(
        text: '工作中',
        style: TextStyle(color: Colors.white, fontSize: small ? 8 : 10),
      ),
    );
  }
}
