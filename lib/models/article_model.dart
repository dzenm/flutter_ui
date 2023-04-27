import 'package:flutter/material.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/entities/article_entity.dart';

///
/// Created by a0010 on 2022/7/28 10:56
/// Provider中共享的文章数据
class ArticleModel with ChangeNotifier {
  ArticleEntity _entity = ArticleEntity();

  /// 数据库对应的所有数据
  List<ArticleEntity> _allArticle = [];

  /// 初始化文章数据，从数据库获取所有的文章数据
  Future<void> init() async {
    List list = await _entity.where(_entity);
    List<ArticleEntity> articles = list.map((e) => e as ArticleEntity).toList();
    _allArticle = articles;
    notifyListeners();
  }

  /// 置顶的文章数据
  List<ArticleEntity> get topArticles => _allArticle.where((article) => article.type == 1).toList();

  /// 普通的文章数据
  List<ArticleEntity> get articles => _allArticle.where((article) => article.type == 0).toList();

  /// 所有的文章数据，置顶的排在前面，普通的排在后面
  List<ArticleEntity> get allArticles => []
    ..addAll(topArticles)
    ..addAll(articles);

  /// 根据索引获取文章
  ArticleEntity? getArticle(int index) => allArticles.isEmpty ? null : allArticles[index];

  /// 更新文章列表
  void updateArticles(List<ArticleEntity> articles) async {
    await Future.forEach(articles, (ArticleEntity article) async => await _handleArticle(article));
    notifyListeners();
  }

  /// 更新单篇文章
  void updateArticle(ArticleEntity article) async {
    await _handleArticle(article);
    notifyListeners();
  }

  /// 处理文章数据
  Future<void> _handleArticle(ArticleEntity article) async {
    int index = _allArticle.indexWhere((e) => e.id == article.id);

    if (index == -1) {
      _allArticle.add(article);
      _entity.insert(article); // 保存为DB中的article数据
    } else {
      _allArticle[index] = article;
      _entity.update(article); // 更新DB中的article数据
    }
  }

  /// 清空数据
  void clear() {
    _allArticle.clear();
    notifyListeners();
  }
}
