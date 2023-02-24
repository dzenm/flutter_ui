import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui/base/router/route_manager.dart';
import 'package:flutter_ui/base/widgets/refresh_list_view.dart';
import 'package:flutter_ui/base/widgets/state_view.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';
import 'package:flutter_ui/entities/collect_entity.dart';
import 'package:flutter_ui/http/http_manager.dart';
import 'package:flutter_ui/pages/common/web_view_page.dart';

///
/// Created by a0010 on 2023/2/23 13:35
/// 我的收藏页面
class CollectPage extends StatefulWidget {
  CollectPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CollectPageState();
}

class _CollectPageState extends State<CollectPage> {
  StateController _controller = StateController();
  int _page = 0; // 加载的页数
  List<CollectEntity> _list = []; // 加载的数据

  @override
  void initState() {
    super.initState();

    _getArticle(isReset: true); // 第一次加载数据
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('收藏列表', style: TextStyle(color: Colors.white)),
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
            ),
          )
        ]),
      ),
    );
  }

  Widget _buildCollectItem(CollectEntity collect, int index) {
    String title = collect.title ?? '';
    return TapLayout(
      onTap: () => RouteManager.push(context, WebViewPage(title: title, url: collect.link ?? '')),
      child: ListTile(
        title: Text(title),
      ),
    );
  }

  // 下拉刷新方法,为list重新赋值
  Future<void> _onRefresh(bool refresh) async => _getArticle(isReset: refresh);

  // 根据页数获取文章
  void _getArticle({bool isReset = false}) {
    if (isReset) {
      _list.clear();
    }
    Future.delayed(Duration(milliseconds: isReset ? 500 : 0), () {
      _page = isReset ? 0 : _page;
      HttpManager.instance.getCollectArticleList(
        page: _page,
        isShowDialog: false,
        success: (list, pageCount) {
          _controller.loadComplete(); // 加载成功
          if (_page == pageCount) {
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
