import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';
import 'package:pp_transfer/pp_transfer.dart';
import 'package:provider/provider.dart';

import '../../study_router.dart';
import 'pp_model.dart';

///
/// Created by a0010 on 2025/2/17 14:32
///
class WifiDirectPage extends StatefulWidget {
  const WifiDirectPage({super.key});

  @override
  State<WifiDirectPage> createState() => _WifiDirectPageState();
}

class _WifiDirectPageState extends State<WifiDirectPage> with Logging {
  late Android2Android services;

  @override
  void initState() {
    super.initState();
    services = Android2Android();
  }

  void _initialize(bool isGroupOwner) async {
    Future.delayed(
      Duration.zero,
      () async => await services.initialize(
        isGroupOwner: isGroupOwner,
      ),
    );
  }

  @override
  void dispose() {
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
          Builder(builder: (context) {
            return IconButton(
              onPressed: () {
                PersistentBottomSheetController controller = TransferView.showView(context, services);
              },
              icon: const Icon(Icons.file_copy_rounded),
            );
          }),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 100, 100, 100),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Expanded(
          child: _buildItemView(context, '我要创建群组', Colors.yellow, () {
            _initialize(true);
          }),
        ),
        Expanded(
          child: _buildItemView(context, '我要加入群组', Colors.green, () {
            _initialize(false);
          }),
        ),
      ]),
    );
  }

  Widget _buildItemView(
    BuildContext context,
    String title,
    Color color,
    GestureTapCallback onTap,
  ) {
    AppTheme theme = context.watch<LocalModel>().theme;
    return TapLayout(
      background: color,
      onTap: onTap,
      child: Center(
        child: Text(
          title,
          style: TextStyle(color: theme.primaryText),
        ),
      ),
    );
  }
}

class TransferView extends StatelessWidget {
  final Android2Android services;

  const TransferView({super.key, required this.services});

  static PersistentBottomSheetController showView(BuildContext context, Android2Android services) {
    return showBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      constraints: const BoxConstraints(maxHeight: 600),
      builder: (context) {
        AppTheme theme = context.watch<LocalModel>().theme;
        return Container(
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: TransferView(services: services),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildTitle(),
      const DividerView(),
      const SizedBox(height: 10),
      Selector0<ServeStatus>(
        selector: (context) => Provider.of<PPModel>(context).status,
        builder: (c, status, w) {
          return Text('P2P状态：$status');
        },
      ),
      const SizedBox(height: 16),
      Expanded(
          child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Selector0<List<SocketAddress>>(
          selector: (context) => Provider.of<PPModel>(context).devices,
          builder: (c, devices, w) {
            return PeersView(devices: devices, onTap: (device) => _viewInfo(context, device));
          },
        ),
      )),
      const DividerView(),
      _buildUserInfo(),
    ]);
  }

  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 56,
        child: Stack(children: [
          Align(
            child: Text(
              '隔空投送副本',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '完成',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ]),
      ),
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

  Widget _buildUserInfo() {
    return const SizedBox(
      height: 64,
      child: Row(children: [
        SizedBox(width: 32),
        Text(
          '用户信息',
          style: TextStyle(fontSize: 18),
        ),
      ]),
    );
  }
}

class PeersView extends StatefulWidget {
  final List<SocketAddress> devices;
  final void Function(SocketAddress) onTap;
  final double size;

  const PeersView({
    super.key,
    required this.devices,
    required this.onTap,
    this.size = 80,
  });

  @override
  State<PeersView> createState() => _PeersViewState();
}

class _PeersViewState extends State<PeersView> {
  List<SocketAddress> devices = [];

  @override
  void initState() {
    super.initState();
    devices = widget.devices;
  }

  @override
  Widget build(BuildContext context) {
    double size = widget.size;
    if (devices.isEmpty) {
      return const EmptyView(text: '未获取到设备');
    }
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: devices.map((device) {
        return Column(mainAxisSize: MainAxisSize.min, children: [
          TapLayout(
            width: size,
            height: size,
            border: device.isGroupOwner ? Border.all(color: Colors.yellow, width: 2) : null,
            background: device.isGroupOwner ? Colors.yellow : Colors.grey,
            onTap: () {
              widget.onTap(device);
            },
            isCircle: true,
            child: Center(
              child: Text(
                (device.deviceName.isEmpty ? 'Empty' : device.deviceName).characters.first.toUpperCase(),
                style: TextStyle(color: Colors.white, fontSize: size / 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(device.deviceName),
          const SizedBox(height: 12),
          Text(device.remoteAddress),
        ]);
      }).toList(),
    );
  }
}
