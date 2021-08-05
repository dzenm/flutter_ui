import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/entities/page_entity.dart';
import 'package:flutter_ui/base/http/api_client.dart';
import 'package:flutter_ui/base/router/navigator_manager.dart';
import 'package:flutter_ui/base/widgets/loading_view.dart';
import 'package:flutter_ui/base/widgets/refresh_list_view.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';
import 'package:flutter_ui/entities/article_entity.dart';
import 'package:flutter_ui/pages/main/main_route.dart';

class ListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<ArticleEntity?> articleList = [];
  int _page = 0; // 加载的页数
  LoadingState _loadingState = LoadingState.loading;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      _loadingState = LoadingState.none;
      _getArticle(isReset: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('列表和刷新', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: RefreshListView(
                isInit: _isInit,
                loadingState: _loadingState,
                itemCount: articleList.length,
                builder: _renderArticleItem,
                refresh: _onRefresh,
                isShowFooterLoading: true,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _renderArticleItem(BuildContext context, int index) {
    ArticleEntity article = articleList[index] ?? ArticleEntity();
    String title = article.title ?? '';
    return TapLayout(
      onTap: () => NavigatorManager.navigateTo(
        context,
        MainRoute.webView + '?title=${Uri.encodeComponent(title)}&url=${Uri.encodeComponent(article.link ?? '')}',
      ),
      child: ListTile(
        title: Text(title),
      ),
    );
  }

  // 下拉刷新方法,为list重新赋值
  Future<void> _onRefresh(bool refresh) async => _getArticle(isReset: refresh);

  // 根据页数获取文章
  void _getArticle({bool isReset = false}) {
    if (_loadingState == LoadingState.loading) return;
    setState(() => _loadingState = LoadingState.loading);

    _page = isReset ? 0 : _page;
    ApiClient.getInstance.request(
      apiServices.article(_page.toString()),
      isShowDialog: false,
      success: (data) {
        PageEntity pageEntity = PageEntity.fromJson(data);
        List<ArticleEntity?> list = (data['datas'] as List<dynamic>).map((e) => ArticleEntity.fromJson(e)).toList();
        setState(() {
          if (_page == pageEntity.total) {
            _loadingState = LoadingState.end;
            return;
          } else {
            isReset ? articleList = list : articleList.addAll(list);
            ++_page;
            _loadingState = LoadingState.more;
          }
          if (!_isInit) _isInit = true;
        });
      },
      failed: (e) => setState(() => _loadingState = LoadingState.error),
    );
  }
}
