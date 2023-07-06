import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui/pages/routers.dart';
import 'package:provider/provider.dart';

import '../../base/res/app_theme.dart';
import '../../base/res/local_model.dart';
import '../../base/route/app_route_delegate.dart';
import '../../generated/l10n.dart';
import 'study_router.dart';

///
/// Created by a0010 on 2022/11/3 16:03
///
class StudyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(S.of(context).studyMainPage('(自定义语言)')),
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
        child: _text('城市选择'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.city),
      ),
      SizedBox(height: 8),
      // 字符转化
      MaterialButton(
        child: _text('字符转化'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.convert),
      ),
      SizedBox(height: 8),
      // dialog
      MaterialButton(
        child: _text('弹窗'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.dialog),
      ),
      SizedBox(height: 8),
      // 可拖动ListView
      MaterialButton(
        child: _text('可拖动ListView'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.dragList),
      ),
      SizedBox(height: 8),
      // 快速页面创建
      MaterialButton(
        child: _text('快速页面创建'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => AppRouteDelegate.of(context).push(Routers.example),
      ),
      SizedBox(height: 8),
      // 浮动的导航栏和PopupWindow
      MaterialButton(
        child: _text('浮动的导航栏和PopupWindow'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.floatNavigation),
      ),
      SizedBox(height: 8),
      // HTTP请求
      MaterialButton(
        child: _text('HTTP请求'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.http),
      ),
      SizedBox(height: 8),
      // 自定义键盘
      MaterialButton(
        child: _text('自定义键盘'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.keyword),
      ),
      SizedBox(height: 8),
      // 刷新和底部加载的列表
      MaterialButton(
        child: _text('刷新和底部加载的列表'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.list),
      ),
      SizedBox(height: 8),
      // 加载图片
      MaterialButton(
        child: _text('加载图片'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.loadImage),
      ),
      SizedBox(height: 8),
      // 加载图片
      MaterialButton(
        child: _text('PopupWindow测试'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.popup),
      ),
      SizedBox(height: 8),
      // Provider
      MaterialButton(
        child: _text('Provider'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.provider),
      ),
      SizedBox(height: 8),
      // 二维码扫描
      MaterialButton(
        child: _text('二维码扫描'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.qr),
      ),
      SizedBox(height: 8),
      // 路由测试
      MaterialButton(
        child: _text('路由测试'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.router),
      ),
      SizedBox(height: 8),
      // 设置
      MaterialButton(
        child: _text(S.of(context).setting),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.city),
      ),
      SizedBox(height: 8),
      // 加载状态
      MaterialButton(
        child: _text(S.of(context).state),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.state),
      ),
      SizedBox(height: 8),
      // 文本展示
      MaterialButton(
        child: _text('文本展示'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.text),
      ),
      SizedBox(height: 8),
      // 视频播放
      MaterialButton(
        child: _text('视频播放'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.video),
      ),
      SizedBox(height: 16),
      MaterialButton(
        child: _text('返回并传递数据'),
        textColor: Colors.white,
        color: theme.appbarColor,
        onPressed: () => AppRouteDelegate.of(context).pop('这是回调的数据'),
      ),
    ];
  }

  Widget _text(String text) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(text)]);
  }
}
