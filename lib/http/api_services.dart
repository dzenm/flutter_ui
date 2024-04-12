import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';

import '../base/http/http.dart';

part 'api_services.g.dart';

@RestApi()
abstract class ApiServices {
  factory ApiServices(Dio dio, {String? baseUrl}) = _ApiServices;

  ///=============================== 一、首页相关 ==============================================
  /// 1.1 获取首页文章列表 [ https://www.wanandroid.com/article/list/0/json ]
  @GET('article/list/{pageNumber}/json')
  Future<DataEntity> articleList(
    @Path("pageNumber") int pageNumber, // 页码拼接在链接上，从0开始,
    {
    @Query('page_size') int? pageSize, // 取值为[1-40]，不传则使用默认值，一旦传入了 page_size，后续该接口分页都需要带上，否则会造成分页读取错误。
  });

  /// 1.2 获取首页banner [ https://www.wanandroid.com/banner/json ]
  @GET('banner/json')
  Future<DataEntity> banner();

  /// 1.3 获取常用网站 [ https://www.wanandroid.com/friend/json ]
  @GET('friend/json')
  Future<DataEntity> friend();

  /// 1.4 获取搜索热词 [ https://www.wanandroid.com//hotkey/json ]
  @GET('hotkey/json')
  Future<DataEntity> hotkey();

  /// 1.5 获取置顶文章 [ https://www.wanandroid.com/article/top/json ]
  @GET('article/top/json')
  Future<DataEntity> topArticleList();

  ///=============================== 二、体系 ==============================================
  /// 2.1 获取体系数据 [ https://www.wanandroid.com/tree/json ]
  @GET('tree/json')
  Future<DataEntity> tree();

  /// 2.2 获取知识体系下的文章 [ https://www.wanandroid.com/article/list/0/json?cid=60 ]
  @GET('article/list/{pageNumber}/json')
  Future<DataEntity> treeArticleListByCid(
    @Path("pageNumber") int pageNumber, // 页码拼接在链接上，从0开始
    @Query('cid') int cid, // 分类的id，上述二级目录的id
    {
    @Query('page_size') int? pageSize, // 取值为[1-40]，不传则使用默认值，一旦传入了 page_size，后续该接口分页都需要带上，否则会造成分页读取错误。
  });

  /// 2.3 获取作者昵称搜索文章 [ https://wanandroid.com/article/list/0/json?author=鸿洋 ]
  @GET('article/list/{pageNumber}/json')
  Future<DataEntity> treeArticleListByAuthor(
    @Path("pageNumber") int pageNumber, // 页码拼接在链接上，从0开始
    @Query('author') String author, // 作者昵称，不支持模糊匹配。
    {
    @Query('page_size') int? pageSize, // 取值为[1-40]，不传则使用默认值，一旦传入了 page_size，后续该接口分页都需要带上，否则会造成分页读取错误。
  });

  ///=============================== 三、导航 ==============================================
  /// 3.1 获取导航数据 [ https://www.wanandroid.com/navi/json ]
  @GET('navi/json')
  Future<DataEntity> navi();

  ///=============================== 四、项目 ==============================================
  /// 4.1 获取项目分类 [ https://www.wanandroid.com/project/tree/json ]
  @GET('project/tree/json')
  Future<DataEntity> project();

  /// 4.2 获取项目列表 [ https://www.wanandroid.com/project/list/1/json?cid=294 ]
  @GET('project/list/{pageNumber}/json')
  Future<DataEntity> projectArticleListByCid(
    @Path("pageNumber") int pageNumber, // 页码拼接在链接上，从1开始
    @Query('cid') int cid, // 分类的id，上面项目分类接口
    {
    @Query('page_size') int? pageSize, // 取值为[1-40]，不传则使用默认值，一旦传入了 page_size，后续该接口分页都需要带上，否则会造成分页读取错误。
  });

  ///=============================== 五、登录与注册 ==============================================
  /// 5.1 登录 [ https://www.wanandroid.com/user/login ]
  @POST('user/login')
  Future<DataEntity> login(
    @Query('username') String username, // 用户名/手机号
    @Query('password') String password, // 密码
  );

  /// 5.2 注册 [ https://www.wanandroid.com/user/register ]
  @POST('user/register')
  Future<DataEntity> register(
    @Query('username') String username, // 用户名/手机号
    @Query('password') String password, // 密码
    @Query('repassword') String repassword, // 密码
  );

  /// 5.3 退出 [ https://www.wanandroid.com/user/logout/json ]
  @GET('user/logout/json')
  Future<DataEntity> logout();

