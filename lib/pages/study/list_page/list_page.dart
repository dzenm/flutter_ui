import 'package:flutter/material.dart';
import 'package:flutter_ui/base/router/route_manager.dart';
import 'package:flutter_ui/base/widgets/refresh_list_view.dart';
import 'package:flutter_ui/base/widgets/state_view.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';
import 'package:flutter_ui/entities/article_entity.dart';
import 'package:flutter_ui/http/http_manager.dart';
import 'package:flutter_ui/models/article_model.dart';
import 'package:flutter_ui/pages/common/web_view_page.dart';
import 'package:provider/provider.dart';

/// 刷新和底部加载的列表
class ListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  StateController _controller = StateController();
  int _page = 0; // 加载的页数

  @override
  void initState() {
    super.initState();
    _getArticle(isReset: true);
  }

  @override
  Widget build(BuildContext context) {
    List<ArticleEntity> articleList = context.watch<ArticleModel>().allArticles;
    return Scaffold(
      appBar: AppBar(
        title: Text('列表和刷新', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        child: Column(children: [
          Expanded(
            child: RefreshListView(
              controller: _controller,
              itemCount: articleList.length,
              builder: (BuildContext context, int index) {
                return _buildArticleItem(articleList[index], index);
              },
              refresh: _onRefresh,
            ),
          )
        ]),
      ),
    );
  }

  Widget _buildArticleItem(ArticleEntity article, int index) {
    String title = article.title ?? '';
    return TapLayout(
      onTap: () => RouteManager.push(context, WebViewPage(title: title, url: article.link ?? '')),
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
      HttpManager.instance.getArticleList(
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
        failed: (error) => setState(() => _controller.loadFailed()),
      );
    });
  }
}
