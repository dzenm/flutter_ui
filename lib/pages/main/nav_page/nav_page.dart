import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../base/log/log.dart';
import '../../../base/res/local_model.dart';
import '../../../base/res/app_theme.dart';
import '../../../base/route/route_manager.dart';
import '../../../base/widgets/common_bar.dart';
import '../../../http/http_manager.dart';
import '../../../models/article_model.dart';
import 'edit_article_page.dart';
import 'nav_model.dart';

///
/// Created by a0010 on 2022/7/28 10:56
/// 分类页面
class NavPage extends StatefulWidget {
  const NavPage({super.key});

  @override
  State<StatefulWidget> createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> {
  static const String _tag = 'NavPage';
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    Log.i('initState', tag: _tag);
    _tabController = DefaultTabController.of(context);
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

    List<String> tabs = context.read<NavModel>().tabs;
    AppTheme? theme = context.watch<LocalModel>().appTheme;
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: CommonBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
          ),
          toolbarHeight: 48,
          bottom: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: tabs.map((tab) => Tab(text: tab)).toList(),
          ),
        ),
        body: TabBarView(
          children: tabs.map((item) {
            return Container(
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
                    color: theme.appbarColor,
                    onPressed: () {
                      RouteManager.push(context, EditArticlePage());
                    },
                  ),
                  SizedBox(height: 8),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _getTopArticle() async {
    await HttpManager.instance.getLopArticleList(
      isShowDialog: false,
      success: (list) {
        context.read<ArticleModel>().updateArticles(list);
      },
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
