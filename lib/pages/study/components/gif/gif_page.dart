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
  late AnimationController _controller1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller1 = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _controller1.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonBar(
        title: 'Gif图片播放',
      ),
      body: FutureBuilder<bool>(
        future: _request(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return GifView(
              image: const AssetImage(Assets.bottleThrow),
              controller: _controller,
              autostart: Autostart.loop,
              onFetchCompleted: () {
                _controller.reset();
                _controller.forward();
              },
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            return GifView(
              image: const AssetImage(Assets.bottlePickup),
              controller: _controller1,
              autostart: Autostart.once,
              onFetchCompleted: () {
                _controller1.reset();
                _controller1.forward();
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<bool> _request() async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }
}
