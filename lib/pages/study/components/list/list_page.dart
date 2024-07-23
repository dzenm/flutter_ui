import 'package:flutter/material.dart';
import 'package:flutter_ui/base/a_router/misc/extensions.dart';

import '../../../../base/base.dart';
import '../../../../entities/entity.dart';
import '../../../../http/http_manager.dart';
import '../../../routers.dart';

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonBar(
        title: '列表和刷新',
      ),
      body: Column(children: [
        Expanded(
          child: Shimmer(
            child: RefreshListView(
              controller: _controller,
              itemCount: _articles.length,
              physics: _isLoading ? const NeverScrollableScrollPhysics() : null,
              builder: (BuildContext context, int index) {
                return _buildArticleItem(_articles[index], index);
              },
              refresh: _onRefresh,
              showFooter: true,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildArticleItem(ArticleEntity article, int index) {
    String title = article.title ?? '';
    return ShimmerLoading(
        isLoading: _isLoading,
        child: TapLayout(
          onTap: () {
            context.pushNamed(
              Routers.webView,
              queryParameters: {
                'title': title,
                'url': article.link ?? '',
              },
            );
          },
          child: ListTile(
            title: ShimmerText(
              isLoading: _isLoading,
              child: Text(title),
            ),
          ),
        ));
  }

  // 下拉刷新方法,为list重新赋值
  Future<void> _onRefresh(bool refresh) async {
    _pageIndex = (refresh ? 0 : _pageIndex);
    await _getData();
  }

  // 根据页数获取文章
  Future<void> _getData() async {
    bool reset = _pageIndex == 0;
    await Future.delayed(Duration(milliseconds: reset ? 500 : 0));
    await HttpManager().getArticles(
      page: _pageIndex,
      isShowDialog: false,
      success: (list, pageCount) {
        if (reset) {
          _articles.clear();
        }
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
      failed: (error) async => setState(() => _controller.loadFailed()),
    );
    Future.delayed(const Duration(seconds: 5), () => setState(() => _isLoading = !_isLoading));
  }
}
