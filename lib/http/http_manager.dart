import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../application.dart';
import '../base/base.dart';
import '../entities/article_entity.dart';
import '../entities/banner_entity.dart';
import '../entities/chapter_entity.dart';
import '../entities/coin_entity.dart';
import '../entities/coin_record_entity.dart';
import '../entities/collect_entity.dart';
import '../entities/hotkey_entity.dart';
import '../entities/navi_entity.dart';
import '../entities/tool_entity.dart';
import '../entities/tree_entity.dart';
import '../entities/user_entity.dart';
import '../entities/website_entity.dart';
import '../models/provider_manager.dart';
import '../models/user_model.dart';
import '../pages/main/nav/nav_model.dart';
import '../pages/routers.dart';

///
/// Created by a0010 on 2022/10/25 13:11
///
class HttpManager {
  factory HttpManager() => instance;

  HttpManager._internal() {
    _httpClient = HttpsClient.instance;
  }

  static final HttpManager instance = HttpManager._internal();

  late HttpsClient _httpClient;

  /// 登录并进入到主页
  Future<void> login(String username, String password) async {
    await _httpClient.request(apiServices.login(username, password), success: (data) {
      UserEntity user = UserEntity.fromJson(data);

      String userId = user.id.toString();
      // 先保存SP，数据库创建需要用到SP的userId
      SpUtil.setUserLoginState(true);
      SpUtil.setUsername(user.username);
      SpUtil.setUserId(userId);
      // 设置用户数据库名称
      DBManager().userId = userId;
      // 设置用户文件夹路径
      FileUtil().initLoginUserDirectory(userId);

      // 更新数据
      context.read<UserModel>().user = user;
      AppRouter.of(context).push(Routers.main, clearStack: true);
    });
  }

  /// 注册并进入到主页
  Future<void> register(String username, String password, String rPassword) async {
    await _httpClient.request(apiServices.register(username, password, rPassword), success: (data) {
      UserEntity user = UserEntity.fromJson(data);

      // 先保存SP，数据库创建需要用到SP的userId
      SpUtil.setUserLoginState(true);
      SpUtil.setUsername(user.username);
      SpUtil.setUserId(user.id.toString());

      // 更新数据
      context.read<UserModel>().user = user;
      AppRouter.of(context).push(Routers.main, clearStack: true);
    });
  }

  /// 获取Banner，并保存banner数据
  Future<void> banner({
    void Function(List<BannerEntity> list)? success,
    bool isShowDialog = true,
  }) async {
    await _httpClient.request(apiServices.banner(), isShowDialog: isShowDialog, success: (data) async {
      List<dynamic> datas = ((data ?? []) as List<dynamic>);
      List<BannerEntity> list = datas.map((e) => BannerEntity.fromJson(e)).toList();
      if (success != null) success(list);
    });
  }

  /// 获取文章列表，并保存文章数据
  Future<void> getArticles({
    int page = 0,
    void Function(List<ArticleEntity> list, int? pageCount)? success,
    Failed? failed,
    bool isShowDialog = true,
    bool isShowToast = true,
  }) async {
    await _httpClient.request(apiServices.articleList(page), isShowDialog: isShowDialog, isShowToast: isShowToast, success: (data) async {
      PageEntity page = PageEntity.fromJson(data);

      List<dynamic> datas = page.datas ?? [];
      List<ArticleEntity> list = datas.map((e) => ArticleEntity.fromJson(e)).toList();
      if (success != null) success(list, page.pageCount);
    }, failed: (error) {
      if (failed != null) {
        failed(error);
      }
    });
  }

  /// 获取置顶文章列表，并保存文章数据
  Future<void> getTopArticles({
    void Function(List<ArticleEntity> list)? success,
    Failed? failed,
    bool isShowDialog = true,
  }) async {
    await _httpClient.request(apiServices.topArticleList(), isShowDialog: isShowDialog, success: (data) async {
      List<dynamic> datas = ((data ?? []) as List<dynamic>);
      List<ArticleEntity> list = datas.map((e) => ArticleEntity.fromJson(e)).toList();
      if (success != null) success(list);
    }, failed: (error) {
      if (failed != null) {
        failed(error);
      }
    });
  }

  /// 获取常用网站，并保存网站数据
  Future<void> getWebsites({
    void Function(List<WebsiteEntity> list)? success,
    Failed? failed,
    bool isShowDialog = true,
  }) async {
    await _httpClient.request(apiServices.friend(), isShowDialog: isShowDialog, success: (data) async {
      List<dynamic> datas = ((data ?? []) as List<dynamic>);
      List<WebsiteEntity> list = datas.map((e) => WebsiteEntity.fromJson(e)).toList();
      if (success != null) success(list);
    }, failed: (error) {
      if (failed != null) {
        failed(error);
      }
    });
  }

