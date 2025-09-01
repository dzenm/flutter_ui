import 'package:flutter/material.dart';

///
/// Created by a0010 on 2025/9/1 09:08
///
///
class GridImageView extends StatefulWidget {
  const GridImageView({super.key});

  @override
  State<GridImageView> createState() => _GridImageViewState();
}

class _GridImageViewState extends State<GridImageView> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double w = size.width;
    double h = size.width;
    Size limitSize = Size(w, h);
    return const Placeholder();
  }
}

class OneImage extends StatelessWidget {
  const OneImage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
