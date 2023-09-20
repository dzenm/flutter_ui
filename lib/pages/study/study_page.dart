import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../base/res/app_theme.dart';
import '../../base/res/local_model.dart';
import '../../base/route/app_route_delegate.dart';
import '../../base/widgets/image_view.dart';
import '../../generated/l10n.dart';
import '../main/main_model.dart';
import 'study_router.dart';

///
/// Created by a0010 on 2022/11/3 16:03
///
class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  State<StatefulWidget> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch<LocalModel>().theme;
    return NestedScrollView(
      floatHeaderSlivers: true,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverAppBar(
            //当此值为true时 SliverAppBar 会固定在页面顶部，为false时 SliverAppBar 会随着滑动向上滑动
            pinned: true,
            //滚动是是否拉伸图片
            stretch: true,
            //展开区域的高度
            expandedHeight: 300,
            //当snap配置为true时，向下滑动页面，SliverAppBar（以及其中配置的flexibleSpace内容）会立即显示出来，
            //反之当snap配置为false时，向下滑动时，只有当ListView的数据滑动到顶部时，SliverAppBar才会下拉显示出来。
            snap: false,
            //阴影
            elevation: 0,
            //背景颜色
            // backgroundColor: headerWhite ? Colors.white : Color(0xFFF4F5F7),
            //一个显示在 AppBar 下方的控件，高度和 AppBar 高度一样， // 可以实现一些特殊的效果，该属性通常在 SliverAppBar 中使用
            flexibleSpace: FlexibleSpaceBar(
              title: Text(S.of(context).studyMainPage('(自定义语言)'), style: TextStyle(color: theme.background)),
              background: const ImageView(
                url: 'http://img.haote.com/upload/20180918/2018091815372344164.jpg',
                fit: BoxFit.cover,
              ),
            ),
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
        ];
      },
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(AppTheme theme) {
    return Container(
      color: theme.background,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(children: _buildChildrenButtons()),
      ),
    );
  }

  List<Widget> _buildChildrenButtons() {
    AppTheme theme = context.watch<LocalModel>().theme;
    return [
      const SizedBox(height: 16),
      // 城市选择
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.city),
        child: _text('城市选择'),
      ),
      const SizedBox(height: 8),
      // 字符转化
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.convert),
        child: _text('字符转化'),
      ),
      const SizedBox(height: 8),
      // dialog
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.dialog),
        child: _text('弹窗'),
      ),
      const SizedBox(height: 8),
      // 可拖动ListView
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.dragList),
        child: _text('可拖动ListView'),
      ),
      const SizedBox(height: 8),
      // 浮动的导航栏和PopupWindow
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.floatNavigation),
        child: _text('浮动的导航栏和PopupWindow'),
      ),
      const SizedBox(height: 8),
      // HTTP请求
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.http),
        child: _text('HTTP请求'),
      ),
      const SizedBox(height: 8),
      // 自定义键盘
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.keyword),
        child: _text('自定义键盘'),
      ),
      const SizedBox(height: 8),
      // 刷新和底部加载的列表
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.list),
        child: _text('刷新和底部加载的列表'),
      ),
      const SizedBox(height: 8),
      // 加载图片
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.loadImage),
        child: _text('加载图片'),
      ),
      const SizedBox(height: 8),
      // 加载图片
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.popup),
        child: _text('PopupWindow测试'),
      ),
      const SizedBox(height: 8),
      // Provider
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.provider),
        child: _text('Provider'),
      ),
      const SizedBox(height: 8),
      // 二维码扫描
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.qr),
        child: _text('二维码扫描'),
      ),
      const SizedBox(height: 8),
      // 路由测试
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.router),
        child: _text('路由测试'),
      ),
      const SizedBox(height: 8),
      // 左右滑动
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.slide),
        child: _text('左右滑动'),
      ),
      const SizedBox(height: 8),
      // 加载状态
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.state),
        child: _text(S.of(context).state),
      ),
      const SizedBox(height: 8),
      // 文本展示
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.text),
        child: _text('文本展示'),
      ),
      const SizedBox(height: 8),
      // 视频播放
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () => AppRouteDelegate.of(context).push(StudyRouter.video),
        child: _text('视频播放'),
      ),
      const SizedBox(height: 8),
      MaterialButton(
        textColor: Colors.white,
        color: theme.button,
        onPressed: () {
          context.read<MainModel>().selectedIndex = 1;
          AppRouteDelegate.of(context).pop('这是回调的数据');
        },
        child: _text('返回并传递数据'),
      ),
    ];
  }

  Widget _text(String text) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(text)]);
  }
}
