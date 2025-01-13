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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonBar(
        title: 'Gif图片播放',
      ),
      body: FutureBuilder<bool>(
        future: _request(),
        builder: (context, snapshot) {
          return const GifView(
            image: AssetImage(Assets.bottleThrow),
            autostart: Autostart.loop,
          );
        },
      ),
    );
  }

  Future<bool> _request() async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }
}
