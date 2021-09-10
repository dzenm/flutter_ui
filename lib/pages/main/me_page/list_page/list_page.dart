import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/entities/page_entity.dart';
import 'package:flutter_ui/base/http/api_client.dart';
import 'package:flutter_ui/base/res/strings.dart';
import 'package:flutter_ui/base/router/route_manager.dart';
import 'package:flutter_ui/base/widgets/refresh_list_view.dart';
import 'package:flutter_ui/base/widgets/state_view.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';
import 'package:flutter_ui/entities/article_entity.dart';
import 'package:flutter_ui/pages/common/web_view_page.dart';

class ListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<ArticleEntity?> articleList = [];
  int _page = 0; // 加载的页数
  StateController _controller = StateController();

  @override
  void initState() {
    super.initState();
    _getArticle(isReset: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of.listAndRefresh, style: TextStyle(color: Colors.white)),
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
                controller: _controller,
                itemCount: articleList.length,
                builder: _renderArticleItem,
                refresh: _onRefresh,
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
      onTap: () => RouteManager.push(WebViewPage(title: title, url: article.link ?? '')),
      child: ListTile(
        title: Text(title),
      ),
    );
  }

  // 下拉刷新方法,为list重新赋值
  Future<void> _onRefresh(bool refresh) async => _getArticle(isReset: refresh);

  // 根据页数获取文章
  void _getArticle({bool isReset = false}) {
    Future.delayed(Duration(milliseconds: isReset ? 500 : 0), () {
      _page = isReset ? 0 : _page;
      ApiClient.getInstance.request(
        apiServices.article(_page.toString()),
        isShowDialog: false,
        success: (data) {
          PageEntity pageEntity = PageEntity.fromJson(data);
          List<ArticleEntity?> list = (data['datas'] as List<dynamic>).map((e) => ArticleEntity.fromJson(e)).toList();
          setState(() {
            _controller.loadComplete();
            if (_page == pageEntity.total) {
              _controller.loadEmpty();
            } else {
              isReset ? articleList = list : articleList.addAll(list);
              ++_page;
              _controller.loadMore();
            }
          });
        },
        failed: (e) => setState(() => _controller.loadFailed()),
      );
    });
  }
}
