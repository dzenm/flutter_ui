import 'package:flutter/material.dart';

import '../../base/log/build_config.dart';
import 'main_page_mobile.dart';
import 'main_page_web.dart';

///
/// Created by a0010 on 2022/7/28 10:56
/// 主页页面
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (BuildConfig.isMobile) {
      return const MainPageMobile();
    } else if (BuildConfig.isWeb) {
      return const MainPageWeb();
    } else if (BuildConfig.isDesktop) {
      return const MainPageMobile();
    }
    return const Center(
      child: Text('未知平台'),
    );
  }
}