  /// 登录请求 [ http://192.168.2.30:8080/api/v1/login ]
  @POST('login')
  Future<DataEntity> testLogin(
    @Query('username') String username, // 用户名/手机号
    @Query('password') String password, // 密码
  );

  ///=============================== 六、收藏 ==============================================
  /// 6.1 获取收藏文章列表 [ https://www.wanandroid.com/lg/collect/list/0/json ]
  @GET('lg/collect/list/{pageNumber}/json')
  Future<DataEntity> collect(
    @Path("pageNumber") int pageNumber, // 页码拼接在链接上，从0开始
    {
    @Query('page_size') int? pageSize, // 取值为[1-40]，不传则使用默认值，一旦传入了 page_size，后续该接口分页都需要带上，否则会造成分页读取错误。
  });

  /// 6.2 收藏站内文章请求 [ https://www.wanandroid.com/lg/collect/1165/json ]
  @POST('lg/collect/{id}/json')
  Future<DataEntity> collectArticle(
    @Path("id") int id, // 文章id，拼接在链接中。
  );

  /// 6.3.1 收藏站外文章请求 [ https://www.wanandroid.com/lg/collect/add/json ]
  @POST('lg/collect/add/json')
  Future<DataEntity> collectOtherArticle(
    @Query('title') String title, // 文章标题
    @Query('author') String author, // 作者
    @Query('link') String link, // 文章 url
  );

  /// 6.3.2 编辑收藏的文章请求，支持站内，站外 [ https://wanandroid.com/lg/collect/user_article/update/id/json ]
  @POST('lg/collect/user_article/update/{id}/json')
  Future<DataEntity> editCollectArticle(
    @Path("id") int id, // 文章id，拼接在链接中。
    @Query('title') String title, // 文章标题
    @Query('author') String author, // 作者
    @Query('link') String link, // 文章 url
  );

  /// 6.4.1 取消收藏文章请求（文章列表） [ https://www.wanandroid.com/lg/uncollect_originId/2333/json ]
  @POST('lg/uncollect_originId/{id}/json')
  Future<DataEntity> uncollectArticle(
    @Path("id") int id, // 文章id，拼接在链接中。
  );

  /// 6.4.2 取消收藏文章请求（我的收藏页面（该页面包含自己录入的内容）） [ https://www.wanandroid.com/lg/uncollect/2805/json ]
  @POST('lg/uncollect/{id}/json')
  Future<DataEntity> uncollectMyArticle(
    @Path("id") int id, // 文章id，拼接在链接中。
    @Path("originId") int originId, // 列表页下发，无则为-1。
  );

  /// 6.5 收藏网站列表 [ https://www.wanandroid.com/lg/collect/usertools/json ]
  @GET('lg/collect/usertools/json')
  Future<DataEntity> userTools();

  /// 6.6 收藏网址 [ https://www.wanandroid.com/lg/collect/addtool/json ]
  @POST('lg/collect/addtool/json')
  Future<DataEntity> addTool(
    @Query('name') String name, // 工具名称
    @Query('link') String link, // 工具 url
  );

  /// 6.7 编辑收藏网站 [ https://www.wanandroid.com/lg/collect/updatetool/json ]
  @POST('lg/collect/updatetool/json')
  Future<DataEntity> updateTool(
    @Query("id") int id, // 工具id。
    @Query('name') String name, // 工具名称
    @Query('link') String link, // 工具 url
  );

  /// 6.8 删除收藏网站 [ https://www.wanandroid.com/lg/collect/deletetool/json ]
  @POST('lg/collect/deletetool/json')
  Future<DataEntity> deleteTool(
    @Query("id") int id, // 工具id
  );

  ///=============================== 七、搜索 ==============================================
  /// 7.1 搜索 [ https://www.wanandroid.com/article/query/0/json ]
  @POST('article/query/{pageNumber}/json')
  Future<DataEntity> query(
    @Path("pageNumber") int pageNumber, // 页码拼接在链接上，从0开始
    @Query("k") String k, // 搜索关键词，支持多个关键词，用空格隔开
    {
    @Query('page_size') int? pageSize, // 取值为[1-40]，不传则使用默认值，一旦传入了 page_size，后续该接口分页都需要带上，否则会造成分页读取错误。
  });

