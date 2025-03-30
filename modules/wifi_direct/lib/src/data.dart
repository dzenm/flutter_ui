///
/// Created by a0010 on 2025/2/20 10:11
///
class WifiP2pConnection {
  /// Indicates whether network connectivity exists and it is possible to establish connections and pass
  /// data.
  /// Always call this before attempting to perform data transactions.
  final bool isConnected;

  /// Indicates whether network connectivity is possible. A network is unavailable when a persistent or
  /// semi-persistent condition prevents the possibility of connecting to that network. Examples include
  ///
  /// The device is out of the coverage area for any network of this type.
  /// The device is on a network other than the home network (i.e., roaming), and data roaming has been
  /// disabled.
  /// The device's radio is turned off, e.g., because airplane mode is enabled.
  final bool isAvailable;

  /// Report the reason an attempt to establish connectivity failed, if one is available.
  final String reason;

  /// Report the extra information about the network state, if any was provided by the lower networking
  /// layers.
  final String extraInfo;

  /// Indicates if a p2p group has been successfully formed
  final bool groupFormed;

  /// Indicates if the current device is the group owner
  final bool isGroupOwner;

  /// Group owner address
  final String groupOwnerAddress;

  /// @see [WifiP2pGroup]
  final WifiP2pGroup? group;

  WifiP2pConnection({
    required this.isConnected,
    required this.isAvailable,
    required this.reason,
    required this.extraInfo,
    required this.groupFormed,
    required this.isGroupOwner,
    required this.groupOwnerAddress,
    this.group,
  });

  factory WifiP2pConnection.fromJson(Map<String, dynamic> json) {
    var group = json['group'] == null ? null : (json['group'] as Map<Object?, Object?>).map((key, val) => MapEntry(key.toString(), val));
    return WifiP2pConnection(
      isConnected: json['isConnected'] ?? false,
      isAvailable: json['isAvailable'] ?? false,
      reason: json['reason'] ?? '',
      extraInfo: json['extraInfo'] ?? '',
      groupFormed: json['groupFormed'] ?? false,
      isGroupOwner: json['isGroupOwner'] ?? false,
      groupOwnerAddress: json['groupOwnerAddress'] ?? '',
      group: group == null ? null : WifiP2pGroup.fromJson(group),
    );
  }

  Map<String, dynamic> toJson() => {
        'groupFormed': groupFormed,
        'isGroupOwner': isGroupOwner,
        'groupOwnerAddress': groupOwnerAddress,
        'isConnected': isConnected,
        'isAvailable': isAvailable,
        'reason': reason,
        'extraInfo': extraInfo,
        'group': group?.toJson(),
      };
}

/// 群组信息
class WifiP2pGroup {
  /// Get the network name (SSID) of the group. Legacy Wi-Fi clients will discover the p2p group using
  /// the network name.
  final String networkName;

  /// et the passphrase of the group. This function will return a valid passphrase only at the group
  /// owner. Legacy Wi-Fi clients will need this passphrase alongside network name obtained from
  /// getNetworkName() to join the group
  final String passphrase;

  /// Check whether this device is the group owner of the created p2p group
  final bool isGroupOwner;

  /// Get the details of the group owner as a [WifiP2pDevice] object
  final WifiP2pDevice? owner;

  /// Get the list of clients currently part of the p2p group
  final List<WifiP2pDevice> clients;

  /// Get the interface name on which the group is created
  final String interfaceName;

  /// The network ID of the P2P group in wpa_supplicant.
  /// if Build.VERSION less than 30, it return -1
  final int networkId;

  /// Get the operating frequency (in MHz) of the p2p group
  /// if Build.VERSION less than 29, it return -1
  final int frequency;

  WifiP2pGroup({
    required this.networkName,
    required this.passphrase,
    required this.isGroupOwner,
    this.owner,
    required this.clients,
    required this.interfaceName,
    required this.networkId,
    required this.frequency,
  });

