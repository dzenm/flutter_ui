import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';

///
/// Created by a0010 on 2025/1/7 11:54
///
class GifPage extends StatefulWidget {
  const GifPage({super.key});

  @override
  State<GifPage> createState() => _GifPageState();
}

class _GifPageState extends State<GifPage> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonBar(
        title: 'Gif图片播放',
      ),
      body: GifView(
        image: const AssetImage(Assets.bottleThrow),
        controller: _controller,
        autostart: Autostart.loop,
        onFetchCompleted: () {
          _controller.reset();
          _controller.forward();
        },
      ),
    );
  }
}
