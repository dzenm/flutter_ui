import 'package:flutter/material.dart';

import '../../../base/base.dart';
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
  int _pageIndex = 0; // 加载的页数

  @override
  void initState() {
    super.initState();
    _getData();
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
  Future<void> _onRefresh(bool refresh) async {
    _pageIndex = (refresh ? 0 : _pageIndex);
    await _getData();
  }

  // 根据页数获取文章
  Future<void> _getData() async {
    bool reset = _pageIndex == 0;
    if (reset) {
      _articles.clear();
    }
    await Future.delayed(Duration(milliseconds: reset ? 500 : 0));
    await HttpManager().getArticles(
      page: _pageIndex,
      isShowDialog: false,
      success: (list, pageCount) {
        _controller.loadComplete(); // 加载成功
        if (_pageIndex >= (pageCount ?? 0)) {
          _controller.loadEmpty(); // 加载完所有页面
        } else {
          // 加载数据成功，下次加载下一页
          _articles.addAll(list);
          ++_pageIndex;
          _controller.loadMore();
        }
        setState(() {});
      },
      failed: (error) => setState(() => _controller.loadFailed()),
    );
  }
}
