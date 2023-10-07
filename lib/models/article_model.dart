import 'package:flutter/material.dart';

import '../base/base.dart';
import '../entities/article_entity.dart';

///
/// Created by a0010 on 2022/7/28 10:56
/// Provider中共享的文章数据
class ArticleModel with ChangeNotifier {
  /// 数据库对应的所有数据
  List<ArticleEntity> _allArticle = [];

  /// 初始化文章数据，从数据库获取所有的文章数据
  Future<void> init() async {
    List<ArticleEntity> articles = await DBManager().query<ArticleEntity>();
    _allArticle = articles;
    notifyListeners();
  }

  /// 置顶的文章数据
  List<ArticleEntity> get topArticles => _allArticle.where((article) => article.type == 1).toList();

  /// 普通的文章数据
  List<ArticleEntity> get articles => _allArticle.where((article) => article.type == 0).toList();

  /// 所有的文章数据，置顶的排在前面，普通的排在后面
  List<ArticleEntity> get allArticles => [...topArticles, ...articles];

  /// 根据索引获取文章
  ArticleEntity? getArticle(int index) => allArticles.isEmpty ? null : allArticles[index];

  /// 更新文章列表
  void updateArticles(List<ArticleEntity> articles) async {
    await _handleArticle(articles);
    notifyListeners();
  }

  /// 更新单篇文章
  void updateArticle(ArticleEntity article) async {
    await _handleArticle([article]);
    notifyListeners();
  }

  /// 处理文章数据
  Future<void> _handleArticle(List<ArticleEntity> articles) async {
    List<ArticleEntity> inserts = [];
    Map<int, ArticleEntity> updates = {};
    for (var article in articles) {
      int index = _allArticle.indexWhere((e) => e.id == article.id);
      if (index == -1) {
        inserts.add(article);
        DBManager().insert(article); // 保存为DB中的article数据
      } else {
        updates[index] = article;
        DBManager().update(article); // 更新DB中的article数据
      }
    }
    _allArticle.addAll(inserts);
    updates.forEach((index, article) => _allArticle[index] = article);
  }

  /// 删除文章数据
  void deleteArticle(int? id) {
    _deleteArticle(id);
    notifyListeners();
  }

  /// 删除文章数据
  void _deleteArticle(int? id) {
    if (id == null) return;
    int index = _allArticle.indexWhere((article) => article.id == id);
    if (index == -1) return;
    _allArticle.removeAt(index);
    DBManager().delete<ArticleEntity>(where: {'id': id});
  }

  /// 清空数据
  void clear() {
    _allArticle.clear();
    notifyListeners();
  }
}
