import 'package:flutter/material.dart';
import 'package:flutter_ui/base/log/build_config.dart';
import 'package:flutter_ui/pages/main/main_page_linux.dart';
import 'package:flutter_ui/pages/main/main_page_mac.dart';
import 'package:flutter_ui/pages/main/main_page_mobile.dart';
import 'package:flutter_ui/pages/main/main_page_web.dart';
import 'package:flutter_ui/pages/main/main_page_windows.dart';

///
/// Created by a0010 on 2022/7/28 10:56
/// 主页页面
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (BuildConfig.isPhone) {
      return const MainPageMobile();
    } else if (BuildConfig.isWeb) {
      return const MainPageWeb();
    } else if (BuildConfig.isWindows) {
      return const MainPageWindows();
    } else if (BuildConfig.isMac) {
      return const MainPageMac();
    } else if (BuildConfig.isLinux) {
      return const MainPageLinux();
    }
    return const Center(
      child: Text('未知平台'),
    );
  }
}
