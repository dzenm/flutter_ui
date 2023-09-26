import 'package:flutter/material.dart';

import '../base/base.dart';
import '../entities/coin_entity.dart';
import '../entities/user_entity.dart';

///
/// Created by a0010 on 2023/2/23 14:26
/// Provider中共享的用户信息
class UserModel with ChangeNotifier {
  UserEntity _user = UserEntity(); //用户信息
  int _collectCount = 0; // 收藏文章数量
  CoinEntity _coin = CoinEntity(); // 积分信息

  /// 初始化用户数据，从数据库获取所有的用户数据
  Future<void> init() async {
    List<UserEntity> list = await DBDao.where(where: {'id': SpUtil.getUserId()});
    if (list.isEmpty) return;
    _user = list.first;
    notifyListeners();
  }

  /// 获取当前登录的用户信息
  UserEntity get user => _user;

  /// 更新当前登录的用户信息
  set user(UserEntity user) {
    _user = user;
    DBDao.insert(user);
    notifyListeners();
  }

  /// 获取收藏的文章数据
  int get collectCount => _collectCount;

  /// 更新收藏的文章数据
  set collectCount(int count) {
    _collectCount = count;
    notifyListeners();
  }

  /// 获取当前的积分信息
  CoinEntity get coin => _coin;

  /// 更新当前的积分信息
  set coin(CoinEntity coin) {
    _coin = coin;
    notifyListeners();
  }

  /// 清空数据
  void clear() {
    _user = UserEntity();
    _coin = CoinEntity();
    _collectCount = 0;
    notifyListeners();
  }
}
