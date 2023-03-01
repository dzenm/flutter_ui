import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/base/router/route_manager.dart';
import 'package:flutter_ui/base/widgets/banner_view.dart';
import 'package:flutter_ui/base/widgets/common_dialog.dart';
import 'package:flutter_ui/base/widgets/refresh_list_view.dart';
import 'package:flutter_ui/base/widgets/state_view.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';
import 'package:flutter_ui/entities/article_entity.dart';
import 'package:flutter_ui/entities/banner_entity.dart';
import 'package:flutter_ui/http/http_manager.dart';
import 'package:flutter_ui/models/article_model.dart';
import 'package:flutter_ui/models/banner_model.dart';
import 'package:flutter_ui/models/webite_model.dart';
import 'package:flutter_ui/pages/common/web_view_page.dart';
import 'package:provider/provider.dart';

// 主页面
class HomePage extends StatefulWidget {
  final String title;

  HomePage({required this.title});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String _tag = 'HomePage';
  StateController _controller = StateController();
  int _page = 0; // 加载的页数

  @override
  void initState() {
    super.initState();
    Log.i('initState', tag: _tag);

    _getData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Log.i('didChangeDependencies', tag: _tag);
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    Log.i('didUpdateWidget', tag: _tag);
  }

  @override
  void deactivate() {
    super.deactivate();
    Log.i('deactivate', tag: _tag);
  }

  @override
  void dispose() {
    super.dispose();
    Log.i('dispose', tag: _tag);
  }

  @override
  Widget build(BuildContext context) {
    Log.i('build', tag: _tag);

    return Scaffold(
      appBar: AppBar(
        // title: Text(widget.title, style: TextStyle(color: Colors.white)),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Container(
        child: Column(
          children: [
            Banner(),
            ArticleListView(
              controller: _controller,
              refresh: _onRefresh,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onRefresh(bool refresh) async => await _getArticle(isReset: refresh);

  Future<void> _getData() async {
    Log.d('开始加载网络数据...', tag: _tag);
    CancelFunc cancel = CommonDialog.loading();
    await Future.wait([
      _getBanner(),
      _getArticle(isReset: true),
      _getTopArticle(),
      // _getDataList(),
    ]).then((value) {
      Log.d('网络数据执行完成...', tag: _tag);
    }).whenComplete(() => cancel());
    Log.d('结束加载网络数据...', tag: _tag);
  }

  Future<void> _getBanner() async {
    await HttpManager.instance.banner(
        isShowDialog: false,
        success: (list) {
          context.read<BannerModel>().updateBanners(list);
        });
  }

  Future<void> _getTopArticle() async {
    await HttpManager.instance.getLopArticleList(
        isShowDialog: false,
        success: (list) {
          context.read<ArticleModel>().updateArticles(list);
        });
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
        });
  }

  Future<void> _getDataList() async {
    await HttpManager.instance.getWebsiteList(
        isShowDialog: false,
        success: (list) {
          context.read<WebsiteModel>().updateWebsites(list);
        });
    await HttpManager.instance.getHotkeyList(
        isShowDialog: false,
        success: (list) {
          // context.read<WebsiteModel>().updateWebsites(list);
        });
    await HttpManager.instance.getTreeList(
        isShowDialog: false,
        success: (list) {
          // context.read<TreeEntity>().updateWebsites(list);
        });
    await HttpManager.instance.getNaviList(
        isShowDialog: false,
        success: (list) {
          // context.read<TreeEntity>().updateWebsites(list);
        });
    await HttpManager.instance.getProjectList(
        isShowDialog: false,
        success: (list) {
          // context.read<TreeEntity>().updateWebsites(list);
        });
  }
}

/// 文章列表 widget
class ArticleListView extends StatefulWidget {
  final StateController controller;
  final RefreshFunction refresh;

  ArticleListView({
    Key? key,
    required this.controller,
    required this.refresh,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ArticleListViewState();
}

class _ArticleListViewState extends State<ArticleListView> {
  static const String _tag = 'ArticleList';

  @override
  Widget build(BuildContext context) {
    Log.i('build', tag: _tag);

    List<ArticleEntity> articleList = context.watch<ArticleModel>().allArticles;
    Log.i('文章数量：${articleList.length}', tag: _tag);
    return Expanded(
      child: RefreshListView(
        controller: widget.controller,
        itemCount: articleList.length,
        builder: (BuildContext context, int index) {
          return ArticleItemView(index);
        },
        refresh: widget.refresh,
        showFooter: true,
      ),
    );
  }
}

/// 文章列表 item widget
class ArticleItemView extends StatelessWidget {
  static const String _tag = 'ArticleItem';
  final int index;

  ArticleItemView(this.index, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Log.i('build', tag: _tag);

    ArticleEntity? article = context.watch<ArticleModel>().getArticle(index);
    if (article == null) return Container();
    String title = article.title ?? '';
    bool showTop = article.type == 1;
    String author = article.author ?? '';
    String chapterName = article.chapterName ?? '';
    String updateTime = article.niceShareDate ?? '';
    bool fresh = article.fresh ?? false;
    return TapLayout(
      padding: EdgeInsets.all(16),
      onTap: () => RouteManager.push(context, WebViewPage(title: title, url: article.link ?? '')),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Offstage(
              offstage: !showTop,
              child: Text('顶', style: TextStyle(color: Colors.red, fontSize: 12)),
            ),
            SizedBox(width: 8),
            Text(author),
            SizedBox(width: 8),
            Text(chapterName),
            SizedBox(width: 8),
            Text(updateTime),
            SizedBox(width: 8),
            TapLayout(
              onTap: () {
                HttpManager.instance.collect(article.id ?? 0, fresh: !fresh, isShowDialog: false, success: () {
                  article.fresh = !fresh;
                  context.read<ArticleModel>().updateArticle(article);
                });
              },
              child: Text(fresh ? '已收藏' : '未收藏'),
            )
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
    Log.i('build', tag: _tag);

    List<BannerEntity> banners = context.watch<BannerModel>().banners;
    return BannerView(
      builder: (src) => Image.network(src ?? '', fit: BoxFit.cover),
      data: banners.map((banner) => BannerData(title: banner.title, data: banner.imagePath)).toList(),
      onTap: (index) {
        CommonDialog.showToast(index.toString());
      },
    );
  }
}
