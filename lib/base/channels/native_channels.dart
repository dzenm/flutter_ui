import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_ui/base/log/log.dart';

class NativeChannels {
  static const String TAG = 'NativeChannels';

  // 管理返回键操作渠道
  static const BACK_TO_DESKTOP_CHANNEL = 'android/channel/backToDesktop';

  // 启动服务渠道
  static const START_VIDEO_SERVICE_SERVICE = 'android/channel/startVideoService';

  // 启动NaughtyActivity渠道
  static const START_NAUGHTY_ACTIVITY_CHANNEL = 'android/channel/startNaughtyActivity';

  // 启动HomeActivity渠道
  static const START_HOME_ACTIVITY_CHANNEL = 'android/channel/homeActivity';

  // 启动NaviDrivingActivity渠道
  static const START_NAVI_DRIVING_ACTIVITY_CHANNEL = 'android/channel/naviDrivingActivity';

  // 启动WalkNaviActivity渠道
  static const START_WALK_NAVI_ACTIVITY_CHANNEL = 'android/channel/walkNaviActivity';

  // 点击返回键回退到手机桌面而不是结束当前页面
  static Future<bool> onBackToDesktop() async {
    if (Platform.isAndroid) {
      final channel = MethodChannel(BACK_TO_DESKTOP_CHANNEL);
      // 通知安卓返回,到手机桌面
      try {
        final bool out = await channel.invokeMethod('backToDesktop');
        return Future.value(out);
      } on PlatformException catch (e) {
        print(e.message);
      }
      return Future.value(false);
    }
    return Future.value(false);
  }

  // 启动一个新的服务
  static Future<bool> startVideoService() async {
    if (Platform.isAndroid) {
      final channel = MethodChannel(START_VIDEO_SERVICE_SERVICE);
      // 通知安卓返回,到手机桌面
      try {
        final String data = await channel.invokeMethod('startVideoService');
        Log.d('服务返回数据: $data', tag: TAG);
        return Future.value(true);
      } on PlatformException catch (e) {
        print(e.message);
      }
      return Future.value(false);
    }
    return Future.value(false);
  }

  // 启动原生NaughtyActivity
  static Future<bool> startNaughtyActivity() async {
    if (Platform.isAndroid) {
      try {
        final channel = MethodChannel(START_NAUGHTY_ACTIVITY_CHANNEL);
        // 通知安卓返回,到手机桌面
        Map<String, dynamic> result = {'message': '我从Flutter页面回来了'};
        final String out = await channel.invokeMethod('startNaughtyActivity');
        Log.d('NaughtyActivity数据: $out', tag: TAG);
        return Future.value(true);
      } on PlatformException catch (e) {
        print(e.message);
      }
    }
    return Future.value(false);
  }

  // 启动原生HomeActivity
  static Future<bool> startHomeActivity() async {
    if (Platform.isAndroid) {
      try {
        final channel = MethodChannel(START_HOME_ACTIVITY_CHANNEL);
        // 通知安卓返回,到手机桌面
        Map<String, dynamic> result = {'message': '我从Flutter页面回来了'};
        final String out = await channel.invokeMethod('startHomeActivity');
        Log.d('HomeActivity数据: $out', tag: TAG);
        return Future.value(true);
      } on PlatformException catch (e) {
        print(e.message);
      }
    }
    return Future.value(false);
  }

  // 启动原生NaviDrivingActivity
  static Future<bool> startNaviDrivingActivity() async {
    if (Platform.isAndroid) {
      try {
        final channel = MethodChannel(START_NAVI_DRIVING_ACTIVITY_CHANNEL);
        // 通知安卓返回,到手机桌面
        Map<String, dynamic> result = {'message': '我从Flutter页面回来了'};
        final String out = await channel.invokeMethod('startNaviDrivingActivity');
        Log.d('NaviDrivingActivity数据: $out', tag: TAG);
        return Future.value(true);
      } on PlatformException catch (e) {
        print(e.message);
      }
    }
    return Future.value(false);
  }

  // 启动原生WalkNaviActivity
  static Future<bool> startWalkNaviActivity() async {
    if (Platform.isAndroid) {
      try {
        final channel = MethodChannel(START_WALK_NAVI_ACTIVITY_CHANNEL);
        // 通知安卓返回,到手机桌面
        Map<String, dynamic> result = {'message': '我从Flutter页面回来了'};
        final String out = await channel.invokeMethod('startWalkNaviActivity');
        Log.d('NaviDrivingActivity数据: $out', tag: TAG);
        return Future.value(true);
      } on PlatformException catch (e) {
        print(e.message);
      }
    }
    return Future.value(false);
  }
}
