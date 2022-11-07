import 'dart:convert';
import 'dart:io';

import 'package:flutter_ui/base/log/log.dart';
import 'package:provider/provider.dart';

///
/// Created by a0010 on 2022/9/1 11:56
///
class DeviceUtil {
  /// 获取内网IP
  static Future<String> getIntranetIP() async {
    String network = '';
    List<NetworkInterface> interfaces = await NetworkInterface.list(
      includeLoopback: false,
      type: InternetAddressType.any,
    );
    network = "";
    interfaces.forEach((interface) {
      network += "### name: ${interface.name}\n";
      int i = 0;
      interface.addresses.forEach((address) {
        network += "${i++}) ${address.address}\n";
      });
    });
    return network;
  }

  static Future<String> getExternalIP() async {
    String network = '';
    // 外网ip
    RegExp ipRegexp = RegExp(r'((?:(?:25[0-5]|2[0-4]\d|(?:1\d{2}|[1-9]?\d))\.){3}(?:25[0-5]|2[0-4]\d|(?:1\d{2}|[1-9]?\d)))');
    String url = 'http://www.ip.cn/';
    HttpClientRequest request = await HttpClient().getUrl(Uri.parse(url));
    HttpClientResponse response = await request.close();
    response.transform(utf8.decoder).forEach((line) {
      ipRegexp.allMatches(line).forEach((match) {
        network = match.group(0).toString();
      });
    });
    return network;
  }

  static Future<String> getIP() async {
    String url = 'http://pv.sohu.com/cityjson?ie=utf-8';
    HttpClientRequest request = await HttpClient().getUrl(Uri.parse(url));
    HttpClientResponse response = await request.close();
    StringBuffer sb = StringBuffer();
    response.transform(utf8.decoder).forEach((line) {
      sb.write(line);
    });
    return sb.toString();
  }
}
