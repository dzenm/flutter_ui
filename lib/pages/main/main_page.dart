import 'package:flutter/material.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/base/naughty/naughty.dart';
import 'package:flutter_ui/base/widgets/badge_view.dart';
import 'package:flutter_ui/base/widgets/keep_alive_wrapper.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';
import 'package:flutter_ui/models/provider_manager.dart';
import 'package:flutter_ui/pages/main/main_model.dart';
import 'package:provider/provider.dart';

import 'home_page/home_page.dart';
import 'me_page/me_page.dart';
import 'nav_page/nav_page.dart';

///
/// Created by a0010 on 2022/7/28 10:56
/// 主页页面
class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  static const String _tag = 'MainPage';

  // 页面管理控制器
  final PageController _pageController = PageController(initialPage: 0);

  // 感知生命周期变化
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    Log.i('didChangeAppLifecycleState: $state', tag: _tag);
  }

  @override
  void initState() {
    super.initState();
    Log.i('initState', tag: _tag);

    WidgetsBinding.instance.addObserver(this);

    Future.delayed(Duration.zero, () {
      Naughty.instance
        ..init(context)
        ..show();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Log.i('didChangeDependencies', tag: _tag);
  }

  @override
  void didUpdateWidget(covariant MainPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    Log.i('didUpdateWidget', tag: _tag);
  }

  @override
  void deactivate() {
    super.deactivate();
    Log.i('deactivate', tag: _tag);
  }

  @override
  void dispose() {
    _pageController.dispose();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
    Log.i('dispose', tag: _tag);
  }

  @override
  Widget build(BuildContext context) {
    Log.i('build', tag: _tag);

    ProviderManager.init(context);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: _buildTabPage(),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: _buildBottomNavigationBar(),
        ),
      ),
    );
  }

  /// Page widget
  List<Widget> _buildTabPage() {
    List<Widget> list = [HomePage(), NavPage(), MePage()];
    return List.generate(list.length, (index) => KeepAliveWrapper(child: list[index]));
  }

  /// BottomNavigationBar widget
  List<Widget> _buildBottomNavigationBar() {
    int len = context.read<MainModel>().len;
    return List.generate(len, (i) => BottomNavigationBarItemView(index: i, controller: _pageController)); // bottomNavigation list
  }
}

/// 底部Item布局
class BottomNavigationBarItemView extends StatefulWidget {
  final int index;
  final PageController controller;
  final GestureTapCallback? onTap;

  BottomNavigationBarItemView({
    required this.index,
    required this.controller,
    this.onTap,
  });

  @override
  State<StatefulWidget> createState() => _BottomNavigationBarItemViewState();
}

class _BottomNavigationBarItemViewState extends State<BottomNavigationBarItemView> {
  static const String _tag = 'BottomNavigationBarItemView';

  @override
  Widget build(BuildContext context) {
    Log.d('build', tag: _tag);

    double width = 56, height = 56;
    // 平分整个宽度
    return Expanded(
      flex: 1,
      // 给item设置点击事件
      child: TapLayout(
        height: height,
        foreground: Colors.transparent,
        onTap: () {
          int index = widget.index;
          bool isSelected = context.read<MainModel>().isSelected(index);
          if (!isSelected) {
            context.read<MainModel>().selectIndex = index;
            widget.controller.jumpToPage(index);
            // widget.controller.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.ease);
          }
          if (widget.onTap != null) widget.onTap!();
        },
        child: Container(
          width: width,
          height: height,
          child: Stack(alignment: Alignment.center, children: [
            // 图标和文字充满Stack并居中显示
            Positioned.fill(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                _buildIcon(),
                SizedBox(height: 2),
                _buildTitle(),
              ]),
            ),
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
      ),
    );
  }

  Widget _buildBadge() {
    Log.d('build badge', tag: _tag);
    return Selector<MainModel, int>(
      builder: (context, value, widget) {
        return BadgeView(count: value);
      },
      selector: (context, model) => model.badgeCount(widget.index),
    );
  }

  Widget _buildIcon() {
    Log.d('build icon', tag: _tag);
    return Selector<MainModel, IconData>(
      builder: (context, value, widget) {
        // 是否是选中的索引
        bool isSelected = context.watch<MainModel>().isSelected(this.widget.index);
        Color color = isSelected ? Colors.blue : Colors.grey.shade500;
        return Icon(value, color: color, size: 20);
      },
      selector: (context, model) => model.icon(widget.index),
    );
  }

  Widget _buildTitle() {
    Log.d('build title', tag: _tag);
    return Selector<MainModel, String>(
      builder: (context, value, widget) {
        // 是否是选中的索引
        bool isSelected = context.watch<MainModel>().isSelected(this.widget.index);
        Color color = isSelected ? Colors.blue : Colors.grey.shade500;
        return Text(value, style: TextStyle(fontSize: 10, color: color));
      },
      selector: (context, model) => model.title(widget.index),
    );
  }
}
