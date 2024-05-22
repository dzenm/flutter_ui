import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../base/base.dart';
import '../study_model.dart';

/// 浮动的导航栏和PopupWindow
class FloatNavigationPage extends StatefulWidget {
  const FloatNavigationPage({super.key});

  @override
  State<StatefulWidget> createState() => _FloatNavigationPageState();
}

class _FloatNavigationPageState extends State<FloatNavigationPage> {
  final List<IconData> _nav = [
    Icons.search,
    Icons.ondemand_video,
    Icons.music_video,
    Icons.insert_comment,
    Icons.person,
  ]; // 导航项

  final List<String> _title = ['搜索', '视频', '音乐', '评论', '我的'];

  SocketThread? socketThread;


  @override
  void initState() {
    super.initState();

    _getData();
    socketThread = SocketThread();
    socketThread?.createIsolate();
  }

  void _getData() async {
    Directory cacheDir = FileUtil().getUserDirectory('test');
    Directory imageDir = FileUtil().getUserDirectory('image');
    Log.d('获取当前APP根目录：cacheDir=${cacheDir.path}');
    Log.d('获取当前APP根目录：imageDir=${imageDir.path}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: const Text('导航栏', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: const VideoLayout(),
        // child: ContentWidget(onTap: () {
        //   socketThread?.sendMessage('点击发送消息');
        // }),
      ),
      bottomNavigationBar: FloatNavigationBar(_nav, title: _title),
    );
  }
}

class ContentWidget extends StatelessWidget {
  final VoidCallback onTap;

  ContentWidget({super.key, required this.onTap});

  final GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    Log.d('build', tag: 'ContentWidget');
    String? username = context.watch<StudyModel>().username;
    return Column(children: [
      if (username != null) const UserNameWidget(),
      const SizedBox(height: 16),
      WrapButton(
        text: '修改',
        width: 100.0,
        onTap: () {
          String? value = context.read<StudyModel>().username;
          if (value == null) {
            context.read<StudyModel>().username = 'new value';
          } else {
            context.read<StudyModel>().username = null;
          }
        },
      ),
      const SizedBox(height: 16),
      WrapButton(
        key: _globalKey,
        text: '显示Popup',
        width: 100.0,
        onTap: () {},
      ),
      const SizedBox(height: 16),
      WrapButton(
        text: '发送消息',
        width: 100.0,
        onTap: onTap,
      ),
    ]);
  }
}

class UserNameWidget extends StatelessWidget {
  const UserNameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Log.d('build', tag: 'UserNameWidget');
    String username = context.watch<StudyModel>().username!;
    return Text(username);
  }
}

class SocketThread {
  static ReceivePort? _mainReceivePort;
  static ReceivePort? _bReceivePort;

  void createIsolate() async {
    // 创建 A 的发送接收器
    _mainReceivePort = ReceivePort();
    _mainReceivePort?.listen((message) {
      SendPort? bSendPort;
      _log("aReceivePort收到消息: message=$message");
      if (message[0] == 0) {
        bSendPort = message[1];
      } else {

      }
    });
    Isolate.spawn(doWork, _mainReceivePort!.sendPort);
  }

  void sendMessage(String message) {
    SendPort aSendPort = _mainReceivePort!.sendPort;
    aSendPort.send(message);
  }

  static void doWork(SendPort sendPort) {
    Isolate isolate = Isolate.current;
    _bReceivePort = ReceivePort();
    SendPort bSendPort = _bReceivePort!.sendPort;
    _bReceivePort?.listen((message) {
      //9.10 rp2收到消息
      _log("bReceivePort收到消息: message=$message");
    });
    // 将新isolate中创建的SendPort发送到main isolate中用于通信
    _log("sendPort准备在${isolate.debugName}发送消息");
    sendPort.send([0, bSendPort]); //3.port1发送消息,传递[0,rp2的发送器]
    // 模拟耗时5秒
    sleep(const Duration(seconds: 5));
    _log("sendPort准备在${isolate.debugName}发送消息");
    sendPort.send([1, "这条信息是 sendPort 在${isolate.debugName}中 发送的"]); //5.port1发送消息
    _log("bSendPort准备在New Isolate发送消息");
    bSendPort.send([1, "这条信息是 bSendPort 在${isolate.debugName}中 发送的"]); //6.port2发送消息
  }

  static void _log(String msg) => Log.d(msg, tag: 'SocketThread');
}
