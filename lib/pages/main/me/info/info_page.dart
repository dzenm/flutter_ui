import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../base/base.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/user_model.dart';
import '../../../../base/widgets/view_media.dart';
import '../../../common/view_media_page.dart';
import '../../../study/study_model.dart';
import '../me_router.dart';

///
/// Created by a0010 on 2023/7/19 11:54
/// 我的个人信息页面
class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<StatefulWidget> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.read<LocalModel>().theme;
    return Scaffold(
      body: Container(
        color: theme.background,
        child: Column(children: [
          CommonBar(
            title: S.of(context).profile,
            centerTitle: true,
          ),
          ...buildChildrenButtons(theme),
        ]),
      ),
    );
  }

  List<Widget> buildChildrenButtons(AppTheme theme) {
    return [
      // 展示用户头像
      Selector<UserModel, String>(
        builder: (context, value, widget) {
          String heroTag = 'infoTag';
          List<String> urls = [
            "https://www.wanandroid.com/blogimgs/50c115c2-cf6c-4802-aa7b-a4334de444cd.png",
            Assets.a,
            Assets.b,
          ];
          List<MediaEntity> images = urls.map((url) => MediaEntity(url: url)).toList();
          return TapLayout(
            height: 50,
            background: theme.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            onTap: () => ViewMediaPage.show(context, medias: images, tag: heroTag),
            child: SingleTextView(
              icon: Icons.account_circle,
              title: S.of(context).avatar,
              textAlign: TextAlign.right,
              suffix: Hero(
                tag: heroTag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(Assets.a, fit: BoxFit.cover, width: 24, height: 24),
                ),
              ),
              isShowForward: true,
            ),
          );
        },
        selector: (context, model) => '',
      ),
      // 展示用户ID
      Selector<UserModel, String>(
        builder: (context, id, widget) {
          return TapLayout(
            height: 50,
            background: theme.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            onTap: () => context.read<StudyModel>().setValue('new value'),
            child: SingleTextView(
              icon: Icons.phone,
              title: S.of(context).id,
              text: id,
              textAlign: TextAlign.right,
              isShowForward: true,
            ),
          );
        },
        selector: (context, model) => '${model.user.id}',
      ),
      // 展示用户名
      Selector<UserModel, String>(
        builder: (context, username, widget) {
          return TapLayout(
            height: 50,
            background: theme.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            onTap: () => AppRouter.of(context).push('${MeRouter.editInfo}?name=dzy', pathSegments: ['212'], body: {'name': 'test'}),
            child: SingleTextView(
              icon: Icons.person,
              title: S.of(context).username,
              text: username,
              textAlign: TextAlign.right,
              isShowForward: true,
            ),
          );
        },
        selector: (context, model) => model.user.username ?? '',
      ),
      // 展示用户邮箱
      Selector<UserModel, String>(
        builder: (context, email, widget) {
          return TapLayout(
            height: 50,
            background: theme.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            onTap: () => context.read<StudyModel>().setValue('new value'),
            child: SingleTextView(
              icon: Icons.email,
              title: S.of(context).email,
              text: email,
              textAlign: TextAlign.right,
              isShowForward: true,
            ),
          );
        },
        selector: (context, model) => '${model.user.email}',
      ),
      // 展示积分数量
      Selector<UserModel, String>(
        builder: (context, coinCount, widget) {
          return TapLayout(
            height: 50,
            background: theme.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            onTap: () => context.read<StudyModel>().setValue('new value'),
            child: SingleTextView(
              icon: Icons.money,
              title: S.of(context).coin,
              text: coinCount,
              textAlign: TextAlign.right,
              isShowForward: true,
            ),
          );
        },
        selector: (context, model) => '${model.user.coinCount}',
      ),
    ];
  }
}