  ///=============================== 八、TO DO 工具 ==============================================
  /// 8.1 搜索 [ https://www.wanandroid.com/article/query/0/json ]
  @POST('article/query/{pageNumber}/json')
  Future<DataEntity> todo(
    @Path("pageNumber") int pageNumber, // 页码拼接在链接上，从0开始
    @Query("k") String k, // 搜索关键词，支持多个关键词，用空格隔开
    {
    @Query('page_size') int? pageSize, // 取值为[1-40]，不传则使用默认值，一旦传入了 page_size，后续该接口分页都需要带上，否则会造成分页读取错误。
  });

  ///=============================== 九、积分 ==============================================
  /// 9.1 积分排行榜 [ https://www.wanandroid.com/coin/rank/1/json ]
  @GET('coin/rank/{pageNumber}/json')
  Future<DataEntity> rankCoin(
    @Path("pageNumber") int pageNumber, // 页码拼接在链接上，从1开始
    {
    @Query('page_size') int? pageSize, // 取值为[1-40]，不传则使用默认值，一旦传入了 page_size，后续该接口分页都需要带上，否则会造成分页读取错误。
  });

  /// 9.2 获取个人积分 [ https://www.wanandroid.com/lg/coin/userinfo/json ]
  @GET('coin/userinfo/json')
  Future<DataEntity> userCoin();

  /// 9.3 获取个人积分获列表 [ https://www.wanandroid.com/lg/coin/list/1/json ]
  @GET('lg/coin/list/{pageNumber}/json')
  Future<DataEntity> coins(
    @Path("pageNumber") int pageNumber, // 页码拼接在链接上，从1开始
    {
    @Query('page_size') int? pageSize, // 取值为[1-40]，不传则使用默认值，一旦传入了 page_size，后续该接口分页都需要带上，否则会造成分页读取错误。
  });

  ///=============================== 十、广场 ==============================================
  /// 10.1 广场列表数据 [ https://wanandroid.com/user_article/list/0/json ]
  @GET('user_article/list/{pageNumber}/json')
  Future<DataEntity> userArticles(
    @Path("pageNumber") int pageNumber, // 页码拼接在链接上，从0开始
    {
    @Query('page_size') int? pageSize, // 取值为[1-40]，不传则使用默认值，一旦传入了 page_size，后续该接口分页都需要带上，否则会造成分页读取错误。
  });

  /// 10.2 分享人对应列表数据 [ https://www.wanandroid.com/user/2/share_articles/1/json ]
  @GET('user/{id}/share_articles/{pageNumber}/json')
  Future<DataEntity> shareArticles(
    @Path("id") int id, // 用户id，拼接在链接中。
    @Path("pageNumber") int pageNumber, // 页码拼接在链接上，从1开始
    {
    @Query('page_size') int? pageSize, // 取值为[1-40]，不传则使用默认值，一旦传入了 page_size，后续该接口分页都需要带上，否则会造成分页读取错误。
  });

  /// 10.3 自己的分享的文章列表 [ https://wanandroid.com/user/lg/private_articles/1/json ]
  @GET('user/lg/private_articles/{pageNumber}/json')
  Future<DataEntity> privateArticles(
    @Path("pageNumber") int pageNumber, // 页码拼接在链接上，从1开始
    {
    @Query('page_size') int? pageSize, // 取值为[1-40]，不传则使用默认值，一旦传入了 page_size，后续该接口分页都需要带上，否则会造成分页读取错误。
  });

  /// 10.4 删除自己分享的文章 [ https://wanandroid.com/lg/user_article/delete/9475/json ]
  @POST('lg/user_article/delete/{id}/json')
  Future<DataEntity> deleteArticle(
    @Path("id") int id, // 文章id，拼接在链接上
  );

  /// 10.5 分享文章 [ https://www.wanandroid.com/lg/user_article/add/json ]
  @POST('lg/user_article/add/json')
  Future<DataEntity> addArticle(
    @Query("title") String title, // 文章标题
    @Query("link") String link, // 文章 url
  );

  ///=============================== 十一、问答 ==============================================
  /// 11.1 问答 [ https://wanandroid.com/wenda/list/1/json ]
  @GET('wenda/list/{pageId}/json')
  Future<DataEntity> questions(
    @Path("pageId") int pageId, // // 页面id，拼接在链接中。
  );

  ///=============================== 十二、个人信息接口 ==============================================
  /// 12.1 个人信息接口 [ https://wanandroid.com//user/lg/userinfo/json ]
  @GET('/user/lg/userinfo/json')
  Future<DataEntity> userinfo();

