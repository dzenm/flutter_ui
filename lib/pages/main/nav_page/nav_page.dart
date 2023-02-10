import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/base/router/route_manager.dart';
import 'package:flutter_ui/base/widgets/refresh_list_view.dart';
import 'package:flutter_ui/base/widgets/state_view.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';
import 'package:flutter_ui/entities/article_entity.dart';
import 'package:flutter_ui/models/article_model.dart';
import 'package:flutter_ui/pages/common/web_view_page.dart';
import 'package:provider/provider.dart';

// 分类页面
class NavPage extends StatefulWidget {
  final String title;

  NavPage({required this.title});

  @override
  _NavPageState createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> with AutomaticKeepAliveClientMixin {
  static const String _tag = 'NavPage';
  StateController _controller = StateController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Log.i('initState', tag: _tag);

    Future.delayed(Duration.zero, () => setState(() => _controller.loadComplete()));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Log.i('didChangeDependencies', tag: _tag);
  }

  @override
  void didUpdateWidget(covariant NavPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    Log.i('didUpdateWidget', tag: _tag);
  }

  @override
  void deactivate() {
    super.deactivate();
    Log.i('deactivate', tag: _tag);
  }

  @override
  void dispose() {
    super.dispose();
    Log.i('dispose', tag: _tag);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Log.i('build', tag: _tag);

    List<ArticleEntity> articleList = context.watch<ArticleModel>().articles;
    Log.i('文章数量：${articleList.length}', tag: _tag);
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
        ),
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
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
                builder: (BuildContext context, int index) {
                  return _buildArticleItem(articleList, index);
                },
                refresh: (state) async {},
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildArticleItem(List<ArticleEntity> articleList, int index) {
    ArticleEntity article = articleList[index];
    String title = article.title ?? '';
    return TapLayout(
      onTap: () => RouteManager.push(context, WebViewPage(title: title, url: article.link ?? '')),
      child: ListTile(
        title: Text(title),
      ),
    );
  }
}
