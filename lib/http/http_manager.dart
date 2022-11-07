import 'package:flutter_ui/base/entities/page_entity.dart';
import 'package:flutter_ui/base/http/api_client.dart';
import 'package:flutter_ui/entities/article_entity.dart';
import 'package:flutter_ui/entities/banner_entity.dart';
import 'package:flutter_ui/http/api_services.dart';

///
/// Created by a0010 on 2022/10/25 13:11
///
class HttpManager {
  factory HttpManager() => getInstance;

  HttpManager._internal() {
    _apiClient = ApiClient.getInstance;
    _apiServices = apiServices;
  }

  static final HttpManager getInstance = HttpManager._internal();

  late ApiClient _apiClient;
  late ApiServices _apiServices;

  /// 获取Banner请求，并保存banner请求数据
  Future<void> banner({
    void Function(List<BannerEntity> list)? success,
  }) async {
    await _apiClient.request(_apiServices.banner(), success: (data) async {
      BannerEntity entity = BannerEntity();
      List<BannerEntity> list = (data as List<dynamic>).map((e) => entity.fromJson(e)).toList();

      if (success != null) success(list);
    });
  }

  /// 获取article请求，并保存article请求数据
  Future<void> getArticleList({
    int page = 0,
    void Function(List<ArticleEntity> list, int? total)? success,
    void Function(HttpError error)? failed,
    bool isShowDialog = true,
    bool isShowToast = true,
  }) async {
    await ApiClient.getInstance.request(apiServices.articleList(page), isShowDialog: isShowDialog, isShowToast: isShowToast, success: (data) async {
      PageEntity pageEntity = PageEntity.fromJson(data);

      List<ArticleEntity> list = (data["datas"] as List<dynamic>).map((e) => ArticleEntity().fromJson(e)).toList();
      if (success != null) success(list, pageEntity.total);
    }, failed: (error) {
      if (failed != null) {
        failed(error);
      }
    });
  }

  /// 获取置顶article请求，并保存article请求数据
  Future<void> getLopArticleList({
    void Function(List<ArticleEntity> list)? success,
    void Function(HttpError error)? failed,
    bool isShowDialog = true,
  }) async {
    await ApiClient.getInstance.request(apiServices.topArticleList(), isShowDialog: isShowDialog, success: (data) async {
      List<ArticleEntity> list = (data as List<dynamic>).map((e) => ArticleEntity().fromJson(e)).toList();
      if (success != null) success(list);
    }, failed: (error) {
      if (failed != null) {
        failed(error);
      }
    });
  }
}
