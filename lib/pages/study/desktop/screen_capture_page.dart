import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:provider/provider.dart';
import 'package:screen_capturer/screen_capturer.dart';

import '../../../base/base.dart';

///
/// Created by a0010 on 2024/4/7 14:31
///
class ScreenCapturePage extends StatefulWidget {
  const ScreenCapturePage({super.key});

  @override
  State<ScreenCapturePage> createState() => _ScreenCapturePageState();
}

class _ScreenCapturePageState extends State<ScreenCapturePage> {
  String _path = '';
  String? _content;
  Uint8List? _list;
  List<String> _files = [];

  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch<LocalModel>().theme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('屏幕截取', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            MaterialButton(
              textColor: Colors.white,
              color: theme.button,
              onPressed: _startCapture,
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('开始截取'),
              ]),
            ),
            const SizedBox(height: 16),
            MaterialButton(
              textColor: Colors.white,
              color: theme.button,
              onPressed: _stopCapture,
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('结束截取'),
              ]),
            ),
            const SizedBox(height: 16),
            Text('截图放置的路径：$_path'),
            const SizedBox(height: 16),
            MaterialButton(
              textColor: Colors.white,
              color: theme.button,
              onPressed: _getParse,
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('获取剪切板内容'),
              ]),
            ),
            const SizedBox(height: 16),
            const Text('剪贴板内容：', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (_content != null && _files.isEmpty) Text('$_content'),
            if (_list != null) SizedBox(height: 240, child: Image.memory(_list!)),
            if (_files.isNotEmpty) Text(_files.toString()),
            const SizedBox(height: 16),
            TextField(controller: textController, maxLines: 10),
          ]),
        ),
      ),
    );
  }

  void _startCapture() async {
    if (BuildConfig.isMacOS) {
      await ScreenCapturer.instance.requestAccess(); // 申请权限
      bool isAllowed = await ScreenCapturer.instance.isAccessAllowed(); // 检测是否拥有权限
      if (!isAllowed) {
        CommonDialog.showToast('未授予权限，无法截取');
        return;
      }
    }

    String imageName = '${DateTime.now().millisecondsSinceEpoch}.png'; // 设置图片名称
    String imagePath = '${FileUtil().getUserDirectory('images').path}/$imageName'; // 设置图片保存的路径
    CapturedData? capturedData = await ScreenCapturer.instance.capture(imagePath: imagePath);
    if (capturedData != null) {
      _path = capturedData.imagePath ?? '';
      setState(() {});
    } else {
      CommonDialog.showToast('截图被取消了');
    }
  }

  void _stopCapture() {}

  void _getParse() async {
    _content = null;
    _list = null;
    _files = [];
    _content = await Pasteboard.text;
    if (_content == null) {
      _list = await Pasteboard.image;
    }
    _files = await Pasteboard.files();
    setState(() {});
  }
}
