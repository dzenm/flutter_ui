import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui/base/http/https_client.dart';
import 'package:flutter_ui/pages/routers.dart';
import 'package:provider/provider.dart';

import '../../../base/log/build_config.dart';
import '../../../base/log/log.dart';
import '../../../base/res/app_theme.dart';
import '../../../base/res/assets.dart';
import '../../../base/res/custom_icon.dart';
import '../../../base/res/local_model.dart';
import '../../../base/route/app_route_delegate.dart';
import '../../../base/utils/str_util.dart';
import '../../../base/widgets/banner_view.dart';
import '../../../base/widgets/common_bar.dart';
import '../../../base/widgets/common_dialog.dart';
import '../../../base/widgets/refresh_list_view.dart';
import '../../../base/widgets/state_view.dart';
import '../../../base/widgets/tap_layout.dart';
import '../../../entities/article_entity.dart';
import '../../../entities/banner_entity.dart';
import '../../../http/http_manager.dart';
import '../../../models/article_model.dart';
import '../../../models/banner_model.dart';
import '../../../models/website_model.dart';

///
/// Created by a0010 on 2022/7/28 10:56
/// 主页面
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String _tag = 'HomePage';
  StateController _controller = StateController();
  int _page = 0; // 加载的页数
  bool _init = false;

  @override
  void initState() {
    super.initState();
    log('initState');

    _getData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    log('didChangeDependencies');
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    log('didUpdateWidget');
  }

  @override
  void deactivate() {
    super.deactivate();
    log('deactivate');
  }

  @override
  void dispose() {
    super.dispose();
    log('dispose');
  }

  @override
  Widget build(BuildContext context) {
    log('build');
    AppTheme theme = context.watch<LocalModel>().theme;
    return Scaffold(
      appBar: CommonBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
        ),
        toolbarHeight: 0,
        backgroundColor: theme.transparent,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_init) {
      return Container();
    }
    return Container(
      child: Column(
        children: [
          Banner(),
          Expanded(
            child: ArticleListView(controller: _controller, refresh: _onRefresh),
          ),
        ],
      ),
    );
  }

  Future<void> _onRefresh(bool refresh) async => await _getArticle(isReset: refresh);

  Future<void> _getData() async {
    log('开始加载网络数据...');
    await Future.wait([
      _getBanner(),
      _getArticle(isReset: true),
      _getTopArticle(),
      _getDataList(),
    ]).then((value) {
      log('网络数据执行完成...');
    }).whenComplete(() {
      _init = true;
    });
    log('结束加载网络数据...');
  }

  Future<void> _getBanner() async {
    await HttpManager.instance.banner(
      isShowDialog: false,
      success: (list) {
        context.read<BannerModel>().banners = list;
      },
    );
  }

  Future<void> _getTopArticle() async {
    await HttpManager.instance.getLopArticleList(
      isShowDialog: false,
      success: (list) {
        context.read<ArticleModel>().updateArticles(list);
      },
    );
  }

  Future<void> _getArticle({bool isReset = false}) async {
    _page = isReset ? 0 : _page;
    await HttpManager.instance.getArticleList(
      page: _page,
      isShowDialog: false,
      success: (list, pageCount) {
        _controller.loadComplete(); // 加载成功
        if (_page >= (pageCount ?? 0)) {
          _controller.loadEmpty(); // 加载完所有页面
        } else {
          // 加载数据成功，保存数据，下次加载下一页
          context.read<ArticleModel>().updateArticles(list);
          ++_page;
          _controller.loadMore();
        }
        setState(() {});
      },
    );
  }

  Future<void> _getDataList() async {
    if (_init) return;
    if (!_init) return;
    await HttpManager.instance.getWebsiteList(
      isShowDialog: false,
      success: (list) {
        context.read<WebsiteModel>().updateWebsites(list);
      },
    );
    await HttpManager.instance.getHotkeyList(
      isShowDialog: false,
      success: (list) {
        // context.read<WebsiteModel>().updateWebsites(list);
      },
    );
    await HttpManager.instance.getTreeList(
      isShowDialog: false,
      success: (list) {
        // context.read<TreeEntity>().updateWebsites(list);
      },
    );
    await HttpManager.instance.getNaviList(
      isShowDialog: false,
      success: (list) {
        // context.read<TreeEntity>().updateWebsites(list);
      },
    );
    await HttpManager.instance.getProjectList(
      isShowDialog: false,
      success: (list) {
        // context.read<TreeEntity>().updateWebsites(list);
      },
    );
  }

  void log(String msg) => BuildConfig.showPageLog ? Log.p(msg, tag: _tag) : null;
}

/// 文章列表 widget
class ArticleListView extends StatelessWidget {
  static const String _tag = 'ArticleListView';

  final StateController controller;
  final RefreshFunction refresh;

  ArticleListView({
    Key? key,
    required this.controller,
    required this.refresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<ArticleModel, int>(
      builder: (context, value, child) {
        Log.p('build', tag: _tag);
        return RefreshListView(
          controller: controller,
          itemCount: value,
          builder: (context, index) {
            return ArticleItemView(index);
          },
          refresh: refresh,
          showFooter: true,
        );
      },
      selector: (context, model) => model.allArticles.length,
    );
  }
}

/// 文章列表 item widget
class ArticleItemView extends StatelessWidget {
  static const String _tag = 'ArticleItemView';
  final int index;

