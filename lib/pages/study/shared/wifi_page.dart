///
/// Created by a0010 on 2025/1/15 09:43
///
import 'dart:io' show Platform;

// ignore_for_file: deprecated_member_use, package_api_docs, public_member_api_docs
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String STA_DEFAULT_SSID = "STA_SSID";
const String STA_DEFAULT_PASSWORD = "STA_PASSWORD";

const String AP_DEFAULT_SSID = "AP_SSID";
const String AP_DEFAULT_PASSWORD = "AP_PASSWORD";

class FlutterWifiIoT extends StatefulWidget {
  const FlutterWifiIoT({super.key});

  @override
  State<StatefulWidget> createState() => _FlutterWifiIoTState();
}

class _FlutterWifiIoTState extends State<FlutterWifiIoT> {

  final TextStyle textStyle = const TextStyle(color: Colors.white);


  @override
  Widget build(BuildContext poContext) {
    return MaterialApp(
      title: Platform.isIOS ? "WifiFlutter Example iOS" : "WifiFlutter Example Android",
    );
  }
}

class PopupCommand {
  String command;
  String argument;

  PopupCommand(this.command, this.argument);
}
