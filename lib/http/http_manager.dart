import 'package:flutter_ui/application.dart';
import 'package:flutter_ui/base/http/https_client.dart';
import 'package:flutter_ui/base/http/page_entity.dart';
import 'package:flutter_ui/base/route/app_route_delegate.dart';
import 'package:flutter_ui/entities/article_entity.dart';
import 'package:flutter_ui/entities/banner_entity.dart';
import 'package:flutter_ui/entities/coin_entity.dart';
import 'package:flutter_ui/entities/coin_record_entity.dart';
import 'package:flutter_ui/entities/collect_entity.dart';
import 'package:flutter_ui/entities/hotkey_entity.dart';
import 'package:flutter_ui/entities/navi_entity.dart';
import 'package:flutter_ui/entities/tree_entity.dart';
import 'package:flutter_ui/entities/website_entity.dart';
import 'package:flutter_ui/http/api_services.dart';
import 'package:flutter_ui/pages/routers.dart';

import '../base/utils/sp_util.dart';
import '../models/provider_manager.dart';

///
/// Created by a0010 on 2022/10/25 13:11
///
class HttpManager {
  factory HttpManager() => instance;

  HttpManager._internal() {
    _httpClient = HttpsClient.instance;
    _apiServices = apiServices;
  }

  static final HttpManager instance = HttpManager._internal();

  late HttpsClient _httpClient;
  late ApiServices _apiServices;

  /// 获取Banner，并保存banner数据
  Future<void> banner({
    void Function(List<BannerEntity> list)? success,
    bool isShowDialog = true,
  }) async {
    await _httpClient.request(_apiServices.banner(), isShowDialog: isShowDialog, success: (data) async {
      List<dynamic> datas = ((data ?? []) as List<dynamic>);
      List<BannerEntity> list = datas.map((e) => BannerEntity.fromJson(e)).toList();
      if (success != null) success(list);
    });
  }

