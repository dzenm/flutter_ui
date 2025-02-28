import 'package:wifi_direct/wifi_direct.dart';

import '../service/connection.dart';

///
/// Created by a0010 on 2025/2/26 11:26
///
class WifiDirectConnectionClient implements WifiConnection {
  final WifiDirect client = WifiDirect();

  @override
  Future<bool> get isPrepare => throw UnimplementedError();

  @override
  bool get isConnected => throw UnimplementedError();

  @override
  bool get isTransiting => throw UnimplementedError();

  @override
  Future<bool> initialize({bool isGroup = true}) async {
    if (!await client.initialize()) return false;
    if (!await client.register()) return false;

    if (isGroup) {
      if (await client.createGroup()) {
        return true;
      }
    } else {
      if (await client.discover()) {
        return true;
      }
    }
    return false;
  }

  Stream<List<WifiP2pDevice>> get discoverPeersStream => client.getDiscoverPeersStream();

  Stream<WifiP2pInfo> get wifiStream => client.getWifiStream();

  @override
  void connect(String deviceAddress) async {
    await client.connect(deviceAddress);
  }

  @override
  void dispose() async {
    await client.unregister();
    client.cancel();
  }
}
