import 'package:fluro/fluro.dart';
import 'package:flutter_ui/pages/main/me_page/me_router.dart';
import 'package:flutter_ui/pages/root_route.dart';

/// 实现该接口自动注册并初始化路由
abstract class BaseRoute {
  void initRouter(FluroRouter router);
}

/// 路由初始化管理
class RouteManager {
  static FluroRouter router = FluroRouter();

  static List<BaseRoute> _mListRouter = [];

  static void registerConfigureRoutes() {
    _mListRouter.clear();
    // 添加模块路由
    _mListRouter.add(RootRoute());
    _mListRouter.add(MeRouter());

    _mListRouter.forEach((element) => element.initRouter(router));
  }
}
