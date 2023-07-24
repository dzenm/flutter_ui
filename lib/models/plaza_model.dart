import 'package:flutter/material.dart';

///
/// Created by a0010 on 2023/7/21 16:35
///
class ArticleModel with ChangeNotifier {

  /// 数据库对应的所有数据
  List _allArticle = [];

  /// 初始化文章数据，从数据库获取所有的文章数据
  Future<void> init() async {
    // List list = await _entity.where(_entity);
    // List<ArticleEntity> articles = list.map((e) => e as ArticleEntity).toList();
    // _allArticle = articles;
    // notifyListeners();
  }

  /// 清空数据
  void clear() {
    _allArticle.clear();
    notifyListeners();
  }
}