  ArticleItemView(this.index, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Log.p('build', tag: _tag);

    AppTheme theme = context.watch<LocalModel>().theme;

    return TapLayout(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      background: theme.background,
      margin: EdgeInsets.only(top: 12, left: 8, right: 8),
      padding: EdgeInsets.all(12),
      onTap: () {
        ArticleEntity? article = context.read<ArticleModel>().getArticle(index);
        if (article == null) return;
        String params = '?title=${article.title}&url=${article.link}';
        AppRouteDelegate.of(context).push(Routers.webView + params);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // 置顶标识图标
            Selector<ArticleModel, bool>(
              builder: (context, value, child) {
                return Offstage(
                  offstage: !value,
                  child: Image(image: AssetImage(Assets.image('ic_top.png')), width: 24, height: 24),
                );
              },
              selector: (context, model) => model.getArticle(index)?.type == 1,
            ),
            // 文章标题
            Expanded(
              child: Selector<ArticleModel, String>(
                builder: (context, value, child) {
                  return Text(
                    value,
                    style: TextStyle(fontSize: 18, color: theme.primaryText),
                  );
                },
                selector: (context, model) => model.getArticle(index)?.title ?? '',
              ),
            ),
          ]),
          Row(children: [
            // 文章所属标签
            Selector<ArticleModel, List<TagEntity>>(
              builder: (context, value, child) {
                return Row(
                  children: value.map(
                    (val) {
                      return TapLayout(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          val.name ?? '',
                          style: TextStyle(fontSize: 12, color: theme.blue),
                        ),
                        onTap: () {
                          /// 处理url
                          String path = val.url ?? '';
                          int start = path.indexOf('/');
                          String url = HttpsClient().baseUrls[0] + path.substring(start);
                          String params = '?title=${val.name}&url=$url';
                          AppRouteDelegate.of(context).push(Routers.webView + params);
                        },
                      );
                    },
                  ).toList(),
                );
              },
              selector: (context, model) => model.getArticle(index)?.tags ?? [],
            ),
          ]),
          Row(children: [
            // 文章描述信息
            Expanded(
              child: Selector<ArticleModel, String>(
                builder: (context, value, child) {
                  return Offstage(
                    offstage: value.isEmpty,
                    child: Text(
                      value,
                      style: TextStyle(color: theme.secondaryText),
                    ),
                  );
                },
                selector: (context, model) => model.getArticle(index)?.desc ?? '',
              ),
            ),
          ]),
          Row(children: [
            // 点赞人数
            Selector<ArticleModel, int>(
              builder: (context, value, child) {
                if (value == 0) return Container();
                return Row(children: [
                  Icon(CustomIcon.thumbs_up, color: theme.blue, size: 16),
                  SizedBox(width: 4),
                  Text(
                    '$value',
                    style: TextStyle(color: theme.blue),
                  ),
                  SizedBox(width: 8),
                ]);
              },
              selector: (context, model) => model.getArticle(index)?.zan ?? 0,
            ),
            // 文章所属的名称
            Expanded(
              child: Selector<ArticleModel, String>(
                builder: (context, value, child) {
                  return Text(value);
                },
                selector: (context, model) => model.getArticle(index)?.chapterName ?? '',
              ),
            ),
            // 文章分享的日期
            Selector<ArticleModel, int>(
              builder: (context, value, child) {
                return Text(
                  StrUtil.todayBefore(DateTime.fromMillisecondsSinceEpoch(value), showTime: true),
                );
              },
              selector: (context, model) => model.getArticle(index)?.shareDate ?? 0,
            ),
            SizedBox(width: 8),
            // 文章收藏的状态
            Selector<ArticleModel, bool>(
              builder: (context, value, child) {
                IconData icon = value ? CustomIcon.heart : CustomIcon.heart_empty;
                Color? color = value ? theme.red : theme.hint;
                return TapLayout(
                  height: 48,
                  width: 48,
                  foreground: theme.transparent,
                  onTap: () {
                    ArticleEntity? article = context.read<ArticleModel>().getArticle(index);
                    if (article == null) return;
                    HttpManager.instance.collect(article.id ?? 0, collect: !value, isShowDialog: false, success: () {
                      article.collect = !value;
                      context.read<ArticleModel>().updateArticle(article);
                    });
                  },
                  child: Icon(icon, color: color),
                );
              },
              selector: (context, model) => model.getArticle(index)?.collect ?? false,
            ),
          ]),
        ],
      ),
    );
  }
}

/// 轮播图 widget
class Banner extends StatelessWidget {
  static const String _tag = 'Banner';

  @override
  Widget build(BuildContext context) {
    Log.p('build', tag: _tag);

    return Selector<BannerModel, List<BannerEntity>>(
      builder: (context, value, widget) {
        return BannerView(
          repeat: true,
          builder: (imagePath) => Image.network(imagePath ?? '', fit: BoxFit.cover),
          data: value.map((banner) => BannerData(title: banner.title, data: banner.imagePath)).toList(),
          onTap: (index) {
            CommonDialog.showToast(index.toString());
          },
        );
      },
      selector: (context, model) => model.banners,
    );
  }
}
