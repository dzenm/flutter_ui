import 'package:flutter/material.dart';
import 'package:flutter_ui/entities/article_entity.dart';
import 'package:flutter_ui/main.dart';
import 'package:provider/provider.dart';

///
/// Created by a0010 on 2022/7/28 10:56
///
class ArticleModel extends ChangeNotifier {
  static ArticleModel get of => Provider.of<ArticleModel>(Application.context, listen: false);

  ArticleEntity _entity = ArticleEntity();

  List<ArticleEntity> _articles = [];

  ArticleModel() {
    _getAllArticles();
  }

  void _getAllArticles() async {
    List list = await _entity.where(_entity);
    List<ArticleEntity> articles = list.map((e) => e as ArticleEntity).toList();
    _articles = articles;
  }

  List<ArticleEntity> get articles => _articles;

  void updateArticles(List<ArticleEntity> articles) {
    _articles.clear();
    _articles = articles;
    _entity.insert(articles);
    notifyListeners();
  }

  void insertArticles(List<ArticleEntity> articles) {
    _articles.addAll(articles);
    _entity.insert(articles);
    notifyListeners();
  }
}

