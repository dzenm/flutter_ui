import 'package:flutter/material.dart';
import 'package:flutter_ui/entities/article_entity.dart';

///
/// Created by a0010 on 2022/7/28 10:56
///
class ArticleModel extends ChangeNotifier {
  ArticleEntity _entity = ArticleEntity();

  /// 数据库对应的所有数据
  List<ArticleEntity> _allArticleList = [];

  ArticleModel() {
    _getAllArticles();
  }

  /// 获取所有的文章数据
  void _getAllArticles() async {
    List list = await _entity.where(_entity);
    List<ArticleEntity> articles = list.map((e) => e as ArticleEntity).toList();
    _allArticleList = articles;
    notifyListeners();
  }

  ///
  List<ArticleEntity> get topArticles => _allArticleList.where((article) => article.type == 1).toList();

  List<ArticleEntity> get articleList => _allArticleList.where((article) => article.type == 0).toList();

  /// 分类整理展示所有的文章数据
  List<ArticleEntity> get articles => []
    ..addAll(topArticles)
    ..addAll(articleList);

  ArticleEntity? getArticle(int index) => articles.isEmpty ? null : articles[index];

  void updateArticles(List<ArticleEntity> articles) {
    _allArticleList.addAll(articles);
    // 保存article到数据库
    _entity.insert(articles);
    notifyListeners();
  }

  void updateArticle(ArticleEntity article) {
    int index = _allArticleList.indexOf(article);
    if (index != -1) {
      _allArticleList.insert(index, article);
      // 更新article数据
      _entity.update(article);
    } else {
      _allArticleList.add(article);
      // 保存article数据
      _entity.insert(article);
    }
    notifyListeners();
  }

  void clear() {
    _allArticleList.clear();
    notifyListeners();
  }
}
