import 'package:flutter/material.dart';

import 'center_text.dart';

class VipTag extends StatelessWidget {
  final String text;

  const VipTag({super.key, this.text = 'VIP'});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      alignment: Alignment.center,
      color: Colors.amber,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: CenterText(
        text: text,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }
}