  /// 获取热词
  Future<void> getHotkeys({
    void Function(List<HotkeyEntity> list)? success,
    Failed? failed,
    bool isShowDialog = true,
  }) async {
    await _httpClient.request(apiServices.hotkey(), isShowDialog: isShowDialog, success: (data) async {
      List<dynamic> datas = ((data ?? []) as List<dynamic>);
      List<HotkeyEntity> list = datas.map((e) => HotkeyEntity.fromJson(e)).toList();
      if (success != null) success(list);
    }, failed: (error) {
      if (failed != null) {
        failed(error);
      }
    });
  }

  /// 获取体系数据
  Future<void> getTrees({
    void Function(List<TreeEntity> list)? success,
    Failed? failed,
    bool isShowDialog = true,
  }) async {
    await _httpClient.request(apiServices.tree(), isShowDialog: isShowDialog, success: (data) async {
      List<dynamic> datas = ((data ?? []) as List<dynamic>);
      List<TreeEntity> list = datas.map((e) => TreeEntity.fromJson(e)).toList();
      if (success != null) success(list);
    }, failed: (error) {
      if (failed != null) {
        failed(error);
      }
    });
  }

  /// 获取知识体系下的文章
  Future<void> getTreeArticlesByCid({
    int page = 0,
    int cid = 0,
    void Function(List<TreeEntity> list)? success,
    Failed? failed,
    bool isShowDialog = true,
  }) async {
    await _httpClient.request(
      apiServices.treeArticleListByCid(page, cid),
      isShowDialog: isShowDialog,
      success: (data) async {
        List<dynamic> datas = ((data ?? []) as List<dynamic>);
        List<TreeEntity> list = datas.map((e) => TreeEntity.fromJson(e)).toList();
        if (success != null) success(list);
      },
      failed: (error) {
        if (failed != null) {
          failed(error);
        }
      },
    );
  }

  /// 获取导航数据
  Future<void> getNavigates({
    void Function(List<NaviEntity> list)? success,
    Failed? failed,
    bool isShowDialog = true,
  }) async {
    await _httpClient.request(apiServices.navi(), isShowDialog: isShowDialog, success: (data) async {
      List<dynamic> datas = ((data ?? []) as List<dynamic>);
      List<NaviEntity> list = datas.map((e) => NaviEntity.fromJson(e)).toList();
      if (success != null) success(list);
    }, failed: (error) {
      if (failed != null) {
        failed(error);
      }
    });
  }

  /// 获取项目分类数据
  Future<void> getProject({
    void Function(List<TreeEntity> list)? success,
    Failed? failed,
    bool isShowDialog = true,
  }) async {
    await _httpClient.request(apiServices.project(), isShowDialog: isShowDialog, success: (data) async {
      List<dynamic> datas = ((data ?? []) as List<dynamic>);
      List<TreeEntity> list = datas.map((e) => TreeEntity.fromJson(e)).toList();
      if (success != null) success(list);
    }, failed: (error) {
      if (failed != null) {
        failed(error);
      }
    });
  }

  /// 根据id收藏/取消收藏文章
  Future<void> collect(
    int id, {
    bool collect = true,
    bool isShowDialog = true,
    void Function()? success,
    void Function()? failed,
  }) async {
    var future = collect ? apiServices.collectArticle(id) : apiServices.uncollectArticle(id);
    await _httpClient.request(future, isShowDialog: isShowDialog, success: (data) async {
      if (success != null) success();
    }, failed: (e) {
      if (failed != null) failed();
    });
  }

  /// 获取我的收藏文章列表
  Future<void> getCollectArticles({
    int page = 0,
    void Function(List<CollectEntity> list, int? pageCount)? success,
    Failed? failed,
    bool isShowDialog = true,
  }) async {
    await _httpClient.request(
      apiServices.collect(page),
      isShowDialog: isShowDialog,
      success: (data) async {
        PageEntity page = PageEntity.fromJson(data);

        List<dynamic> datas = page.datas ?? [];
        List<CollectEntity> list = datas.map((e) => CollectEntity.fromJson(e)).toList();
        if (success != null) success(list, page.pageCount);
      },
      failed: (error) {
        if (failed != null) {
          failed(error);
        }
      },
    );
  }

  /// 获取积分排行榜
  Future<void> getRankCoins({
    int page = 1,
    void Function(List<CoinEntity> list, int? pageCount)? success,
    Failed? failed,
    bool isShowDialog = true,
  }) async {
    await _httpClient.request(
      apiServices.rankCoin(page),
      isShowDialog: isShowDialog,
      success: (data) async {
        PageEntity page = PageEntity.fromJson(data);

        List<dynamic> datas = page.datas ?? [];
        List<CoinEntity> list = datas.map((e) => CoinEntity.fromJson(e)).toList();
        if (success != null) success(list, page.pageCount);
      },
      failed: (error) {
        if (failed != null) {
          failed(error);
        }
      },
    );
  }

  /// 获取个人积分获列表
  Future<void> getCoins({
    int page = 1,
    void Function(List<CoinRecordEntity> list, int? pageCount)? success,
    Failed? failed,
    bool isShowDialog = true,
  }) async {
    await _httpClient.request(
      apiServices.coins(page),
      isShowDialog: isShowDialog,
      success: (data) async {
        PageEntity page = PageEntity.fromJson(data);

        List<dynamic> datas = page.datas ?? [];
        List<CoinRecordEntity> list = datas.map((e) => CoinRecordEntity.fromJson(e)).toList();
        if (success != null) success(list, page.pageCount);
      },
      failed: (error) {
        if (failed != null) {
          failed(error);
        }
      },
    );
  }

