import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui/pages/main/me_page/me_router.dart';
import 'package:flutter_ui/pages/routers.dart';
import 'package:provider/provider.dart';

import '../../../base/log/log.dart';
import '../../../base/res/app_theme.dart';
import '../../../base/res/local_model.dart';
import '../../../base/route/route_manager.dart';
import '../../../base/utils/device_util.dart';
import '../../../base/widgets/single_text_layout.dart';
import '../../../base/widgets/tap_layout.dart';
import '../../../entities/coin_entity.dart';
import '../../../entities/user_entity.dart';
import '../../../generated/l10n.dart';
import '../../../http/http_manager.dart';
import '../../../models/user_model.dart';
import 'me_model.dart';
import 'medicine/medicine_page.dart';

///
/// Created by a0010 on 2022/7/28 10:56
/// 我的页面
class MePage extends StatefulWidget {
  const MePage({super.key});

  @override
  State<StatefulWidget> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  static const String _tag = 'MePage';

  @override
  void initState() {
    super.initState();
    Log.i('initState', tag: _tag);

    _getUserinfo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Log.i('didChangeDependencies', tag: _tag);
  }

  @override
  void didUpdateWidget(covariant MePage oldWidget) {
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
    super.dispose();
    Log.i('dispose', tag: _tag);
  }

  @override
  Widget build(BuildContext context) {
    Log.i('build', tag: _tag);

    AppTheme? theme = context.watch<LocalModel>().appTheme;
    double? statusBarHeight = MediaQuery.of(context).padding.top;

    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverAppBar(
            //当此值为true时 SliverAppBar 会固定在页面顶部，为false时 SliverAppBar 会随着滑动向上滑动
            pinned: true,
            //滚动是是否拉伸图片
            stretch: true,
            //展开区域的高度
            expandedHeight: 500,
            //当snap配置为true时，向下滑动页面，SliverAppBar（以及其中配置的flexibleSpace内容）会立即显示出来，
            //反之当snap配置为false时，向下滑动时，只有当ListView的数据滑动到顶部时，SliverAppBar才会下拉显示出来。
            snap: false,
            //阴影
            elevation: 0,
            //背景颜色
            // backgroundColor: headerWhite ? Colors.white : Color(0xFFF4F5F7),
            //一个显示在 AppBar 下方的控件，高度和 AppBar 高度一样， // 可以实现一些特殊的效果，该属性通常在 SliverAppBar 中使用
            flexibleSpace: FlexibleSpaceBar(
              title: Text('复仇者联盟', style: TextStyle(color: theme.background)),
              background: Image.network(
                'http://img.haote.com/upload/20180918/2018091815372344164.jpg',
                fit: BoxFit.cover,
              ),
            ),
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
        ];
      },
      physics: AlwaysScrollableScrollPhysics(),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(children: buildChildrenButtons(theme, statusBarHeight)),
        ),
      ),
    );
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // toolbar背景色块
          Column(children: [
            SizedBox(
              height: statusBarHeight + kToolbarHeight,
              child: Container(color: theme.appbarColor),
            ),
            Expanded(child: Container(color: theme.divide)),
          ]),
          // body
          SingleChildScrollView(
            physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()), // 上拉下拉弹簧效果
            child: Container(
              margin: EdgeInsets.only(top: statusBarHeight + 16, left: 16, right: 16),
              decoration: BoxDecoration(
                color: theme.background,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(children: buildChildrenButtons(theme, statusBarHeight)),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> buildChildrenButtons(AppTheme? theme, double statusBarHeight) {
    return [
      TapLayout(
        height: 50.0,
        padding: EdgeInsets.symmetric(horizontal: 16),
        onTap: () => RouteManager.push(context, MedicinePage(medicineName: '金银花')),
        child: SingleTextLayout(
          title: 'Chinese',
          isShowForward: true,
        ),
      ),
      SizedBox(height: 8),
      TapLayout(
        height: 50.0,
        padding: EdgeInsets.symmetric(horizontal: 16),
        onTap: () => Navigator.pushNamed(context, MeRouter.collect),
        child: SingleTextLayout(
          icon: Icons.collections,
          title: S.of(context).collect,
          isShowForward: true,
        ),
      ),
      TapLayout(
        height: 50.0,
        padding: EdgeInsets.symmetric(horizontal: 16),
        onTap: () => Navigator.pushNamed(context, MeRouter.coin),
        child: SingleTextLayout(
          icon: Icons.money,
          title: S.of(context).coin,
          isShowForward: true,
        ),
      ),
      TapLayout(
        height: 50.0,
        padding: EdgeInsets.symmetric(horizontal: 16),
        onTap: () => Navigator.pushNamed(context, MeRouter.rank),
        child: SingleTextLayout(
          icon: Icons.money,
          title: '积分排行榜',
          isShowForward: true,
        ),
      ),
      TapLayout(
        height: 50.0,
        padding: EdgeInsets.symmetric(horizontal: 16),
        onTap: () => Navigator.pushNamed(context, MeRouter.article),
        child: SingleTextLayout(
          icon: Icons.article,
          title: '分享的文章',
          isShowForward: true,
        ),
      ),
      TapLayout(
        height: 50.0,
        padding: EdgeInsets.symmetric(horizontal: 16),
        onTap: () => Navigator.pushNamed(context, Routers.study.study),
        child: SingleTextLayout(
          icon: Icons.real_estate_agent_sharp,
          title: '学习主页',
          isShowForward: true,
        ),
      ),
      TapLayout(
        height: 50.0,
        padding: EdgeInsets.symmetric(horizontal: 16),
        onTap: () => Navigator.pushNamed(context, MeRouter.viewInfo),
        child: SingleTextLayout(
          icon: Icons.supervised_user_circle_sharp,
          title: '我的资料',
          isShowForward: true,
        ),
      ),
      TapLayout(
        height: 50.0,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
        padding: EdgeInsets.symmetric(horizontal: 16),
        onTap: () => Navigator.pushNamed(context, MeRouter.setting),
        child: SingleTextLayout(
          icon: Icons.settings,
          title: S.of(context).setting,
          isShowForward: true,
        ),
      ),
    ];
  }

  void getData() async {
    String ip = await DeviceUtil.getIP();
    context.read<MeModel>().updateIP(ip);
  }

  Future<void> _getUserinfo() async {
    await HttpManager.instance.getUserinfo(success: (data) {
      // 用户数据
      UserEntity user = UserEntity.fromJson(data['userInfo']);
      int count = data['collectArticleInfo']['count'];
      CoinEntity coin = CoinEntity.fromJson(data['coinInfo']);

      context.read<UserModel>().user = user;
      context.read<UserModel>().collectCount = count;
      context.read<UserModel>().coin = coin;
    });
  }
}
