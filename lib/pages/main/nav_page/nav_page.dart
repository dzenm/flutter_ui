import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/base/model/local_model.dart';
import 'package:flutter_ui/base/res/theme/app_theme.dart';
import 'package:flutter_ui/base/router/route_manager.dart';
import 'package:flutter_ui/base/widgets/refresh_list_view.dart';
import 'package:flutter_ui/base/widgets/state_view.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';
import 'package:flutter_ui/entities/article_entity.dart';
import 'package:flutter_ui/models/article_model.dart';
import 'package:flutter_ui/pages/common/web_view_page.dart';
import 'package:provider/provider.dart';

import 'edit_article_page.dart';

// 分类页面
class NavPage extends StatefulWidget {
  final String title;

  NavPage({Key? key, required this.title}) : super(key: key);

  @override
  _NavPageState createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> {
  static const String _tag = 'NavPage';
  StateController _controller = StateController();

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
    Log.i('build', tag: _tag);

    AppTheme? theme = context.watch<LocalModel>().appTheme;
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
            SizedBox(height: 8),
            TopView(text: '这是Top数据'),
            SizedBox(height: 8),
            MaterialButton(
              child: Text('进入下一个页面'),
              textColor: theme.background,
              color: theme.primary,
              onPressed: () {
                RouteManager.push(context, EditArticlePage());
              },
            ),
            SizedBox(height: 8),
            ArticleList(controller: _controller),
          ],
        ),
      ),
    );
  }
}

class TopView extends StatefulWidget {
  final String text;

  TopView({Key? key, required this.text}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TopViewState();
}

class _TopViewState extends State<TopView> {
  static const String _tag = 'TopView';

  @override
  Widget build(BuildContext context) {
    Log.i('build', tag: _tag);

    return Text(widget.text);
  }
}

class ArticleList extends StatefulWidget {
  final StateController controller;

  ArticleList({Key? key, required this.controller}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ArticleListState();
}

class _ArticleListState extends State<ArticleList> {
  static const String _tag = 'ArticleList';

  @override
  Widget build(BuildContext context) {
    Log.i('build', tag: _tag);

    List<ArticleEntity> articleList = context.watch<ArticleModel>().allArticles;
    Log.i('文章数量：${articleList.length}', tag: _tag);
    return Expanded(
      child: RefreshListView(
        controller: widget.controller,
        itemCount: articleList.length,
        builder: (BuildContext context, int index) {
          return ArticleItem(index);
        },
        refresh: (state) async {},
      ),
    );
  }
}

class ArticleItem extends StatelessWidget {
  static const String _tag = 'ArticleItem';
  final int index;

  ArticleItem(this.index);

  @override
  Widget build(BuildContext context) {
    Log.i('build', tag: _tag);

    ArticleEntity? article = context.watch<ArticleModel>().getArticle(index);
    String title = article?.title ?? '';
    return TapLayout(
      onTap: () => RouteManager.push(context, WebViewPage(title: title, url: article?.link ?? '')),
      child: ListTile(
        title: Text(title),
      ),
    );
  }
}