  /// 获取广场列表数据
  Future<void> getPlazas({
    int page = 0,
    void Function(int? pageCount)? success,
    Failed? failed,
  }) async {
    await HttpsClient().request(
      apiServices.userArticles(page),
      isShowDialog: false,
      success: (data) async {
        PageEntity page = PageEntity.fromJson(data);

        List<dynamic> datas = page.datas ?? [];
        List<ArticleEntity> list = datas.map((e) => ArticleEntity.fromJson(e)).toList();
        context.read<NavModel>().updatePlazaArticles(list);
        if (success != null) success(page.pageCount);
      },
      failed: (error) {
        if (failed != null) {
          failed(error);
        }
      },
    );
  }

  /// 获取教程数据
  Future<void> getChapters({
    void Function()? success,
    Failed? failed,
  }) async {
    await HttpsClient().request(
      apiServices.chapter(),
      isShowDialog: false,
      success: (data) async {
        List<dynamic> datas = data;
        List<ChapterEntity> list = datas.map((e) => ChapterEntity.fromJson(e)).toList();
        context.read<NavModel>().updateChapters(list);
        if (success != null) success();
      },
      failed: (error) {
        if (failed != null) {
          failed(error);
        }
      },
    );
  }

  /// 获取问答列表
  Future<void> getQuestions({
    int page = 0,
    void Function(int? pageCount)? success,
    Failed? failed,
  }) async {
    await HttpsClient().request(
      apiServices.userArticles(page),
      isShowDialog: false,
      success: (data) async {
        PageEntity page = PageEntity.fromJson(data);

        List<dynamic> datas = page.datas ?? [];
        List<ArticleEntity> list = datas.map((e) => ArticleEntity.fromJson(e)).toList();
        context.read<NavModel>().updateQAArticles(list);
        if (success != null) success(page.pageCount);
      },
      failed: (error) {
        if (failed != null) {
          failed(error);
        }
      },
    );
  }

  /// 获取最新项目列表
  Future<void> getProjects({
    int page = 0,
    void Function(int? pageCount)? success,
    Failed? failed,
  }) async {
    await HttpsClient().request(
      apiServices.projects(page),
      isShowDialog: false,
      success: (data) async {
        PageEntity page = PageEntity.fromJson(data);

        List<dynamic> datas = page.datas ?? [];
        List<ArticleEntity> list = datas.map((e) => ArticleEntity.fromJson(e)).toList();
        context.read<NavModel>().updateProjectArticles(list);
        if (success != null) success(page.pageCount);
      },
      failed: (error) {
        if (failed != null) {
          failed(error);
        }
      },
    );
  }

  /// 获取公众号数据
  Future<void> getBlogChapters({
    void Function()? success,
    Failed? failed,
  }) async {
    await HttpsClient().request(
      apiServices.chapters(),
      isShowDialog: false,
      success: (data) async {
        List<dynamic> datas = data;
        List<ChapterEntity> list = datas.map((e) => ChapterEntity.fromJson(e)).toList();
        context.read<NavModel>().updateBlogChapters(list);
        if (success != null) success();
      },
      failed: (error) {
        if (failed != null) {
          failed(error);
        }
      },
    );
  }

  /// 获取工具数据
  Future<void> getTools({
    void Function()? success,
    Failed? failed,
  }) async {
    await HttpsClient().request(
      apiServices.tools(),
      isShowDialog: false,
      success: (data) async {
        List<dynamic> datas = data;
        List<ToolEntity> list = datas.map((e) => ToolEntity.fromJson(e)).toList();
        context.read<NavModel>().updateTools(list);
        if (success != null) success();
      },
      failed: (error) {
        if (failed != null) {
          failed(error);
        }
      },
    );
  }

  /// 获取我分享的文章列表
  Future<void> getPrivateArticles({
    int page = 1,
    void Function(dynamic data)? success,
    Failed? failed,
    bool isShowDialog = true,
  }) async {
    await _httpClient.request(
      apiServices.privateArticles(page),
      isShowDialog: isShowDialog,
      success: (data) async {
        if (success != null) success(data);
      },
      failed: (error) {
        if (failed != null) {
          failed(error);
        }
      },
    );
  }

  /// 获取用户信息
  Future<void> getUserinfo({
    void Function(dynamic data)? success,
    Failed? failed,
  }) async {
    await _httpClient.request(apiServices.userinfo(), isShowDialog: false, success: (data) async {
      if (success != null) success(data);
    }, failed: (error) {
      if (failed != null) {
        failed(error);
      }
    });
  }

  Future<void> logout() async {
    await _httpClient.request(apiServices.logout(), success: (data) {
      SpUtil.clearUser();
      ProviderManager.clear();
      AppRouterDelegate.of(Application().context).push(Routers.login, clearStack: true);
    });
  }

  BuildContext get context => Application().context;
}
