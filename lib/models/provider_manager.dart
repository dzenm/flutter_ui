import 'package:flutter/material.dart';
import 'package:flutter_ui/application.dart';
import 'package:provider/provider.dart';

import '../pages/main/home_page/home_model.dart';
import '../pages/main/main_model.dart';
import '../pages/main/me_page/me_model.dart';
import '../pages/main/nav_page/nav_model.dart';
import '../pages/study/study_model.dart';
import 'article_model.dart';
import 'banner_model.dart';
import 'user_model.dart';
import 'website_model.dart';

///
/// Created by a0010 on 2022/7/28 10:56
/// 管理所有Provider Model状态
class ProviderManager {
  static bool _init = false;

  /// 初始化所有数据
  static Future<void> init(BuildContext context) async {
    if (_init) return;
    _init = true;

    // 表相关的Model
    await context.read<ArticleModel>().init();
    await context.read<BannerModel>().init();
    await context.read<UserModel>().init();
    await context.read<WebsiteModel>().init();

    // 页面相关的Model
    await context.read<MainModel>().init();
    await context.read<HomeModel>().init();
    await context.read<MeModel>().init();
    await context.read<NavModel>().init();
    await context.read<StudyModel>().init();
  }

  /// 清空所有数据
  static void clear(BuildContext context) {
    _init = false;
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

  static ArticleModel article({BuildContext? context, bool listen = false}) {
    return Provider.of<ArticleModel>(context ?? Application().context, listen: listen);
  }

  static BannerModel banner({BuildContext? context, bool listen = false}) {
    return Provider.of<BannerModel>(context ?? Application().context, listen: listen);
  }

  static UserModel user({BuildContext? context, bool listen = false}) {
    return Provider.of<UserModel>(context ?? Application().context, listen: listen);
  }

  static WebsiteModel website({BuildContext? context, bool listen = false}) {
    return Provider.of<WebsiteModel>(context ?? Application().context, listen: listen);
  }

  static MainModel main({BuildContext? context, bool listen = false}) {
    return Provider.of<MainModel>(context ?? Application().context, listen: listen);
  }

  static HomeModel home({BuildContext? context, bool listen = false}) {
    return Provider.of<HomeModel>(context ?? Application().context, listen: listen);
  }

  static MeModel me({BuildContext? context, bool listen = false}) {
    return Provider.of<MeModel>(context ?? Application().context, listen: listen);
  }

  static NavModel nav({BuildContext? context, bool listen = false}) {
    return Provider.of<NavModel>(context ?? Application().context, listen: listen);
  }

  static StudyModel study({BuildContext? context, bool listen = false}) {
    return Provider.of<StudyModel>(context ?? Application().context, listen: listen);
  }
}
