import 'package:dio/dio.dart';
import 'package:flutter_ui/base/entities/data_entity.dart';
import 'package:retrofit/http.dart';

part 'api_services.g.dart';

@RestApi()
abstract class ApiServices {
  factory ApiServices(Dio dio, {String? baseUrl}) = _ApiServices;

  /// 登录请求 [ https://www.wanandroid.com/user/login ]
  @POST('user/login')
  Future<DataEntity> login(
    @Query('username') String username, // 用户名/手机号
    @Query('password') String password, // 密码
  );

  /// 登录请求 [ http://192.168.2.30:8080/api/v1/login ]
  @POST('login')
  Future<DataEntity> testLogin(
    @Query('username') String username, // 用户名/手机号
    @Query('password') String password, // 密码
  );

  /// 注册请求 [ https://www.wanandroid.com/user/register ]
  @POST('user/register')
  Future<DataEntity> register(
    @Query('username') String username, // 用户名/手机号
    @Query('password') String password, // 密码
    @Query('repassword') String repassword, // 密码
  );

  /// 退出登录请求 [ https://www.wanandroid.com/user/logout/json ]
  @GET('user/logout/json')
  Future<DataEntity> logout();

  /// 获取首页文章请求 [ https://www.wanandroid.com/article/list/0/json ]
  @GET('article/list/{pageNumber}/json')
  Future<DataEntity> articleList(
    @Path("pageNumber") int pageNumber,
  );

  /// 获取置顶文章请求 [ https://www.wanandroid.com/article/top/json ]
  @GET('article/top/json')
  Future<DataEntity> topArticleList();

  /// 获取首页banner请求 [ https://www.wanandroid.com/banner/json ]
  @GET('banner/json')
  Future<DataEntity> banner();

  /// 获取常用网站请求 [ https://www.wanandroid.com/friend/json ]
  @GET('friend/json')
  Future<DataEntity> friend();

  /// 获取搜索热词请求 [ https://www.wanandroid.com//hotkey/json ]
  @GET('hotkey/json')
  Future<DataEntity> hotkey();

  /// 获取体系数据请求 [ https://www.wanandroid.com/tree/json ]
  @GET('tree/json')
  Future<DataEntity> tree();

  /// 获取知识体系下的文章请求 [ https://www.wanandroid.com/article/list/0/json?cid=60 ]
  @GET('article/list/{pageNumber}/json')
  Future<DataEntity> treeArticleListByCid(
    @Path("pageNumber") int pageNumber, // 页码拼接在链接上，从0开始
    @Query('cid') int cid, // 分类的id，上述二级目录的id
  );

  /// 获取作者昵称搜索文章请求 [ https://wanandroid.com/article/list/0/json?author=鸿洋 ]
  @GET('article/list/{pageNumber}/json')
  Future<DataEntity> treeArticleListByAuthor(
    @Path("pageNumber") int pageNumber, // 页码拼接在链接上，从0开始
    @Query('author') String author, // 作者昵称，不支持模糊匹配。
  );

  /// 获取导航数据请求 [ https://www.wanandroid.com/navi/json ]
  @GET('navi/json')
  Future<DataEntity> navi();

  /// 获取项目分类数据请求 [ https://www.wanandroid.com/project/tree/json ]
  @GET('project/tree/json')
  Future<DataEntity> project();

  /// 获取项目列表数据请求 [ https://www.wanandroid.com/project/list/1/json?cid=294 ]
  @GET('project/list/{pageNumber}/json')
  Future<DataEntity> projectArticleListByCid(
    @Path("pageNumber") int pageNumber, // 页码拼接在链接上，从1开始
    @Query('cid') int cid, // 分类的id，上面项目分类接口
  );

  /// 获取收藏文章列表请求 [ https://www.wanandroid.com/lg/collect/list/0/json ]
  @GET('lg/collect/list/{pageNumber}/json')
  Future<DataEntity> collect(
    @Path("pageNumber") int pageNumber, // 页码拼接在链接上，从0开始
  );

  /// 更新收藏站内文章请求 [ https://www.wanandroid.com/lg/collect/1165/json ]
  @POST('lg/collect/{id}/json')
  Future<DataEntity> collectArticle(
    @Path("id") int id, // 文章id，拼接在链接中。
  );

  /// 查询中药详情请求
  @GET('zhongyao/index')
  Future<DataEntity> getZhongYao(
    @Query('key') String key,
    @Query('word') String word,
  );
}
