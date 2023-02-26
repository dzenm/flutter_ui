import 'package:flutter/material.dart';
import 'package:flutter_ui/base/utils/sp_util.dart';
import 'package:flutter_ui/entities/coin_entity.dart';
import 'package:flutter_ui/entities/user_entity.dart';

///
/// Created by a0010 on 2023/2/23 14:26
/// 用户信息
class UserModel extends ChangeNotifier {
  UserEntity _user = UserEntity(); //用户信息
  int _collectCount = 0; // 收藏文章数量
  CoinEntity _coin = CoinEntity(); // 积分信息

  UserModel() {
    _getUser();
  }

  /// 获取用户数据
  void _getUser() async {
    List list = await _user.where(_user, where: {'id': SpUtil.getUserId()});
    _user = list.map((e) => e as UserEntity).first;
    notifyListeners();
  }

  /// 获取当前登录的用户信息
  UserEntity get user => _user;

  /// 更新当前登录的用户信息
  void updateUser(UserEntity user) {
    _user = user;
    _user.insert(user);
    notifyListeners();
  }

  /// 获取收藏的文章数据
  int get collectCount => _collectCount;

  /// 更新收藏的文章数据
  void updateCollectCount(int count) {
    _collectCount = count;
    notifyListeners();
  }

  /// 获取当前的积分信息
  CoinEntity get coin => _coin;

  /// 更新当前的积分信息
  void updateCoin(CoinEntity coin) {
    _coin = coin;
    notifyListeners();
  }
}
