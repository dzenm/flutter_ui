import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/pages/main/me/me_model.dart';
import 'package:provider/provider.dart';

///
/// Created by a0010 on 2024/4/3 14:14
///
class MeContentPage extends StatelessWidget {
  final StatefulNavigationShell? navigation;
  const MeContentPage({super.key, this.navigation});

  @override
  Widget build(BuildContext context) {
    String? path = context.watch<MeModel>().selectedTab;
    // PageBuilder? builder;
    // if (path != null) {
    //   AppRouteSettings settings = AppRouteSettings.parse(path);
    //   Log.d('路由信息：settings=${settings.toString()}');
    //   for (var router in Routers.routers) {
    //     if (router.path != settings.name) continue;
    //     builder = router.builder;
    //     break;
    //   }
    // }
    //
    // if (path == null || builder == null) {
    //   return const EmptyView(text: '空页面');
    // }
    // return builder(AppRouteSettings.parse(path));
    return const Placeholder();
  }
}
