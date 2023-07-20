import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../base/res/app_theme.dart';
import '../../../../base/res/assets.dart';
import '../../../../base/res/local_model.dart';
import '../../../../base/route/app_route_delegate.dart';
import '../../../../base/widgets/common_bar.dart';
import '../../../../base/widgets/single_text_layout.dart';
import '../../../../base/widgets/tap_layout.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/user_model.dart';
import '../../../common/preview_photo_page.dart';
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
          CommonBar(title: '我的信息', centerTitle: true),
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
          return TapLayout(
            height: 50,
            background: theme.white,
            padding: EdgeInsets.symmetric(horizontal: 16),
            onTap: () => PreviewPhotoPage.show(context, [
              "https://www.wanandroid.com/blogimgs/50c115c2-cf6c-4802-aa7b-a4334de444cd.png",
              Assets.image('a.jpg'),
              Assets.image('a.jpg'),
            ]),
            child: SingleTextLayout(
              icon: Icons.account_circle,
              title: S.of(context).avatar,
              isTextLeft: false,
              suffix: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(Assets.image('a.jpg'), fit: BoxFit.cover, width: 24, height: 24),
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
            padding: EdgeInsets.symmetric(horizontal: 16),
            onTap: () => context.read<StudyModel>().setValue('new value'),
            child: SingleTextLayout(
              icon: Icons.phone,
              title: S.of(context).id,
              text: id,
              isTextLeft: false,
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
            padding: EdgeInsets.symmetric(horizontal: 16),
            onTap: () => AppRouteDelegate.of(context).push(MeRouter.editInfo),
            child: SingleTextLayout(
              icon: Icons.person,
              title: S.of(context).username,
              text: username,
              isTextLeft: false,
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
            padding: EdgeInsets.symmetric(horizontal: 16),
            onTap: () => context.read<StudyModel>().setValue('new value'),
            child: SingleTextLayout(
              icon: Icons.email,
              title: S.of(context).email,
              text: email,
              isTextLeft: false,
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
            padding: EdgeInsets.symmetric(horizontal: 16),
            onTap: () => context.read<StudyModel>().setValue('new value'),
            child: SingleTextLayout(
              icon: Icons.money,
              title: S.of(context).coin,
              text: coinCount,
              isTextLeft: false,
              isShowForward: true,
            ),
          );
        },
        selector: (context, model) => '${model.user.coinCount}',
      ),
    ];
  }
}
