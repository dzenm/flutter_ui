import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/http/api_client.dart';
import 'package:flutter_ui/base/widgets/loading_view.dart';
import 'package:flutter_ui/base/widgets/refresh_list_view.dart';
import 'package:flutter_ui/entities/article_entity.dart';
import 'package:flutter_ui/entities/page_entity.dart';

class ListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<ArticleEntity?> articleList = [];
  int _page = 0; // 加载的页数
  LoadingState loadingState = LoadingState.loading;
  bool isInit = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      loadingState = LoadingState.none;
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
              child: isInit
                  ? RefreshListView(list: articleList, refresh: _onRefresh, builder: _renderArticleItem)
                  : LoadingView(loadingState: loadingState, onTap: () => _getArticle()),
            )
          ],
        ),
      ),
    );
  }

  Widget _renderArticleItem(BuildContext context, int index) {
    if (index < articleList.length) {
      return ListTile(
        title: Text(articleList[index]?.title ?? ''),
      );
    }
    return LoadingView(loadingState: loadingState, vertical: false, onTap: () => _getArticle());
  }

  // 下拉刷新方法,为list重新赋值
  Future<void> _onRefresh(bool refresh) async => _getArticle(isReset: refresh);

  // 根据页数获取文章
  void _getArticle({bool isReset = false}) async {
    if (loadingState == LoadingState.loading) return;
    setState(() => loadingState = LoadingState.loading);

    _page = isReset ? 0 : _page;
    ApiClient.getInstance.request(
      apiServices.article(_page.toString()),
      isShowDialog: false,
      success: (data) {
        PageEntity pageBean = PageEntity.fromJson(data);
        List<ArticleEntity?> list = (data['datas'] as List<dynamic>).map((e) => ArticleEntity.fromJson(e)).toList();
        setState(() {
          if (_page == pageBean.total) {
            loadingState = LoadingState.complete;
            return;
          } else {
            isReset ? articleList = list : articleList.addAll(list);
            ++_page;
            loadingState = LoadingState.more;
          }
          if (!isInit) isInit = true;
        });
      },
      failed: (e) => setState(() => loadingState = LoadingState.error),
    );
  }
}
