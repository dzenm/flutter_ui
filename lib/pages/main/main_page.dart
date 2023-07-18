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
      return MainPageMobile();
    } else if (BuildConfig.isWeb) {
      return MainPageWeb();
    } else if (BuildConfig.isWindows) {
      return MainPageWindows();
    } else if (BuildConfig.isMac) {
      return MainPageMac();
    } else if (BuildConfig.isLinux) {
      return MainPageLinux();
    }
    return Container(
      child: Center(
        child: Text('未知平台'),
      ),
    );
  }
}
