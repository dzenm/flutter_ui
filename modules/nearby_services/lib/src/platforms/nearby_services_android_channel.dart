import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../entities/p2p_entity.dart';
import 'nearby_services_platform_interface.dart';

/// An implementation of [NearbyServicesPlatform] that uses method channels.
class MethodChannelNearbyServices extends NearbyServicesPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('nearby_services');

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
    return result ?? false;
  }

  @override
  Future<bool> unregister() async {
    final result = await methodChannel.invokeMethod<bool>('unregister');
    return result ?? false;
  }

  @override
  Future<bool> discover() async {
    final result = await methodChannel.invokeMethod<bool>('discover');
    return result ?? false;
  }

  @override
  Future<bool> stopDiscovery() async {
    final result = await methodChannel.invokeMethod<bool>('stopDiscovery');
    return result ?? false;
  }

  @override
  Future<bool> connect(String address) async {
    final args = {
      "address": address,
    };
    final result = await methodChannel.invokeMethod<bool>("connect", args);
    return result ?? false;
  }

  @override
  Future<bool> disconnect() async {
    final result = await methodChannel.invokeMethod<bool>('disconnect');
    return result ?? false;
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

  final EventChannel _peersChannel = const EventChannel("nearby_services_discover_peers");

  final EventChannel _connectionChannel = const EventChannel("nearby_services_connection");

  @override
  Stream<List<PeerInfo>> discoverPeersStream() {
    Stream<List<PeerInfo>> stream = _peersChannel.receiveBroadcastStream().map((peers) {
      if (peers == null) return [];
      Iterable iterable = jsonDecode(peers);
      List<PeerInfo> result = iterable
          .map((json) => PeerInfo(
                deviceName: json["deviceName"],
                deviceAddress: json["deviceAddress"],
                isGroupOwner: json["isGroupOwner"],
                isServiceDiscoveryCapable: json["isServiceDiscoveryCapable"],
                primaryDeviceType: json["primaryDeviceType"],
                secondaryDeviceType: json["secondaryDeviceType"],
                status: json["status"],
              ))
          .toList();
      return result;
    });
    return stream;
  }

  @override
  Stream<WifiP2PInfo> wifiP2PStream() {
    Stream<WifiP2PInfo> stream = _connectionChannel.receiveBroadcastStream().map((wifiP2P) {
      if (wifiP2P == "null") {
        return const WifiP2PInfo(
          isConnected: false,
          isGroupOwner: false,
          groupOwnerAddress: "",
          groupFormed: false,
          clients: [],
        );
      }
      Map<String, dynamic>? json = jsonDecode(wifiP2P);
      if (json != null) {
        List<ClientInfo> clients = [];
        if ((json["clients"] as List).isNotEmpty) {
          for (var i in json["clients"]) {
            Map<String, dynamic> client = (i as Map<String, dynamic>);
            clients.add(ClientInfo(
              deviceName: client["deviceName"],
              deviceAddress: client["deviceAddress"],
              isGroupOwner: client["isGroupOwner"],
              isServiceDiscoveryCapable: client["isServiceDiscoveryCapable"],
              primaryDeviceType: client["primaryDeviceType"],
              secondaryDeviceType: client["secondaryDeviceType"],
              status: client["status"],
            ));
          }
        }

        bool isConnected = false;
        if (json["isGroupOwner"] == true) {
          isConnected = json["isConnected"] == true && clients.isNotEmpty;
        } else {
          isConnected = json["isConnected"];
        }
        return WifiP2PInfo(
          isConnected: isConnected,
          isGroupOwner: json["isGroupOwner"],
          groupOwnerAddress: json["groupOwnerAddress"] == "null" ? "" : json["groupOwnerAddress"],
          groupFormed: json["groupFormed"],
          clients: clients,
        );
      } else {
        return const WifiP2PInfo(
          isConnected: false,
          isGroupOwner: false,
          groupOwnerAddress: "",
          groupFormed: false,
          clients: [],
        );
      }
    });
    return stream;
  }
}
