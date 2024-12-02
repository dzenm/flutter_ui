
import 'entities/entity.dart';

///
/// Created by a0010 on 2024/6/28 10:59
///
final class OnlineUser {
  OnlineUser._();

  /// 用户信息在登录时[LoginModel.connect]进行赋值，在登出时清空，在未登录时使用数据为空
  static UserEntity get user => _user!;
  static UserEntity? _user;

  /// 在登录时设置
  static set user(UserEntity user) {
    _user = user;
  }

  /// 控制vip模块是否需要展示
  static bool showVipFunction = false;

  /// 初始化登录的用户信息
  static void init() {
    UserEntity user = UserEntity();
    _user = user;
  }

  /// 清空登录的用户信息
  static void clear() {
    _user = null;
  }
}
