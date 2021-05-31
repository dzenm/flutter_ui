import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/http/api_client.dart';
import 'package:flutter_ui/models/article_bean.dart';
import 'package:flutter_ui/widgets/loading_view.dart';
import 'package:flutter_ui/widgets/refresh_list_view.dart';

class ListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<ArticleBean?> articleList = [];
  int _page = 1; // 加载的页数
  LoadingState loadingState = LoadingState.none;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _getArticle(_page, isReset: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('列表和刷新')),
      body: RefreshListView(list: articleList, refresh: _onRefresh, builder: _renderArticleItem),
    );
  }

  Widget _renderArticleItem(BuildContext context, int index) {
    if (index < articleList.length) {
      return ListTile(
        title: Text(articleList[index]?.title ?? ''),
      );
    }
    return LoadingFooterView(loadingState: loadingState);
  }

  // 下拉刷新方法,为list重新赋值
  Future<void> _onRefresh(bool refresh) async => _getArticle(_page, isReset: refresh);

  // 根据页数获取文章
  void _getArticle(int num, {bool isReset = false}) async {
    _page = isReset ? 0 : _page;
    if (isLoading) return;
    setState(() => loadingState = LoadingState.loading);
    isLoading = true;
    ApiClient.instance.request(apiServices.article(num.toString()), success: (data) {
      List<ArticleBean?> list = (data['datas'] as List<dynamic>).map((e) => ArticleBean.fromJson(e)).toList();
      setState(() {
        if (_page == 3) {
          loadingState = LoadingState.complete;
          return;
        }
        if (isReset) {
          articleList = list;
        } else {
          articleList.addAll(list);
        }
        ++_page;
        isLoading = false;
        loadingState = LoadingState.loading;
      });
    });
  }
}
