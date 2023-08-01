import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../application.dart';
import '../base/res/local_model.dart';
import '../pages/main/home/home_model.dart';
import '../pages/main/main_model.dart';
import '../pages/main/me/me_model.dart';
import '../pages/main/nav/nav_model.dart';
import '../pages/study/study_model.dart';
import 'article_model.dart';
import 'banner_model.dart';
import 'user_model.dart';
import 'website_model.dart';

///
/// Created by a0010 on 2022/7/28 10:56
/// 管理所有Provider Model状态
class ProviderManager {
  /// 清空所有数据
  static void clear({BuildContext? context}) {
    context ??= _context;
    // 表相关的Model
    context.read<ArticleModel>().clear();
    context.read<BannerModel>().clear();
    context.read<UserModel>().clear();
    context.read<ArticleModel>().clear();

    // 页面相关的Model
    context.read<MainModel>().clear();
    context.read<HomeModel>().clear();
    context.read<MeModel>().clear();
    context.read<NavModel>().clear();
    context.read<StudyModel>().clear();
  }

  static LocalModel local({BuildContext? context, bool listen = false}) {
    return Provider.of<LocalModel>(context ?? _context, listen: listen);
  }

  static ArticleModel article({BuildContext? context, bool listen = false}) {
    return Provider.of<ArticleModel>(context ?? _context, listen: listen);
  }

  static BannerModel banner({BuildContext? context, bool listen = false}) {
    return Provider.of<BannerModel>(context ?? _context, listen: listen);
  }

  static UserModel user({BuildContext? context, bool listen = false}) {
    return Provider.of<UserModel>(context ?? _context, listen: listen);
  }

  static WebsiteModel website({BuildContext? context, bool listen = false}) {
    return Provider.of<WebsiteModel>(context ?? _context, listen: listen);
  }

  static MainModel main({BuildContext? context, bool listen = false}) {
    return Provider.of<MainModel>(context ?? _context, listen: listen);
  }

  static HomeModel home({BuildContext? context, bool listen = false}) {
    return Provider.of<HomeModel>(context ?? _context, listen: listen);
  }

  static MeModel me({BuildContext? context, bool listen = false}) {
    return Provider.of<MeModel>(context ?? _context, listen: listen);
  }

  static NavModel nav({BuildContext? context, bool listen = false}) {
    return Provider.of<NavModel>(context ?? _context, listen: listen);
  }

  static StudyModel study({BuildContext? context, bool listen = false}) {
    return Provider.of<StudyModel>(context ?? _context, listen: listen);
  }

  static BuildContext get _context => Application().context;
}
