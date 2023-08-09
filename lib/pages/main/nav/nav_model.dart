import 'package:flutter/widgets.dart';

import '../../../entities/article_entity.dart';
import '../../../entities/chapter_entity.dart';
import '../../../entities/tool_entity.dart';

///
/// Created by a0010 on 2022/7/28 10:56
/// Provider中共享的Nav页面数据
class NavModel with ChangeNotifier {
  /// 初始化数据
  Future<void> init() async {}

  /// 广场文章的数据
  final List<ArticleEntity> _plazaArticles = [];

  List<ArticleEntity> get plazaArticles => _plazaArticles;

  void updatePlazaArticles(List<ArticleEntity> articles) {
    for (var article in articles) {
      int index = _plazaArticles.indexWhere((e) => e.id == article.id);
      if (index == -1) {
        _plazaArticles.add(article);
      } else {
        _plazaArticles[index] = article;
      }
    }
    notifyListeners();
  }

  /// 教程的数据
  final List<ChapterEntity> _chapters = [];

  List<ChapterEntity> get chapters => _chapters;

  void updateChapters(List<ChapterEntity> chapters) {
    for (var chapter in chapters) {
      int index = _chapters.indexWhere((e) => e.id == chapter.id);
      if (index == -1) {
        _chapters.add(chapter);
      } else {
        _chapters[index] = chapter;
      }
    }
    notifyListeners();
  }

  /// 问答文章的数据
  final List<ArticleEntity> _qaArticles = [];

  List<ArticleEntity> get qaArticles => _qaArticles;

  void updateQAArticles(List<ArticleEntity> articles) {
    for (var article in articles) {
      int index = _qaArticles.indexWhere((e) => e.id == article.id);
      if (index == -1) {
        _qaArticles.add(article);
      } else {
        _qaArticles[index] = article;
      }
    }
    notifyListeners();
  }

  /// 项目文章的数据
  final List<ArticleEntity> _projectArticles = [];

  List<ArticleEntity> get projectArticles => _projectArticles;

  void updateProjectArticles(List<ArticleEntity> articles) {
    for (var article in articles) {
      int index = _projectArticles.indexWhere((e) => e.id == article.id);
      if (index == -1) {
        _projectArticles.add(article);
      } else {
        _projectArticles[index] = article;
      }
    }
    notifyListeners();
  }

  /// 公众号的数据
  final List<ChapterEntity> _blogChapters = [];

  List<ChapterEntity> get blogChapters => _blogChapters;

  void updateBlogChapters(List<ChapterEntity> chapters) {
    for (var chapter in chapters) {
      int index = _blogChapters.indexWhere((e) => e.id == chapter.id);
      if (index == -1) {
        _blogChapters.add(chapter);
      } else {
        _blogChapters[index] = chapter;
      }
    }
    notifyListeners();
  }

  /// 工具的数据
  final List<ToolEntity> _tools = [];

  List<ToolEntity> get tools => _tools;

  void updateTools(List<ToolEntity> tools) {
    for (var tool in tools) {
      int index = _tools.indexWhere((e) => e.id == tool.id);
      if (index == -1) {
        _tools.add(tool);
      } else {
        _tools[index] = tool;
      }
    }
    notifyListeners();
  }

  /// 清空数据
  void clear() {
    notifyListeners();
  }
}
