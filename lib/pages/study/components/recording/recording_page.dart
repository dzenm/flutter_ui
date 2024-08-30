import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';



///
/// Created by a0010 on 2024/6/26 16:02
///
class RecordingPage extends StatefulWidget {
  const RecordingPage({super.key});

  @override
  State<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  final List<String> _items = List.generate(15, (index) => '文字内容 $index');
  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      resizeToAvoidBottomInset: false,
    );
  }
}
