import 'package:flutter/material.dart';
import 'package:flutter_ui/base/log/build_config.dart';
import 'package:flutter_ui/pages/main/main_page_linux.dart';
import 'package:flutter_ui/pages/main/main_page_mac.dart';
import 'package:flutter_ui/pages/main/main_page_mobile.dart';
import 'package:flutter_ui/pages/main/main_page_web.dart';
import 'package:flutter_ui/pages/main/main_page_windows.dart';
import 'package:provider/provider.dart';

import '../../base/log/log.dart';
import '../../base/widgets/badge_tag.dart';
import '../../base/widgets/tap_layout.dart';
import 'main_model.dart';

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

/// 底部Item布局
class BottomNavigationBarItemView extends StatelessWidget {
  static const String _tag = 'BottomNavigationBarItemView';

  final int index;
  final PageController controller;
  final GestureTapCallback? onTap;

  BottomNavigationBarItemView({
    required this.index,
    required this.controller,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Log.d('build');

    double width = 56, height = 56;
    return TapLayout(
      height: height,
      foreground: Colors.transparent,
      onTap: () => _jumpToPage(context),
      child: Container(
        width: width,
        height: height,
        child: Stack(alignment: Alignment.center, children: [
          // 图标和文字充满Stack并居中显示
          Positioned.fill(child: _builtItem()),
          // badge固定在右上角
          Positioned(
            width: width / 2,
            height: height,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [Positioned(left: 16, top: 2, child: _buildBadge())],
            ),
          ),
        ]),
      ),
    );
  }

  /// 跳转页面
  void _jumpToPage(BuildContext context) {
    bool isSelected = context.read<MainModel>().isSelected(index);
    if (!isSelected) {
      context.read<MainModel>().selectedIndex = index;
      controller.jumpToPage(index);
      // controller.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.ease);
    }
    if (onTap != null) onTap!();
  }

  Widget _buildBadge() {
    Log.d('build badge', tag: _tag);

    return Selector<MainModel, int>(
      builder: (context, value, widget) {
        return BadgeTag(count: value);
      },
      selector: (context, model) => model.badge(index),
    );
  }

  Widget _builtItem() {
    return Selector<MainModel, int>(
      builder: (context, value, widget) {
        return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          _buildIcon(value),
          SizedBox(height: 2),
          _buildTitle(value),
        ]);
      },
      selector: (context, model) => model.selectedIndex,
    );
  }

  Widget _buildIcon(int selectIndex) {
    bool isSelected = selectIndex == index; // 是否是选中的索引
    return Selector<MainModel, IconData>(
      builder: (context, value, widget) {
        Color color = isSelected ? Colors.blue : Colors.grey.shade500;
        return Icon(value, color: color, size: 20);
      },
      selector: (context, model) => model.icon(index),
    );
  }

  Widget _buildTitle(int selectIndex) {
    bool isSelected = selectIndex == index; // 是否是选中的索引
    return Selector<MainModel, String>(
      builder: (context, value, widget) {
        Color color = isSelected ? Colors.blue : Colors.grey.shade500;
        return Text(value, style: TextStyle(fontSize: 10, color: color));
      },
      selector: (context, model) => model.title(index),
    );
  }
}