  ///=============================== 十三、问答评论列表 ==============================================
  /// 13.1 返回问答的评论列表，默认以点赞数倒序排列，当前用户登录则本人评论会置顶 [ https://wanandroid.com/wenda/comments/id/json ]
  @GET('wenda/comments/{id}/json')
  Future<DataEntity> comments(
    @Path("id") int id, // 问答 id，可以通过问答列表获取，拼接在链接上
  );

  ///=============================== 十四、站内消息列表 ==============================================
  /// 14.1 未读消息数量 [ https://wanandroid.com/message/lg/count_unread/json ]
  @GET('message/lg/count_unread/json')
  Future<DataEntity> unreadCount();

  /// 14.2 已读消息列表 [ https://wanandroid.com/message/lg/readed_list/1/json ]
  @GET('message/lg/readed_list/{pageNumber}/json')
  Future<DataEntity> readMessages(
    @Path("pageNumber") int pageNumber, // 页码拼接在链接上，从1开始
    {
    @Query('page_size') int? pageSize, // 取值为[1-40]，不传则使用默认值，一旦传入了 page_size，后续该接口分页都需要带上，否则会造成分页读取错误。
  });

  /// 14.3 未读消息列表 [ https://wanandroid.com/message/lg/unread_list/1/json ]
  @GET('message/lg/unread_list/{pageNumber}/json')
  Future<DataEntity> unreadMessages(
    @Path("pageNumber") int pageNumber, // 页码拼接在链接上，从1开始
    {
    @Query('page_size') int? pageSize, // 取值为[1-40]，不传则使用默认值，一旦传入了 page_size，后续该接口分页都需要带上，否则会造成分页读取错误。
  });

  ///=============================== 十五、公众号Tab ==============================================
  /// 15.1 获取公众号列表 [ https://wanandroid.com/wxarticle/chapters/json ]
  @GET('wxarticle/chapters/json')
  Future<DataEntity> chapters();

  /// 15.2 查看某个公众号历史数据 [ https://wanandroid.com/wxarticle/list/408/1/json ]
  @GET('wxarticle/list/{id}/{pageNumber}/json')
  Future<DataEntity> chapterList(
    @Path("id") int id, // 公众号 id，可以通过问答列表获取，拼接在链接上
    @Path("pageNumber") int pageNumber, // 页码拼接在链接上，从1开始
    {
    @Query('page_size') int? pageSize, // 取值为[1-40]，不传则使用默认值，一旦传入了 page_size，后续该接口分页都需要带上，否则会造成分页读取错误。
  });

  /// 15.3 在某个公众号中搜索历史文章 [ https://wanandroid.com/wxarticle/list/405/1/json?k=Java ]
  @GET('wxarticle/list/{id}/{pageNumber}/json')
  Future<DataEntity> chapterQuery(
    @Path("id") int id, // 公众号 id，可以通过问答列表获取，拼接在链接上
    @Path("pageNumber") int pageNumber, // 页码拼接在链接上，从1开始
    @Query("k") String k, // 搜索关键词
    {
    @Query('page_size') int? pageSize, // 取值为[1-40]，不传则使用默认值，一旦传入了 page_size，后续该接口分页都需要带上，否则会造成分页读取错误。
  });

  ///=============================== 十六、最新项目 Tab ==============================================
  /// 16.1 最新项目tab [ https://wanandroid.com/article/listproject/0/json ]
  @GET('article/listproject/{pageNumber}/json')
  Future<DataEntity> projects(
    @Path("pageNumber") int pageNumber, // 页码拼接在链接上，从1开始
    {
    @Query('page_size') int? pageSize, // 取值为[1-40]，不传则使用默认值，一旦传入了 page_size，后续该接口分页都需要带上，否则会造成分页读取错误。
  });

  ///=============================== 十七、工具列表接口 ==============================================
  /// 17.1 工具列表 [ https://wanandroid.com/tools/list/json ]
  @GET('tools/list/json')
  Future<DataEntity> tools();

  ///=============================== 十八、教程 ==============================================
  /// 18.1 教程列表 [ https://www.wanandroid.com/chapter/547/sublist/json ]
  @GET('chapter/547/sublist/json')
  Future<DataEntity> chapter();

  /// 18.2 单个教程下所有文章列表 [ https://wanandroid.com/article/list/0/json?cid=549 ]
  @GET('article/list/0/json')
  Future<DataEntity> chapterArticle(
    @Query("cid") int cid, // 教程对象 id，可以通过问答列表获取，拼接在链接上
  );

  /// 查询中药详情请求
  @GET('zhongyao/index')
  Future<DataEntity> getZhongYao(
    @Query('key') String key,
    @Query('word') String word,
  );
}
