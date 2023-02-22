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

  /// 置顶的文章数据
  List<ArticleEntity> get topArticles => _allArticleList.where((article) => article.type == 1).toList();

  /// 普通的文章数据
  List<ArticleEntity> get articles => _allArticleList.where((article) => article.type == 0).toList();

  /// 所有的文章数据，置顶的排在前面，普通的排在后面
  List<ArticleEntity> get allArticles => []
    ..addAll(topArticles)
    ..addAll(articles);

  ArticleEntity? getArticle(int index) => allArticles.isEmpty ? null : allArticles[index];

  void updateArticles(List<ArticleEntity> articles) {
    articles.forEach((article) => _handleArticle(article));
    notifyListeners();
  }

  void updateArticle(ArticleEntity article) {
    _handleArticle(article);
    notifyListeners();
  }

  /// 处理文章数据
  Future<void> _handleArticle(ArticleEntity article) async {
    int index = _allArticleList.indexOf(article);
    if (index != -1) {
      _allArticleList.insert(index, article);
      _entity.update(article); // 更新DB中的article数据
    } else {
      _allArticleList.add(article);
      _entity.insert(article); // 保存为DB中的article数据
    }
  }

  void clear() {
    _allArticleList.clear();
    notifyListeners();
  }
}
