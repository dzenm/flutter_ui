import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/base/res/lang/strings.dart';
import 'package:flutter_ui/base/res/local_model.dart';
import 'package:flutter_ui/base/res/theme/app_theme.dart';
import 'package:flutter_ui/base/router/route_manager.dart';
import 'package:flutter_ui/base/utils/native_channel_util.dart';
import 'package:flutter_ui/base/widgets/common_dialog.dart';
import 'package:flutter_ui/base/widgets/custom_popup_dialog.dart';
import 'package:flutter_ui/base/widgets/picker_list_view.dart';
import 'package:provider/provider.dart';

import '../common/example_page.dart';
import 'city_page/city_page.dart';
import 'convert_page/convert_page.dart';
import 'drag_list_page/drag_list_page.dart';
import 'float_navigation_page/float_navigation_page.dart';
import 'http_page/http_page.dart';
import 'keyword_board/keyword_board_page.dart';
import 'list_page/list_page.dart';
import 'load_image_page/load_image_page.dart';
import 'provider_page/provider_page.dart';
import 'qr_page/qr_page.dart';
import 'router/router_page.dart';
import 'setting_page/setting_page.dart';
import 'state_page/state_page.dart';
import 'text_page/text_page.dart';
import 'video_page/video_page.dart';

///
/// Created by a0010 on 2022/11/3 16:03
///
class StudyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(S.of(context).studyMainPage),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(children: _buildChildrenButtons()),
        ),
      ),
    );
  }

  List<Widget> _buildChildrenButtons() {
    AppTheme theme = context.watch<LocalModel>().appTheme;
    return [
      SizedBox(height: 16),
      // 城市选择
      MaterialButton(
        child: _text(S.of(context).citySelected),
        textColor: Colors.white,
        color: theme.toolbarBackground,
        onPressed: () => RouteManager.push(context, CitySelectedPage()),
      ),
      SizedBox(height: 8),
      // 字符转化
      MaterialButton(
        child: _text(S.of(context).charConvert),
        textColor: Colors.white,
        color: theme.toolbarBackground,
        onPressed: () => RouteManager.push(context, ConvertPage()),
      ),
      SizedBox(height: 8),
      // 可拖动ListView
      MaterialButton(
        child: _text(S.of(context).dragList),
        textColor: Colors.white,
        color: theme.toolbarBackground,
        onPressed: () => RouteManager.push(context, DragListPage()),
      ),
      SizedBox(height: 8),
      // 快速页面创建
      MaterialButton(
        child: _text(S.of(context).test),
        textColor: Colors.white,
        color: theme.toolbarBackground,
        onPressed: () => RouteManager.push(context, ExamplePage()),
      ),
      SizedBox(height: 8),
      // 浮动的导航栏和PopupWindow
      MaterialButton(
        child: _text(S.of(context).navigationBar),
        textColor: Colors.white,
        color: theme.toolbarBackground,
        onPressed: () => RouteManager.push(context, FloatNavigationPage()),
      ),
      SizedBox(height: 8),
      // HTTP请求
      MaterialButton(
        child: _text(S.of(context).httpRequest),
        textColor: Colors.white,
        color: theme.toolbarBackground,
        onPressed: () => RouteManager.push(context, HTTPListPage()),
      ),
      SizedBox(height: 8),
      // 自定义键盘
      MaterialButton(
        child: _text(S.of(context).keyword),
        textColor: Colors.white,
        color: theme.toolbarBackground,
        onPressed: () => RouteManager.push(context, KeywordBoardPage()),
      ),
      SizedBox(height: 8),
      // 刷新和底部加载的列表
      MaterialButton(
        child: _text(S.of(context).listAndRefresh),
        textColor: Colors.white,
        color: theme.toolbarBackground,
        onPressed: () => RouteManager.push(context, ListPage()),
      ),
      SizedBox(height: 8),
      // 加载图片
      MaterialButton(
        child: _text(S.of(context).loadImage),
        textColor: Colors.white,
        color: theme.toolbarBackground,
        onPressed: () => RouteManager.push(context, LoadImagePage()),
      ),
      SizedBox(height: 8),
      // Provider
      MaterialButton(
        child: _text('Provider'),
        textColor: Colors.white,
        color: theme.toolbarBackground,
        onPressed: () => RouteManager.push(context, ProviderPage()),
      ),
      SizedBox(height: 8),
      // 二维码扫描
      MaterialButton(
        child: _text(S.of(context).qr),
        textColor: Colors.white,
        color: theme.toolbarBackground,
        onPressed: () => RouteManager.push(context, QRPage()),
      ),
      SizedBox(height: 8),
      // 路由测试
      MaterialButton(
        child: _text(S.of(context).router),
        textColor: Colors.white,
        color: theme.toolbarBackground,
        onPressed: () => RouteManager.push(context, RouterPage()),
      ),
      SizedBox(height: 8),
      // 设置
      MaterialButton(
        child: _text(S.of(context).setting),
        textColor: Colors.white,
        color: theme.toolbarBackground,
        onPressed: () => RouteManager.push(context, SettingPage()),
      ),
      SizedBox(height: 8),
      // 加载状态
      MaterialButton(
        child: _text(S.of(context).state),
        textColor: Colors.white,
        color: theme.toolbarBackground,
        onPressed: () => RouteManager.push(context, StatePage()),
      ),
      SizedBox(height: 8),
      // 文本展示
      MaterialButton(
        child: _text(S.of(context).textAndInput),
        textColor: Colors.white,
        color: theme.primary,
        onPressed: () => RouteManager.push(context, TextPage()),
      ),
      SizedBox(height: 8),
      // 视频播放
      MaterialButton(
        child: _text(S.of(context).videoPlay),
        textColor: Colors.white,
        color: theme.primary,
        onPressed: () => RouteManager.push(context, VideoPage()),
      ),
      SizedBox(height: 8),
      // 自定义PopupView控件
      CustomPopupView(
        direction: PopupDirection.top,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        width: 160,
        elevation: 5,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5.0, offset: Offset(2.0, 2.0))],
        barrierColor: const Color(0x01FFFFFF),
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.primary,
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('展示Dialog', style: TextStyle(color: theme.background, fontWeight: FontWeight.w600))],
          ),
        ),
        popupDialogBuilder: (context) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text('PopupWindow 测试'),
          );
        },
      ),
      SizedBox(height: 8),
      // 启动原生页面
      MaterialButton(
        child: _text(S.of(context).nav),
        textColor: Colors.white,
        color: theme.primary,
        onPressed: () => NativeChannelUtil.startHomeActivity(),
      ),
      SizedBox(height: 8),
      // PickerListView控件
      MaterialButton(
        child: _text(S.of(context).listDialog),
        textColor: Colors.white,
        color: theme.primary,
        onPressed: () => PickerListView.showList(
          context: context,
          list: ['测试一', '测试二', '测试三', '测试四', '测试五'],
          defaultIndex: _selectedIndex,
          onSelectedChanged: (index) {
            _selectedIndex = index;
            Log.i('选中的回调: $_selectedIndex');
          },
        ),
      ),
      SizedBox(height: 8),
      // 升级dialog
      MaterialButton(
        child: _text(S.of(context).upgradeDialog),
        textColor: Colors.white,
        color: theme.primary,
        onPressed: () => CommonDialog.showAppUpgradeDialog(
          context,
          version: '12',
          desc: ['升级了'],
        ),
      ),
      SizedBox(height: 16),
    ];
  }

  Widget _text(String text) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(text)]);
  }
}
