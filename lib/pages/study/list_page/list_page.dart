import 'package:flutter/material.dart';

import '../../../base/route/app_route_delegate.dart';
import '../../../base/widgets/refresh_list_view.dart';
import '../../../base/widgets/state_view.dart';
import '../../../base/widgets/tap_layout.dart';
import '../../../entities/article_entity.dart';
import '../../../http/http_manager.dart';
import '../../routers.dart';

/// 刷新和底部加载的列表
class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<StatefulWidget> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final StateController _controller = StateController();
  final List<ArticleEntity> _articles = [];
  int _page = 0; // 加载的页数

  @override
  void initState() {
    super.initState();
    _getArticle(isReset: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('列表和刷新', style: TextStyle(color: Colors.white)),
      ),
      body: Column(children: [
        Expanded(
          child: RefreshListView(
            controller: _controller,
            itemCount: _articles.length,
            builder: (BuildContext context, int index) {
              return _buildArticleItem(_articles[index], index);
            },
            refresh: _onRefresh,
            showFooter: true,
          ),
        )
      ]),
    );
  }

  Widget _buildArticleItem(ArticleEntity article, int index) {
    String title = article.title ?? '';
    return TapLayout(
      onTap: () {
        String params = '?title=$title&url=${article.link}';
        AppRouteDelegate.of(context).push(Routers.webView + params);
      },
      child: ListTile(
        title: Text(title),
      ),
    );
  }

  // 下拉刷新方法,为list重新赋值
  Future<void> _onRefresh(bool refresh) async => await _getArticle(isReset: refresh);

  // 根据页数获取文章
  Future<void> _getArticle({bool isReset = false}) async {
    await Future.delayed(Duration(milliseconds: isReset ? 500 : 0));
    if (isReset) {
      _page = 0;
      _articles.clear();
    }
    await HttpManager.instance.getArticles(
      page: _page,
      isShowDialog: false,
      success: (list, pageCount) {
        _controller.loadComplete(); // 加载成功
        if (_page >= (pageCount ?? 0)) {
          _controller.loadEmpty(); // 加载完所有页面
        } else {
          // 加载数据成功，下次加载下一页
          _articles.addAll(list);
          ++_page;
          _controller.loadMore();
        }
        setState(() {});
      },
      failed: (error) => setState(() => _controller.loadFailed()),
    );
  }
}
