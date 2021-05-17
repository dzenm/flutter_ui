import 'package:fluro/fluro.dart';

// 实现该接口自动注册并初始化路由
abstract class ImplRoute {
  void initRouter(FluroRouter router);
}
