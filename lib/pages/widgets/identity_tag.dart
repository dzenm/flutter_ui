import 'package:flutter/material.dart';

import 'center_text.dart';

///
/// Created by a0010 on 2023/4/26 15:35
/// 实名认证标签
class IdentityTag extends StatelessWidget {
  const IdentityTag({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 15,
      width: 15,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xffffbb4b),
      ),
      child: const CenterText(
        text: '实',
        style: TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }
}
