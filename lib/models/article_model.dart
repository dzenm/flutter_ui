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

  void _getAllArticles() async {
    List list = await _entity.where(_entity);
    List<ArticleEntity> articles = list.map((e) => e as ArticleEntity).toList();
    _allArticleList = articles;
  }

  List<ArticleEntity> get articles {
    List<ArticleEntity> topArticleList = _allArticleList.where((article) => article.type == 1).toList();
    List<ArticleEntity> articleList = _allArticleList.where((article) => article.type == 0).toList();
    List<ArticleEntity> articles = []
      ..addAll(topArticleList)
      ..addAll(articleList);
    return articles;
  }

  void updateArticles(List<ArticleEntity> articles) {
    _allArticleList.addAll(articles);
    // 保存article到数据库
    _entity.insert(articles);
    notifyListeners();
  }

  void clear() {
    _allArticleList.clear();
    notifyListeners();
  }
}