  /// 获取article，并保存article数据
  Future<void> getArticleList({
    int page = 0,
    void Function(List<ArticleEntity> list, int? pageCount)? success,
    Failed? failed,
    bool isShowDialog = true,
    bool isShowToast = true,
  }) async {
    await HttpsClient.instance.request(apiServices.articleList(page), isShowDialog: isShowDialog, isShowToast: isShowToast, success: (data) async {
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

  /// 获取置顶article，并保存article数据
  Future<void> getLopArticleList({
    void Function(List<ArticleEntity> list)? success,
    Failed? failed,
    bool isShowDialog = true,
  }) async {
    await HttpsClient.instance.request(apiServices.topArticleList(), isShowDialog: isShowDialog, success: (data) async {
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
  Future<void> getWebsiteList({
    void Function(List<WebsiteEntity> list)? success,
    Failed? failed,
    bool isShowDialog = true,
  }) async {
    await HttpsClient.instance.request(apiServices.friend(), isShowDialog: isShowDialog, success: (data) async {
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
  Future<void> getHotkeyList({
    void Function(List<HotkeyEntity> list)? success,
    Failed? failed,
    bool isShowDialog = true,
  }) async {
    await HttpsClient.instance.request(apiServices.hotkey(), isShowDialog: isShowDialog, success: (data) async {
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
  Future<void> getTreeList({
    void Function(List<TreeEntity> list)? success,
    Failed? failed,
    bool isShowDialog = true,
  }) async {
    await HttpsClient.instance.request(apiServices.tree(), isShowDialog: isShowDialog, success: (data) async {
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
  Future<void> getTreeArticleListByCid({
    int page = 0,
    int cid = 0,
    void Function(List<TreeEntity> list)? success,
    Failed? failed,
    bool isShowDialog = true,
  }) async {
    await HttpsClient.instance.request(
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
  Future<void> getNaviList({
    void Function(List<NaviEntity> list)? success,
    Failed? failed,
    bool isShowDialog = true,
  }) async {
    await HttpsClient.instance.request(apiServices.navi(), isShowDialog: isShowDialog, success: (data) async {
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
  Future<void> getProjectList({
    void Function(List<TreeEntity> list)? success,
    Failed? failed,
    bool isShowDialog = true,
  }) async {
    await HttpsClient.instance.request(apiServices.project(), isShowDialog: isShowDialog, success: (data) async {
      List<dynamic> datas = ((data ?? []) as List<dynamic>);
      List<TreeEntity> list = datas.map((e) => TreeEntity.fromJson(e)).toList();
      if (success != null) success(list);
    }, failed: (error) {
      if (failed != null) {
        failed(error);
      }
    });
  }

  /// 获取我收藏的article
  Future<void> getCollectArticleList({
    int page = 0,
    void Function(List<CollectEntity> list, int? pageCount)? success,
    Failed? failed,
    bool isShowDialog = true,
  }) async {
    await HttpsClient.instance.request(apiServices.collect(page), isShowDialog: isShowDialog, success: (data) async {
      PageEntity page = PageEntity.fromJson(data);

      List<dynamic> datas = page.datas ?? [];
      List<CollectEntity> list = datas.map((e) => CollectEntity.fromJson(e)).toList();
      if (success != null) success(list, page.pageCount);
    }, failed: (error) {
      if (failed != null) {
        failed(error);
      }
    });
  }

  /// 根据id收藏/取消收藏article
  Future<void> collect(
    int id, {
    bool collect = true,
    bool isShowDialog = true,
    void Function()? success,
  }) async {
    var future = collect ? apiServices.collectArticle(id) : apiServices.uncollectArticle(id);
    await HttpsClient.instance.request(future, isShowDialog: isShowDialog, success: (data) async {
      if (success != null) success();
    });
  }

  /// 获取积分排行榜
  Future<void> getRankCoinList({
    int page = 1,
    void Function(List<CoinEntity> list, int? pageCount)? success,
    Failed? failed,
    bool isShowDialog = true,
  }) async {
    await HttpsClient.instance.request(apiServices.rankCoin(page), isShowDialog: isShowDialog, success: (data) async {
      PageEntity page = PageEntity.fromJson(data);

      List<dynamic> datas = page.datas ?? [];
      List<CoinEntity> list = datas.map((e) => CoinEntity.fromJson(e)).toList();
      if (success != null) success(list, page.pageCount);
    }, failed: (error) {
      if (failed != null) {
        failed(error);
      }
    });
  }

  /// 获取积分排行榜
  Future<void> getCoinList({
    int page = 1,
    void Function(List<CoinRecordEntity> list, int? pageCount)? success,
    Failed? failed,
    bool isShowDialog = true,
  }) async {
    await HttpsClient.instance.request(apiServices.coins(page), isShowDialog: isShowDialog, success: (data) async {
      PageEntity page = PageEntity.fromJson(data);

      List<dynamic> datas = page.datas ?? [];
      List<CoinRecordEntity> list = datas.map((e) => CoinRecordEntity.fromJson(e)).toList();
      if (success != null) success(list, page.pageCount);
    }, failed: (error) {
      if (failed != null) {
        failed(error);
      }
    });
  }

  /// 获取我分享的文章列表
  Future<void> getPrivateArticleList({
    int page = 1,
    void Function(dynamic data)? success,
    Failed? failed,
    bool isShowDialog = true,
  }) async {
    await HttpsClient.instance.request(apiServices.privateArticles(page), isShowDialog: isShowDialog, success: (data) async {
      if (success != null) success(data);
    }, failed: (error) {
      if (failed != null) {
        failed(error);
      }
    });
  }

  /// 获取用户信息
  Future<void> getUserinfo({
    void Function(dynamic data)? success,
    Failed? failed,
  }) async {
    await HttpsClient.instance.request(apiServices.userinfo(), isShowDialog: false, success: (data) async {
      if (success != null) success(data);
    }, failed: (error) {
      if (failed != null) {
        failed(error);
      }
    });
  }

  /// 获取问答article，并保存article数据
  Future<void> getQuestionsList({
    int page = 0,
    void Function(List<ArticleEntity> list, int? pageCount)? success,
    Failed? failed,
    bool isShowDialog = true,
    bool isShowToast = true,
  }) async {
    await HttpsClient.instance.request(apiServices.questions(page), isShowDialog: isShowDialog, isShowToast: isShowToast, success: (data) async {
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


  Future<void> logout() async {
    await HttpsClient.instance.request(apiServices.logout(), success: (data) {
      SpUtil.clearUser();
      ProviderManager.clear(Application().context);
      AppRouteDelegate.of(Application().context).push(Routers.login, clearStack: true);
    });
  }
}
