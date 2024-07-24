import 'package:flutter/material.dart';

///
/// Created by a0010 on 2024/3/18 13:54
///
class EmptyView extends StatelessWidget {
  final String text;

  const EmptyView({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text),
    );
  }
}
