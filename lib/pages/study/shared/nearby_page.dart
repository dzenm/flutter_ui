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
    services.register();
    _initialize();
  }

  void _initialize() async {
    await services.initialize();
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
        title: 'P2P',
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: ListView(children: [
          const SizedBox(height: 10),
          Selector0<ServeStatus>(
            selector: (context) => P2PWidget.of(context).status,
            builder: (c, status, w) {
              return Text('P2P状态：$status');
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              services.discoverDevices();
            },
            child: const Text("I am to join a group"),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: DiscoverPeers(
              onTap: (device) {
                services.connect(device);
              },
            ),
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
}

class DiscoverPeers extends StatelessWidget {
  final void Function(SocketAddress device) onTap;

  const DiscoverPeers({super.key, required this.onTap});

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
