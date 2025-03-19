import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'data.dart';
import 'wifi_direct_platform_interface.dart';

/// An implementation of [WifiDirectPlatform] that uses method channels.
class WifiDirectAndroid extends WifiDirectPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('wifi_direct');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool> initialize() async {
    final result = await methodChannel.invokeMethod<bool>('initialize');
    return result ?? false;
  }

  @override
  Future<bool> register() async {
    final result = await methodChannel.invokeMethod<bool>('register');
    _isRegister = result ?? false;
    return _isRegister;
  }

  @override
  Future<bool> unregister() async {
    final result = await methodChannel.invokeMethod<bool>('unregister');
    _isRegister = result ?? false;
    return _isRegister;
  }

  @override
  Future<bool> discoverPeers() async {
    final result = await methodChannel.invokeMethod<bool>('discoverPeers');
    return result ?? false;
  }

  @override
  Future<bool> stopPeerDiscovery() async {
    final result = await methodChannel.invokeMethod<bool>('stopPeerDiscovery');
    return result ?? false;
  }

  @override
  Future<List<WifiP2pDevice>> requestPeers() async {
    final result = await methodChannel.invokeMethod<List<Map<Object?, Object?>>>('requestPeers');

    List<WifiP2pDevice> devices = (result as List<Map<Object?, Object?>>).map((e) {
      var json = e.map((key, val) => MapEntry(key.toString(), val));
      return WifiP2pDevice.fromJson(json);
    }).toList();
    return devices;
  }

  @override
  Future<bool> connect(String address) async {
    final args = {
      'address': address,
    };
    final result = await methodChannel.invokeMethod<bool>('connect', args);
    return result ?? false;
  }

  @override
  Future<bool> disconnect() async {
    final result = await methodChannel.invokeMethod<bool>('disconnect');
    return result ?? false;
  }

  @override
  Future<WifiP2pGroup?> requestGroup() async {
    final result = await methodChannel.invokeMethod<Map<Object?, Object?>>('requestGroup');
    if (result == null) {
      return null;
    }
    var json = result.map((key, val) => MapEntry(key.toString(), val));
    return WifiP2pGroup.fromJson(json);
  }

  @override
  Future<bool> createGroup() async {
    final result = await methodChannel.invokeMethod<bool>('createGroup');
    return result ?? false;
  }

  @override
  Future<bool> removeGroup() async {
    final result = await methodChannel.invokeMethod<bool>('removeGroup');
    return result ?? false;
  }

  @override
  Future<bool> isGPSEnabled() async {
    final result = await methodChannel.invokeMethod<bool>('isGPSEnabled');
    return result ?? false;
  }

  @override
  Future<bool> openLocationSettingsPage() async {
    final result = await methodChannel.invokeMethod<bool>('openLocationSettingsPage');
    return result ?? false;
  }

  @override
  Future<bool> isWifiEnabled() async {
    final result = await methodChannel.invokeMethod<bool>('isWifiEnabled');
    return result ?? false;
  }

  @override
  Future<bool> openWifiSettingsPage() async {
    final result = await methodChannel.invokeMethod<bool>('openWifiSettingsPage');
    return result ?? false;
  }

  bool _isRegister = false;

  final EventChannel _connectionChannel = const EventChannel('wifi_direct_stream');

  Stream<String?>? _connectionStream;

  @override
  void setP2pConnectionListener(P2pConnectionListener listener) => _listener = listener;
  P2pConnectionListener? _listener;

  @override
  Stream<String?> receiveConnectionStream() {
    Stream<String?>? stream = _connectionStream;
    if (stream == null) {
      stream = _connectionChannel.receiveBroadcastStream().map((result) {
        if (result['p2pState'] != null) {
          var res = result['p2pState'] as bool;
          _listener?.onP2pState(res);
        } else if (result['peersAvailable'] != null) {
          var list = (result['peersAvailable'] as List<Object?>).map((e) {
            var json = (e as Map<Object?, Object?>).map((key, val) => MapEntry(key.toString(), val));
            return WifiP2pDevice.fromJson(json);
          }).toList();
          _listener?.onPeersAvailable(list);
        } else if (result['connectionAvailable'] != null) {
          var json = (result['connectionAvailable'] as Map<Object?, Object?>).map((key, val) => MapEntry(key.toString(), val));
          WifiP2pInfo info = WifiP2pInfo.fromJson(json);
          _listener?.onConnectionInfoAvailable(info);
        } else if (result['p2pConnection'] != null) {
          var res = result['p2pConnection'];
          if (!res) {
            _listener?.onDisconnected();
          }
        } else if (result['selfP2pChanged'] != null) {
          var json = (result['selfP2pChanged'] as Map<Object?, Object?>).map((key, val) => MapEntry(key.toString(), val));
          WifiP2pDevice selfDevice = WifiP2pDevice.fromJson(json);
          _listener?.onSelfP2pChanged(selfDevice);
        }
        return '';
        // bool isEmpty = connection == null || connection == 'null' || connection.toString().isEmpty;
        // if (isEmpty) {
        //   return null;
        //   // return WifiP2pInfo(
        //   //   groupFormed: false,
        //   //   isGroupOwner: false,
        //   //   groupOwnerAddress: '',
        //   //   isConnected: false,
        //   //   isAvailable: false,
        //   //   reason: '',
        //   //   extraInfo: '',
        //   // );
        // }
        // Map<String, dynamic> json = jsonDecode(connection);
        // List<WifiP2pDevice> clients = [];
        // WifiP2pGroup? group;
        // if (json['group'] != null) {
        //   Map<String, dynamic> map = json['group'];
        //   group = WifiP2pGroup.fromJson(map);
        // }
        //
        // bool isConnected = false;
        // if (json['isGroupOwner'] == true) {
        //   isConnected = json['isConnected'] == true && clients.isNotEmpty;
        // } else {
        //   isConnected = json['isConnected'];
        // }
        return null;
        // return WifiP2pInfo(
        //   groupFormed: json['groupFormed'],
        //   isGroupOwner: json['isGroupOwner'],
        //   groupOwnerAddress: json['groupOwnerAddress'],
        //   isConnected: isConnected,
        //   isAvailable: json['isAvailable'],
        //   reason: json['reason'],
        //   extraInfo: json['extraInfo'],
        //   group: group,
        // );
      });
      _connectionStream = stream;
    }
    return stream;
  }
}

