import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';
import 'package:pp_transfer/pp_transfer.dart';
import 'package:provider/provider.dart';

import 'pp_model.dart';

///
/// Created by a0010 on 2025/2/17 14:32
///
class WifiDirectPage extends StatelessWidget {
  const WifiDirectPage({super.key});

  @override
  Widget build(BuildContext context) {
    WifiInfo wifi = WifiInfo();
    return WifiModel(
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

class _WifiDirectBodyPageState extends State<WifiDirectBodyPage> with Logging implements DeviceListener {
  late Android2Android services;

  @override
  void initState() {
    super.initState();
    services = Android2Android();
    _initialize();
  }

  void _initialize() async {
    await services.initialize();
    services.setOnDeviceListener(this);
  }

  @override
  void dispose() {
    services.dispose();
    services.unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch<LocalModel>().theme;
    return Scaffold(
      appBar: const CommonBar(
        title: 'Wifi Direct',
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: ListView(children: [
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            width: MediaQuery.of(context).size.width,
            child: DiscoverPeers(
              onTap: (device) {
                services.connect(device);
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              services.discoverDevices();
            },
            child: const Text("I am to join a group"),
          ),
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

  @override
  void onListen(List<SocketAddress> addresses) {
    WifiModel.read(context).updateDevices(addresses);
  }
}

class DiscoverPeers extends StatelessWidget {
  final void Function(SocketAddress device) onTap;

  const DiscoverPeers({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    List<SocketAddress> devices = WifiModel.of(context).devices;
    if (devices.isEmpty) {
      return const EmptyView(text: '未获取到设备');
    }
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: devices.length,
      itemBuilder: (context, index) {
        SocketAddress device = devices[index];
        return Center(
          child: GestureDetector(
            onTap: () {
              _viewInfo(context, device);
            },
            child: Container(
              height: 80,
              width: 80,
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
          ),
        );
      },
    );
  }

  void _viewInfo(BuildContext context, SocketAddress device) {
    showDialog(
      context: context,
      builder: (context) {
        String text = device.isConnected ? 'disconnect' : 'connect';
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
                  Text("isConnected: ${device.isConnected}"),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  onTap(device);
                  Navigator.of(context).pop();
                },
                child: Text(text),
              ),
            ],
          ),
        );
      },
    );
  }
}
