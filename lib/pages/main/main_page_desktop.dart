import 'package:dbl/dbl.dart';
import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../common/view_media_page.dart';
import 'main_model.dart';
import 'system_tray.dart';

///
/// Created by a0010 on 2023/6/29 15:49
///
class MainPageDesktop extends StatelessWidget with Logging {
  final Map<MainTab, Widget> tabs;

  MainPageDesktop({super.key, required this.tabs});

  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    logPage('build');

    return Material(
      color: Colors.white,
      child: DesktopWrapper(
        child: Row(children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: DesktopNavigationRail(
              width: 56.0,
              onSelected: (int index) {
                MainTab selectedTab = MainTab.home;
                for (var tab in MainTab.values) {
                  if (index != tab.index) continue;
                  selectedTab = tab;
                }
                _jumpToPage(context, selectedTab);
              },
              leading: _buildLeadingView(context),
              children: tabs.keys.map((tab) {
                return NavigationRailItemView(tab: tab);
              }).toList(),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // 主要的展示内容，Expanded 占满剩下屏幕空间
          Expanded(
            child: PageView(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              children: _buildBody(),
            ),
          )
        ]),
      ),
    );
  }

  List<Widget> _buildBody() {
    List<Widget> list = [];
    for (var child in tabs.values) {
      list.add(KeepAliveWrapper(child: child));
    }
    return list;
  }

  Widget _buildLeadingView(BuildContext context) {
    String heroTag = 'heroTag';
    List<String> urls = [
      Assets.a,
    ];
    List<MediaEntity> images = urls.map((url) => MediaEntity(url: url)).toList();
    return TapLayout(
      border: Border.all(width: 3.0, color: const Color(0xfffcfcfc)),
      borderRadius: const BorderRadius.all(Radius.circular(32)),
      onTap: () => ViewMediaPage.show(context, medias: images, tag: images),
      child: Hero(
        tag: heroTag,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Image.asset(Assets.a, fit: BoxFit.cover, width: 32, height: 32),
        ),
      ),
    );
  }

  /// 跳转页面
  void _jumpToPage(BuildContext context, MainTab tab) {
    bool isSelected = context.read<MainModel>().isSelected(tab);
    if (!isSelected) {
      context.read<MainModel>().setSelectedTab(tab);
      _controller.jumpToPage(tab.index);
    }
  }
}

class NavigationRailItemView extends StatelessWidget {
  final MainTab tab;

  const NavigationRailItemView({super.key, required this.tab});

  @override
  Widget build(BuildContext context) {
    MainTab selectedTab = context.watch<MainModel>().selectedTab;

    List<IconData> icons = [
      Icons.home,
      Icons.airplay_rounded,
      Icons.person,
    ];
    // List<String> titles = [
    //   S.of(context).home,
    //   S.of(context).nav,
    //   S.of(context).me,
    // ];
    int index = tab.index;
    AppTheme theme = context.watch<LocalModel>().theme;
    IconData icon = icons[index]; // 图标
    // String title = titles[index]; // 标题
    bool isSelected = selectedTab == tab; // 是否是选中的索引
    Color color = isSelected ? theme.appbar : theme.hint;
    return Icon(icon, color: color);
  }
}

class MainPageDesktopWrapper extends StatefulWidget {
  final Widget child;

  const MainPageDesktopWrapper({super.key, required this.child});

  @override
  State<MainPageDesktopWrapper> createState() => _MainPageDesktopWrapperState();
}

class _MainPageDesktopWrapperState extends State<MainPageDesktopWrapper> with Logging, WindowListener, TrayListener, SystemTray {
  @override
  void initState() {
    super.initState();
    logPage('initState');

    // 这里注意一个问题，在桌面端可能会存在多个StatefulWidget在一个页面，导致数据变化的时候，没有重建子StatefulWidget，而是直接调用旧的build方法，
    // 所以会出现initState未执行的情况，这种问题的解决办法是在didUpdateWidget进行判断oldWidget与widget是否相同，将initState应该执行的内容再次执行即可

    windowManager.addListener(this);
    trayManager.addListener(this);

    DesktopWrapper.setWindow();
    init();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    super.dispose();
    logPage('dispose');
  }

  @override
  void onTrayIconMouseDown() {
    logInfo('onTrayIconMouseDown');

    // 图标鼠标左键单击事件（显示程序）
    final windows = windowManager;
    windows.restore();
  }

  @override
  void onTrayIconRightMouseDown() {
    logInfo('onTrayIconRightMouseDown');

    // 图标鼠标右键单击事件（显示菜单）
    SystemTray().trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    logInfo('onTrayMenuItemClick');

    // 菜单选项点击事件
    switch (menuItem.key) {
      case 'exit':
        final windows = windowManager;
        windows.close();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    logPage('build');
    return widget.child;
  }

  @override
  void onWindowEvent(String eventName) {
    logPage('onWindowEvent: eventName=$eventName');
  }

  @override
  void onWindowClose() async {
    // do something
    bool isPreventClose = await windowManager.isPreventClose();
    if (!mounted) return;
    if (isPreventClose) {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Are you sure you want to close this window?'),
            actions: [
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Yes'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await windowManager.destroy();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void onWindowFocus() {
    // 窗口获取焦点后调用
    // Make sure to call once.
    setState(() {});
    // do something
  }

  @override
  void onWindowBlur() {
    // 窗口失去焦点后调用
    // do something
  }

  @override
  void onWindowMaximize() {
    //
    // do something
  }

  @override
  void onWindowUnmaximize() {
    // do something
  }

  @override
  void onWindowMinimize() {
    // 最小化窗口时调用
    // do something
  }

  @override
  void onWindowRestore() {
    // 最大化恢复窗口时调用
    // do something
  }

  @override
  void onWindowResize() {
    // 窗口尺寸准备发生变化时调用（调整窗口大小/最大化）
    // do something
  }

  @override
  void onWindowResized() {
    // 窗口尺寸正在发生变化时调用（调整窗口大小/最大化）
    // do something
  }

  @override
  void onWindowMove() {
    // 窗口准备移动时调用
    // do something
  }

  @override
  void onWindowMoved() {
    // 窗口正在移动时调用
    // do something
  }

  @override
  void onWindowEnterFullScreen() {
    // 进入全屏时调用（最大化屏幕）
    // do something
  }

  @override
  void onWindowLeaveFullScreen() {
    // 离开全屏时调用（最大化恢复）
    // do something
  }
}