  factory WifiP2pGroup.fromJson(Map<String, dynamic> json) {
    var owner = json['owner'] == null ? null : json['owner'] as Map<Object?, Object?>;
    var ownerJson = owner?.map((key, val) => MapEntry(key.toString(), val));
    var clients = json['clients'] == null ? null : json['clients'] as List<Object?>;
    var clientsJson = clients?.map((e) {
          return (e as Map<Object?, Object?>).map((key, val) => MapEntry(key.toString(), val));
        }).toList() ??
        [];
    return WifiP2pGroup(
      networkName: json['networkName'] ?? '',
      passphrase: json['passphrase'] ?? '',
      isGroupOwner: json['isGroupOwner'] ?? false,
      owner: ownerJson == null ? null : WifiP2pDevice.fromJson(ownerJson),
      clients: clientsJson.map((e) => WifiP2pDevice.fromJson(e)).toList(),
      interfaceName: json['interfaceName'] ?? '',
      networkId: json['networkId'] ?? 0,
      frequency: json['frequency'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'networkName': networkName,
        'passphrase': passphrase,
        'isGroupOwner': isGroupOwner,
        'owner': owner?.toJson(),
        'clients': clients.map((e) => e.toJson()).toList(),
        'interfaceName': interfaceName,
        'networkId': networkId,
        'frequency': frequency,
      };
}

/// 设备信息
class WifiP2pDevice {
  /// The device name is a user friendly string to identify a Wi-Fi p2p device
  final String deviceName;

  /// The device MAC address uniquely identifies a Wi-Fi p2p device
  final String deviceAddress;

  /// Primary device type identifies the type of device. For example, an application could filter the
  /// devices discovered to only display printers if the purpose is to enable a printing action from the
  /// user. See the Wi-Fi Direct technical specification for the full list of standard device types supported
  final String? primaryDeviceType;

  /// Secondary device type is an optional attribute that can be provided by a device in addition to the
  /// primary device type.
  final String? secondaryDeviceType;

  /// Device connection status
  final DeviceStatus status;

  /// Returns true if WPS push button configuration is supported
  final bool wpsPbcSupported;

  /// Returns true if WPS keypad configuration is supported
  final bool wpsKeypadSupported;

  /// Returns true if WPS display configuration is supported
  final bool wpsDisplaySupported;

  /// Returns true if the device is capable of service discovery
  final bool isServiceDiscoveryCapable;

  /// Returns true if the device is a group owner
  final bool isGroupOwner;

  const WifiP2pDevice({
    required this.deviceName,
    required this.deviceAddress,
    required this.primaryDeviceType,
    required this.secondaryDeviceType,
    required this.status,
    required this.wpsPbcSupported,
    required this.wpsKeypadSupported,
    required this.wpsDisplaySupported,
    required this.isServiceDiscoveryCapable,
    required this.isGroupOwner,
  });

  factory WifiP2pDevice.fromJson(Map<String, dynamic> json) {
    return WifiP2pDevice(
      deviceName: json['deviceName'] ?? '',
      deviceAddress: json['deviceAddress'] ?? '',
      primaryDeviceType: json['primaryDeviceType'] ?? '',
      secondaryDeviceType: json['secondaryDeviceType'] ?? '',
      status: DeviceStatus.parse(json['status']),
      wpsPbcSupported: json['wpsPbcSupported'] ?? false,
      wpsKeypadSupported: json['wpsKeypadSupported'] ?? false,
      wpsDisplaySupported: json['wpsDisplaySupported'] ?? false,
      isServiceDiscoveryCapable: json['isServiceDiscoveryCapable'] ?? false,
      isGroupOwner: json['isGroupOwner'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'deviceName': deviceName,
        'deviceAddress': deviceAddress,
        'primaryDeviceType': primaryDeviceType,
        'secondaryDeviceType': secondaryDeviceType,
        'status': status.value,
        'wpsPbcSupported': wpsPbcSupported,
        'wpsKeypadSupported': wpsKeypadSupported,
        'wpsDisplaySupported': wpsDisplaySupported,
        'isServiceDiscoveryCapable': isServiceDiscoveryCapable,
        'isGroupOwner': isGroupOwner,
      };

  bool get isConnected => status == DeviceStatus.connected;
}

/// 设备连接状态
enum DeviceStatus {
  connected(0),
  invited(1),
  failed(2),
  available(3),
  unavailable(4);

  final int value;

  const DeviceStatus(this.value);

  static DeviceStatus parse(int? value) {
    for (var item in DeviceStatus.values) {
      if (item.value == value) return item;
    }
    return DeviceStatus.unavailable;
  }
}

abstract interface class P2pConnectionListener {
  void onP2pState(bool enabled);

  void onPeersAvailable(List<WifiP2pDevice> peers);

  void onConnectionInfoAvailable(WifiP2pConnection connection);

  void onSelfP2pChanged(WifiP2pDevice device);

  void onDiscoverChanged(bool isDiscover);
}
