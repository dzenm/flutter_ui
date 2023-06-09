import 'package:flutter/material.dart';
import 'package:flutter_ui/models/provider_manager.dart';
import 'package:provider/provider.dart';

import '../../base/log/build_config.dart';
import '../../base/log/log.dart';
import '../../base/naughty/naughty.dart';
import '../../base/widgets/badge_tag.dart';
import '../../base/widgets/keep_alive_wrapper.dart';
import '../../base/widgets/tap_layout.dart';
import 'home_page/home_page.dart';
import 'main_model.dart';
import 'me_page/me_page.dart';
import 'nav_page/nav_page.dart';

///
/// Created by a0010 on 2022/7/28 10:56
/// 主页页面
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  static const String _tag = 'MainPage';

  // 页面管理控制器
  final PageController _controller = PageController(initialPage: 0);

  // 感知生命周期变化
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    log('didChangeAppLifecycleState: $state');

    // 处理APP生命周期
    switch (state) {
      case AppLifecycleState.inactive: // 失去焦点
        break;
      case AppLifecycleState.resumed: // 进入前台
        break;
      case AppLifecycleState.paused: // 进入后台
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    log('initState');

    WidgetsBinding.instance.addObserver(this);
  }

  /// 在build之前使用context，并且只能创建一次
  void _useContextBeforeBuild(BuildContext context) {
    // 因为要跟随语言的变化， 所以每次build都需要更新
    ProviderManager.init(context);
    Naughty.instance
      ..init(context)
      ..show();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    log('didChangeDependencies');
  }

  @override
  void didUpdateWidget(covariant MainPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    log('didUpdateWidget');
  }

  @override
  void deactivate() {
    super.deactivate();
    log('deactivate');
  }

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
    log('dispose');
  }

  @override
  Widget build(BuildContext context) {
    log('build');

    _useContextBeforeBuild(context);

    return Scaffold(
      body: PageView(
        controller: _controller,
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
    int len = context.read<MainModel>().len;
    List<Widget> list = [HomePage(), NavPage(), MePage()];
    return List.generate(len, (index) => KeepAliveWrapper(child: index < list.length ? list[index] : Container()));
  }

  /// BottomNavigationBar widget
  List<Widget> _buildBottomNavigationBar() {
    int len = context.read<MainModel>().len;
    return List.generate(len, (i) => BottomNavigationBarItemView(index: i, controller: _controller)); // bottomNavigation list
  }

  void log(String msg) => BuildConfig.showPageLog ? Log.i(msg, tag: _tag) : null;
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
    // 平分整个宽度
    return Expanded(
      flex: 1,
      // 给item设置点击事件
      child: TapLayout(
        height: height,
        foreground: Colors.transparent,
        onTap: () {
          bool isSelected = context.read<MainModel>().isSelected(index);
          if (!isSelected) {
            context.read<MainModel>().selectedIndex = index;
            controller.jumpToPage(index);
            // controller.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.ease);
          }
          if (onTap != null) onTap!();
        },
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
      ),
    );
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
