import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../base/base.dart';
import '../../../entities/coin_entity.dart';
import '../../../entities/user_entity.dart';
import '../../../generated/l10n.dart';
import '../../../http/http_manager.dart';
import '../../../models/provider_manager.dart';
import '../../../models/user_model.dart';
import '../../common/preview_picture_page.dart';
import '../../mall/mall_router.dart';
import '../../study/study_router.dart';
import 'me_router.dart';

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
    log('initState');

    _getUserinfo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    log('didChangeDependencies');
  }

  @override
  void didUpdateWidget(covariant MePage oldWidget) {
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
    super.dispose();
    log('dispose');
  }

  @override
  Widget build(BuildContext context) {
    log('build');

    AppTheme theme = context.watch<LocalModel>().theme;
    double? statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // toolbar背景色块
          Column(children: [
            const CommonBar(),
            Expanded(child: Container(color: theme.divide)),
          ]),
          // body
          _buildBody(theme, statusBarHeight),
        ],
      ),
    );
  }

  Widget _buildBody(AppTheme theme, double statusBarHeight) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 16, right: 16, top: statusBarHeight),
      // AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()): iOS上拉下拉弹簧效果，
      // AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()): Android微光效果
      physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
      child: Stack(alignment: Alignment.topRight, children: [
        Container(
          margin: const EdgeInsets.only(top: 24),
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: [
            const SizedBox(height: 48),
            ..._buildChildrenButtons(theme),
          ]),
        ),
        Positioned(
          right: 32,
          child: TapLayout(
            border: Border.all(width: 3.0, color: const Color(0xfffcfcfc)),
            borderRadius: const BorderRadius.all(Radius.circular(64)),
            onTap: () => PreviewPicturePage.show(context, [Assets.a]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(64),
              child: Image.asset(Assets.a, fit: BoxFit.cover, width: 64, height: 64),
            ),
          ),
        ),
      ]),
    );
  }

  List<Widget> _buildChildrenButtons(AppTheme theme) {
    return [
      TapLayout(
        height: 50.0,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        onTap: () {
          String params = '?medicineName=金银花';
          AppRouteDelegate.of(context).push(MeRouter.medicine + params);
        },
        child: SingleTextLayout(
          title: S.of(context).chineseMedicine,
          isShowForward: true,
        ),
      ),
      const SizedBox(height: 8),
      TapLayout(
        height: 50.0,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        onTap: () => AppRouteDelegate.of(context).push(MeRouter.collect),
        child: SingleTextLayout(
          icon: Icons.collections,
          title: S.of(context).collect,
          isShowForward: true,
        ),
      ),
      TapLayout(
        height: 50.0,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        onTap: () => AppRouteDelegate.of(context).push(MeRouter.coin),
        child: SingleTextLayout(
          icon: Icons.money,
          title: S.of(context).coinRecord,
          isShowForward: true,
        ),
      ),
      TapLayout(
        height: 50.0,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        onTap: () => AppRouteDelegate.of(context).push(MeRouter.rank),
        child: SingleTextLayout(
          icon: Icons.money,
          title: S.of(context).integralRankingList,
          isShowForward: true,
        ),
      ),
      TapLayout(
        height: 50.0,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        onTap: () => AppRouteDelegate.of(context).push(MeRouter.article),
        child: SingleTextLayout(
          icon: Icons.article,
          title: S.of(context).sharedArticle,
          isShowForward: true,
        ),
      ),
      TapLayout(
        height: 50.0,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        onTap: () => AppRouteDelegate.of(context).push(StudyRouter.study).then((value) => log(value)),
        child: SingleTextLayout(
          icon: Icons.real_estate_agent_sharp,
          title: S.of(context).studyMainPage(''),
          isShowForward: true,
        ),
      ),
      TapLayout(
        height: 50.0,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        onTap: () => AppRouteDelegate.of(context).push(MeRouter.info),
        child: SingleTextLayout(
          icon: Icons.supervised_user_circle_sharp,
          title: S.of(context).profile,
          isShowForward: true,
        ),
      ),
      TapLayout(
        height: 50.0,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        onTap: () => AppRouteDelegate.of(context).push(MallRouter.mall),
        child: SingleTextLayout(
          icon: Icons.local_mall_rounded,
          title: S.of(context).mall,
          isShowForward: true,
        ),
      ),
      TapLayout(
        height: 50.0,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        onTap: () => AppRouteDelegate.of(context).push(MeRouter.setting),
        child: SingleTextLayout(
          icon: Icons.settings,
          title: S.of(context).setting,
          isShowForward: true,
        ),
      ),
    ];
  }

  void getData() async {
    await DeviceUtil.getIP().then((ip) async {
      ProviderManager.me(context: context).updateIP(ip);
    });
  }

  Future<void> _getUserinfo() async {
    await HttpManager().getUserinfo(success: (data) {
      // 用户数据
      UserEntity user = UserEntity.fromJson(data['userInfo']);
      int count = data['collectArticleInfo']['count'];
      CoinEntity coin = CoinEntity.fromJson(data['coinInfo']);

      context.read<UserModel>().user = user;
      context.read<UserModel>().collectCount = count;
      context.read<UserModel>().coin = coin;
    });
  }

  void log(String msg) => Log.p(msg, tag: _tag);
}
