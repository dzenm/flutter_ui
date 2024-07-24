import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../generated/l10n.dart';
import '../study_router.dart';

///
/// Created by a0010 on 2024/6/27 13:33
///
class ComponentsPage extends StatelessWidget {
  const ComponentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch<LocalModel>().theme;
    return Scaffold(
      appBar: CommonBar(
        title: 'Components',
        backgroundColor: theme.primary,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(children: _buildChildrenButtons(context)),
        ),
      ),
    );
  }

  List<Widget> _buildChildrenButtons(BuildContext context) {
    AppTheme theme = context.watch<LocalModel>().theme;
    return [
      const SizedBox(height: 8),
      // 聊天列表
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => context.pushNamed(StudyRouter.chat),
        child: _text('聊天列表'),
      ),
      const SizedBox(height: 8),
      // 城市选择
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => context.pushNamed(StudyRouter.city),
        child: _text('城市选择'),
      ),
      const SizedBox(height: 8),
      // dialog
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => context.pushNamed(StudyRouter.dialog),
        child: _text('弹窗'),
      ),
      const SizedBox(height: 8),
      // 可拖动ListView
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => context.pushNamed(StudyRouter.dragList),
        child: _text('可拖动ListView'),
      ),
      const SizedBox(height: 8),
      // 浮动的导航栏和PopupWindow
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => context.pushNamed(StudyRouter.floatNavigation),
        child: _text('浮动的导航栏和PopupWindow'),
      ),
      const SizedBox(height: 8),
      // 自定义键盘
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => context.pushNamed(StudyRouter.keyword),
        child: _text('自定义键盘'),
      ),
      const SizedBox(height: 8),
      // 刷新和底部加载的列表
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => context.pushNamed(StudyRouter.list),
        child: _text('刷新和底部加载的列表'),
      ),
      const SizedBox(height: 8),
      // 自定义Popup
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => context.pushNamed(StudyRouter.popup),
        child: _text('PopupWindow测试'),
      ),
      const SizedBox(height: 8),
      // 二维码扫描
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => context.pushNamed(StudyRouter.qr),
        child: _text('二维码扫描'),
      ),
      const SizedBox(height: 8),
      // 仿微信录音
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => context.pushNamed(StudyRouter.recording),
        child: _text('仿微信录音'),
      ),
      const SizedBox(height: 8),
      // 左右滑动
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => context.pushNamed(StudyRouter.slide),
        child: _text('左右滑动'),
      ),
      const SizedBox(height: 8),
      // 加载状态
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => context.pushNamed(StudyRouter.state),
        child: _text(S.of(context).state),
      ),
      const SizedBox(height: 8),
      // 文本展示
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => context.pushNamed(StudyRouter.text),
        child: _text('文本展示'),
      ),
      const SizedBox(height: 8),
    ];
  }

  Widget _text(String text) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(text)]);
  }
}
