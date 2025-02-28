import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';
import 'package:pp_transfer/pp_transfer.dart';
import 'package:provider/provider.dart';

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
  List<WifiP2pDevice> _peers = [];
  WifiP2pInfo? _wifiP2PInfo;

  @override
  void initState() {
    super.initState();
    services = Android2Android();
  }

  void _init(bool isGroup) async {
    services.discoverPeersStream.listen((data) {
      _peers = data;
      setState(() {});
    });
    services.wifiStream.listen((data) {
      _wifiP2PInfo = data;
      setState(() {});
    });
    services.initialize(isGroup: isGroup);
  }

  @override
  void dispose() {
    services.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch<LocalModel>().theme;
    String ip = '';
    Widget widget = const SizedBox.shrink();
    if (_wifiP2PInfo != null) {
      ip = _wifiP2PInfo?.groupOwnerAddress ?? '';
      widget = Text("connected: ${_wifiP2PInfo?.isConnected}, "
          "isGroupOwner: ${_wifiP2PInfo?.isGroupOwner}, "
          "groupFormed: ${_wifiP2PInfo?.groupFormed}, "
          "groupOwnerAddress: ${_wifiP2PInfo?.groupOwnerAddress}, "
          "clients: ${_wifiP2PInfo?.group}");
    }
    return Scaffold(
      appBar: const CommonBar(
        title: 'Wifi Direct',
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: ListView(children: [
          Text("IP: $ip"),
          widget,
          const SizedBox(height: 10),
          const Text("PEERS:"),
          SizedBox(
            height: 100,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _peers.length,
              itemBuilder: (context, index) {
                WifiP2pDevice peer = _peers[index];
                return Center(
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => Center(
                          child: AlertDialog(
                            content: SizedBox(
                              height: 200,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("name: ${peer.deviceName}"),
                                  Text("address: ${peer.deviceAddress}"),
                                  Text("isGroupOwner: ${peer.isGroupOwner}"),
                                  Text("isServiceDiscoveryCapable: ${peer.isServiceDiscoveryCapable}"),
                                  Text("primaryDeviceType: ${peer.primaryDeviceType}"),
                                  Text("secondaryDeviceType: ${peer.secondaryDeviceType}"),
                                  Text("status: ${peer.status}"),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  services.connect(peer.deviceAddress);
                                  Navigator.of(context).pop();
                                },
                                child: const Text("connect"),
                              ),
                            ],
                          ),
                        ),
                      );
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
                          peer.deviceName.toString().characters.first.toUpperCase(),
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
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _init(true);
            },
            child: const Text("I want to create a group"),
          ),

          ElevatedButton(
            onPressed: () {
              _init(false);
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
}
