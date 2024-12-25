import 'package:dbl/dbl.dart';
import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../entities/coin.dart';
import '../../../entities/user.dart';
import '../../../generated/l10n.dart';
import '../../../http/http_manager.dart';
import '../../../models/provider_manager.dart';
import '../../../models/user.dart';
import '../../common/view_media.dart';
import '../../mall/mall_router.dart';
import '../../study/study_router.dart';
import 'me_content_page.dart';
import 'me_model.dart';
import 'me_router.dart';

///
/// Created by a0010 on 2022/7/28 10:56
/// 我的页面
class MePageMobile extends StatelessWidget {
  const MePageMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return _MePage(push: <String>(path) {
      return context.pushNamed(path);
    });
  }
}

class MePageDesktop extends StatelessWidget {
  /// The navigation shell and container for the branch Navigators.
  final StatefulNavigationShell navigationShell;

  /// The children (branch Navigators) to display in a custom container
  final List<Widget> children;

  const MePageDesktop({
    super.key,
    required this.navigationShell,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return MeContentPage(
      navigationShell: navigationShell,
      children: children,
      builder: (controller) {
        return DesktopMenu(
          width: 320,
          secondaryChild: Material(
            child: PageView(
              controller: controller,
              children: children,
            ),
          ),
          child: _MePage(
            push: <String>(path) async {
              int index = MeRouter.getPathIndex(path);
              context.read<MeModel>().selectedTab = path;
              controller.jumpToPage(index);
              navigationShell.goBranch(index);
              return null;
            },
          ),
        );
      },
    );
  }
}

class _MePage extends StatefulWidget {
  final Future<T?>? Function<T>(String path) push;

  const _MePage({required this.push});

  @override
  State<StatefulWidget> createState() => _MePageState();
}

class _MePageState extends State<_MePage> with Logging {
  @override
  void initState() {
    super.initState();
    logPage('initState');

    _getUserinfo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    logPage('didChangeDependencies');
  }

  @override
  void didUpdateWidget(covariant _MePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    logPage('didUpdateWidget');
  }

  @override
  void deactivate() {
    super.deactivate();
    logPage('deactivate');
  }

  @override
  void dispose() {
    super.dispose();
    logPage('dispose');
  }

  @override
  Widget build(BuildContext context) {
    logPage('build');

    AppTheme theme = context.watch<LocalModel>().theme;
    double? statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // toolbar背景色块
          Column(children: [
            const CommonBar(),
            Expanded(child: Container(color: theme.cardBackground)),
          ]),
          // body
          _buildBody(theme, statusBarHeight),
        ],
      ),
    );
  }

  Widget _buildBody(AppTheme theme, double statusBarHeight) {
    String heroTag = 'meTag';
    List<String> urls = [
      Assets.a,
    ];
    List<MediaEntity> images = urls.map((url) => MediaEntity(url: url)).toList();
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
          clipBehavior: Clip.hardEdge,
          child: Column(children: [
            const SizedBox(height: 48),
            ..._buildChildrenButtons(theme),
          ]),
        ),
        Positioned(
          right: 32,
          child: TapLayout(
            border: Border.all(width: 4, color: Colors.white),
            width: 72,
            isCircle: true,
            onTap: () => ViewMediaPage.show(context, medias: images, tag: heroTag),
            child: Hero(
              tag: heroTag,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(64),
                child: Image.asset(Assets.a, fit: BoxFit.cover, width: 64, height: 64),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  List<Widget> _buildChildrenButtons(AppTheme theme) {
    return [
      _SelectedView(
        path: MeRouter.medicine,
        onTap: push,
        child: SingleTextView(
          title: S.of(context).chineseMedicine,
          isShowForward: true,
        ),
      ),
      const SizedBox(height: 8),
      _SelectedView(
        path: MeRouter.collect,
        onTap: push,
        child: SingleTextView(
          icon: Icons.collections,
          title: S.of(context).collect,
          isShowForward: true,
        ),
      ),
      _SelectedView(
        path: MeRouter.coin,
        onTap: push,
        child: SingleTextView(
          icon: Icons.money,
          title: S.of(context).coinRecord,
          isShowForward: true,
        ),
      ),
      _SelectedView(
        path: MeRouter.rank,
        onTap: push,
        child: SingleTextView(
          icon: Icons.money,
          title: S.of(context).integralRankingList,
          isShowForward: true,
        ),
      ),
      _SelectedView(
        path: MeRouter.article,
        onTap: push,
        child: SingleTextView(
          icon: Icons.article,
          title: S.of(context).sharedArticle,
          isShowForward: true,
        ),
      ),
      _SelectedView(
        path: StudyRouter.study,
        onTap: push,
        child: SingleTextView(
          icon: Icons.real_estate_agent_sharp,
          title: S.of(context).studyMainPage(''),
          isShowForward: true,
        ),
      ),
      _SelectedView(
        path: MeRouter.info,
        onTap: push,
        child: SingleTextView(
          icon: Icons.supervised_user_circle_sharp,
          title: S.of(context).profile,
          isShowForward: true,
        ),
      ),
      _SelectedView(
        path: MallRouter.mall,
        onTap: push,
        child: SingleTextView(
          icon: Icons.local_mall_rounded,
          title: S.of(context).mall,
          isShowForward: true,
        ),
      ),
      _SelectedView(
        path: MeRouter.setting,
        onTap: push,
        child: SingleTextView(
          icon: Icons.settings,
          title: S.of(context).setting,
          isShowForward: true,
        ),
      ),
    ];
  }

  Future<T?>? push<T>(String path) {
    return widget.push(path);
  }

  void getData() async {
    await DeviceUtil.getIP().then((ip) async {
      ProviderManager.me(context: context).updateIP(ip);
    });
  }

  Future<void> _getUserinfo() async {
    await HttpManager().getUserinfo(success: (data) async {
      // 用户数据
      UserEntity user = UserEntity.fromJson(data['userInfo']);
      int count = data['collectArticleInfo']['count'];
      CoinEntity coin = CoinEntity.fromJson(data['coinInfo']);

      if (!mounted) return;
      context.read<UserModel>().user = user;
      context.read<UserModel>().collectCount = count;
      context.read<UserModel>().coin = coin;
    });
  }
}

class _SelectedView extends StatelessWidget {
  final Widget child;
  final String path;
  final Future<T?>? Function<T>(String path)? onTap;

  const _SelectedView({
    super.key,
    required this.child,
    required this.path,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<MeModel, String?>(
      selector: (_, model) => model.selectedTab,
      builder: (c, selectedPath, w) {
        bool isSelected = path == selectedPath;
        AppTheme theme = context.watch<LocalModel>().theme;
        Color color = isSelected ? theme.divide : theme.transparent;
        return Theme(
          data: ThemeData(
            textTheme: TextTheme(
              bodyMedium: TextStyle(color: theme.white),
            ),
          ),
          child: TapLayout(
            height: 50.0,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            background: color,
            onTap: () {
              if (onTap != null) {
                onTap!(path);
              }
            },
            child: child,
          ),
        );
      },
    );
  }
}
