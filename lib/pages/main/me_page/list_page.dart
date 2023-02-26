import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui/base/entities/page_entity.dart';
import 'package:flutter_ui/base/widgets/refresh_list_view.dart';
import 'package:flutter_ui/base/widgets/state_view.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';
import 'package:flutter_ui/entities/article_entity.dart';
import 'package:flutter_ui/http/http_manager.dart';

///
/// Created by a0010 on 2023/2/23 13:35
/// 我分享的文章页面
class ListPage extends StatefulWidget {
  ListPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  StateController _controller = StateController();
  int _page = 1; // 加载的页数
  List<ArticleEntity> _list = []; // 加载的数据

  @override
  void initState() {
    super.initState();

    _getArticles(isReset: true); // 第一次加载数据
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('分享的文章列表', style: TextStyle(color: Colors.white)),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Container(
        child: Column(children: [
          Expanded(
            child: RefreshListView(
              controller: _controller,
              itemCount: _list.length,
              builder: (BuildContext context, int index) {
                return _buildCollectItem(_list[index], index);
              },
              refresh: _onRefresh,
              showFooter: true,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildCollectItem(ArticleEntity article, int index) {
    String title = article.title ?? '';
    return TapLayout(
      child: ListTile(
        title: Text(title),
      ),
    );
  }

  // 下拉刷新方法,为list重新赋值
  Future<void> _onRefresh(bool refresh) async => _getArticles(isReset: refresh);

  // 根据页数获取收藏
  void _getArticles({bool isReset = false}) {
    if (isReset) {
      _list.clear();
    }
    Future.delayed(Duration(milliseconds: isReset ? 500 : 0), () {
      _page = isReset ? 1 : _page;
      HttpManager.instance.getPrivateArticleList(
        page: _page,
        isShowDialog: false,
        success: (data) {
          PageEntity page = PageEntity.fromJson(data['shareArticles']);
          List<dynamic> datas = (page.datas ?? []);
          List<ArticleEntity> list = datas.map((e) => ArticleEntity.fromJson(e)).toList();

          _controller.loadComplete(); // 加载成功
          if (_page >= (page.pageCount ?? 0)) {
            _controller.loadEmpty(); // 加载完所有页面
          } else {
            // 加载数据成功，保存数据，下次加载下一页
            _list.addAll(list);
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
