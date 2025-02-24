///
/// Created by a0010 on 2025/2/20 10:11
///
class PeerInfo {
  final String deviceName;
  final String deviceAddress;
  final bool isGroupOwner;
  final bool isServiceDiscoveryCapable;
  final String? primaryDeviceType;
  final String? secondaryDeviceType;
  final int status;

  const PeerInfo({
    required this.deviceName,
    required this.deviceAddress,
    required this.isGroupOwner,
    required this.isServiceDiscoveryCapable,
    required this.primaryDeviceType,
    required this.secondaryDeviceType,
    required this.status,
  });
}

class WifiP2PInfo {
  final bool isConnected;
  final bool isGroupOwner;
  final String groupOwnerAddress;
  final bool groupFormed;
  final List<ClientInfo> clients;

  const WifiP2PInfo({
    required this.isConnected,
    required this.isGroupOwner,
    required this.groupOwnerAddress,
    required this.groupFormed,
    required this.clients,
  });
}

class ClientInfo {
  final String deviceName;
  final String deviceAddress;
  final bool isGroupOwner;
  final bool isServiceDiscoveryCapable;
  final String? primaryDeviceType;
  final String? secondaryDeviceType;
  final int status;

  const ClientInfo({
    required this.deviceName,
    required this.deviceAddress,
    required this.isGroupOwner,
    required this.isServiceDiscoveryCapable,
    required this.primaryDeviceType,
    required this.secondaryDeviceType,
    required this.status,
  });

// TODO add factory from json Map<String>
}
