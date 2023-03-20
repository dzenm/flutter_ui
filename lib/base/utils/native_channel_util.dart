import 'dart:io';

import 'package:flutter/services.dart';

///
/// Created by a0010 on 2022/3/22 09:38
/// 与原生进行通信的通道
///
class NativeChannelUtil {
  static var _logPrint;

  static void init({void Function(dynamic msg, {String tag})? logPrint}) {
    _logPrint = logPrint;
  }

  // 点击返回键回退到手机桌面而不是结束当前页面
  static Future<bool> onBackToDesktop() async {
    if (!Platform.isAndroid) return false;
    MethodChannel channel = MethodChannel('channel/android/backToDesktop');
    try {
      // 通知安卓返回,到手机桌面
      bool out = await channel.invokeMethod('backToDesktop');
      return out;
    } on PlatformException catch (e) {
      log(e.message);
    }
    return false;
  }

  // 启动一个新的服务
  static Future<bool> startVideoService() async {
    if (!Platform.isAndroid) return false;
    MethodChannel channel = MethodChannel('channel/android/startVideoService');
    // 通知安卓返回,到手机桌面
    try {
      String data = await channel.invokeMethod('startVideoService');
      log('从Android端Service返回数据: data=$data');
      return true;
    } on PlatformException catch (e) {
      log(e.message);
    }
    return false;
  }

  // 启动原生HomeActivity
  static Future<bool> startHomeActivity() async {
    if (!Platform.isAndroid) return false;
    try {
      MethodChannel channel = MethodChannel('channel/android/homeActivity');
      // 通知安卓返回,到手机桌面
      Map<String, dynamic> inData = {'message': '我是来自Flutter传递的数据'};
      String outData = await channel.invokeMethod('startHomeActivity', inData);
      log('HomeActivity数据: outData=$outData, inData=$inData');
      return true;
    } on PlatformException catch (e) {
      log(e.message);
    }
    return false;
  }

  static void log(dynamic text) => _logPrint == null ? null : _logPrint!(text, tag: 'NativeChannelUtil');
}
