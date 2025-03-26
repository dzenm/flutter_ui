import 'dart:convert';
import 'dart:typed_data';

import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';
import 'package:pp_transfer/pp_transfer.dart';
import 'package:provider/provider.dart';

import '../../study_router.dart';
import 'pp_model.dart';

///
/// Created by a0010 on 2025/2/17 14:32
///
class WifiDirectPage extends StatelessWidget {
  const WifiDirectPage({super.key});

  @override
  Widget build(BuildContext context) {
    PPModel wifi = PPModel();
    return P2PWidget(
      notifier: wifi,
      child: Builder(builder: (context) {
        return const WifiDirectBodyPage();
      }),
    );
  }
}

class WifiDirectBodyPage extends StatefulWidget {
  const WifiDirectBodyPage({super.key});

  @override
  State<WifiDirectBodyPage> createState() => _WifiDirectBodyPageState();
}

class _WifiDirectBodyPageState extends State<WifiDirectBodyPage> with Logging {
  late Android2Android services;

  @override
  void initState() {
    super.initState();
    services = Android2Android();
    services.start();
    _initialize();
  }

  void _initialize() async {
    Future.delayed(Duration.zero, () async => await services.initialize());
  }

  @override
  void dispose() {
    services.stop();
    services.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch<LocalModel>().theme;
    return Scaffold(
      appBar: CommonBar(
        title: 'P2P',
        actions: [
          IconButton(
              onPressed: () {
                services.addMessage(TextMessage(body: utf8.encode('这是第2条消息')));
                services.addMessage(TextMessage(body: utf8.encode('11231312312')));
                services.addMessage(TextMessage(body: utf8.encode('这是第三条消息')));
                services.addMessage(TextMessage(body: utf8.encode('这是第4条消息')));
              },
              icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 100, 100, 100),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const SizedBox(height: 10),
          Selector0<ServeStatus>(
            selector: (context) => P2PWidget.of(context).status,
            builder: (c, status, w) {
              return Text('P2P状态：$status');
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: DiscoverPeers(services: services),
          ),
          Expanded(child: Container()),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void snack(String msg) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          msg,
        ),
      ),
    );
  }
}

class DiscoverPeers extends StatelessWidget {
  final Android2Android services;

  const DiscoverPeers({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    List<SocketAddress> devices = P2PWidget.of(context).devices;
    if (devices.isEmpty) {
      return const EmptyView(text: '未获取到设备');
    }
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: devices.map((device) {
        return InkWell(
          onTap: () {
            _viewInfo(context, device);
          },
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: Text(
                device.deviceName.toString().characters.first.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _viewInfo(BuildContext context, SocketAddress device) {
    showDialog(
      context: context,
      builder: (context) {
        var status = device.status;
        var isConnected = status == DeviceStatus.connected;
        String text = isConnected ? 'disconnect' : 'connect';
        return Center(
          child: AlertDialog(
            content: SizedBox(
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("name: ${device.deviceName}"),
                  Text("address: ${device.remoteAddress}"),
                  Text("isGroupOwner: ${device.isGroupOwner}"),
                  Text("status: $status"),
                  Text("isConnected: $isConnected"),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  switch (status) {
                    case DeviceStatus.connected:
                      services.removeGroup();
                      break;
                    case DeviceStatus.invited:
                      var snackBar = SnackBar(
                        content: const Text('已请求过连接'),
                        action: SnackBarAction(
                            label: '取消连接',
                            onPressed: () {
                              services.cancelConnect();
                            }),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      break;
                    case DeviceStatus.failed:
                      var snackBar = const SnackBar(
                        content: Text('连接失败，请稍后再试'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      break;
                    case DeviceStatus.available:
                      services.connect(device);
                      break;
                    case DeviceStatus.unavailable:
                      var snackBar = const SnackBar(
                        content: Text('设备不可用，暂时无法连接'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      break;
                  }
                },
                child: Text(text),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  context.pushNamed(StudyRouter.device);
                },
                child: const Text('进入会话'),
              ),
            ],
          ),
        );
      },
    );
  }
}
