import 'package:flutter/material.dart';
import 'package:flutter_ui/models/article_model.dart';
import 'package:flutter_ui/pages/main/home_page/home_model.dart';
import 'package:flutter_ui/pages/main/main_model.dart';
import 'package:flutter_ui/pages/main/me_page/me_model.dart';
import 'package:flutter_ui/pages/main/nav_page/nav_model.dart';
import 'package:flutter_ui/pages/study/study_model.dart';
import 'package:provider/provider.dart';

import 'banner_model.dart';
import 'user_model.dart';
import 'website_model.dart';

///
/// Created by a0010 on 2022/7/28 10:56
/// 管理所有Provider Model状态
class ProviderManager {
  static bool _init = false;

  static void initData(BuildContext context) {
    if (_init) return;
    _init = true;

    context.read<MainModel>().initData(context);
  }

  /// 初始化所有数据
  static Future<void> init(BuildContext context) async {
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

  static ArticleModel getArticle(BuildContext context) {
    return context.read<ArticleModel>();
  }

  static BannerModel getBanner(BuildContext context) {
    return context.read<BannerModel>();
  }

  static UserModel getUser(BuildContext context) {
    return context.read<UserModel>();
  }

  static WebsiteModel getWebsite(BuildContext context) {
    return context.read<WebsiteModel>();
  }

  static MainModel getMain(BuildContext context) {
    return context.read<MainModel>();
  }

  static HomeModel getHome(BuildContext context) {
    return context.read<HomeModel>();
  }

  static MeModel getMe(BuildContext context) {
    return context.read<MeModel>();
  }

  static NavModel getNav(BuildContext context) {
    return context.read<NavModel>();
  }

  static StudyModel getStudy(BuildContext context) {
    return context.read<StudyModel>();
  }
}
