import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../base/log/build_config.dart';
import '../../../base/log/log.dart';
import '../../../base/res/app_theme.dart';
import '../../../base/res/local_model.dart';
import '../../../base/widgets/common_bar.dart';
import '../../../generated/l10n.dart';
import '../../../http/http_manager.dart';
import '../../../models/article_model.dart';

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
  TabController? _controller;

  @override
  void initState() {
    super.initState();
    log('initState');
    _controller = DefaultTabController.of(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    log('didChangeDependencies');
  }

  @override
  void didUpdateWidget(covariant NavPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    log('didUpdateWidget');
  }

  @override
  void deactivate() {
    super.deactivate();
    log('deactivate');
  }

  @override
  void dispose() {
    super.dispose();
    log('dispose');
  }

  @override
  Widget build(BuildContext context) {
    log('build');

    List<String> tabs = [
      S.of(context).plaza,
      S.of(context).tutorial,
      S.of(context).qa,
      S.of(context).project,
      S.of(context).official,
      S.of(context).tool,
    ];
    AppTheme theme = context.watch<LocalModel>().theme;
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: CommonBar(
          backgroundColor: theme.white,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.dark,
          ),
          toolbarHeight: 48,
          bottom: TabBar(
            controller: _controller,
            isScrollable: true,
            indicatorSize: TabBarIndicatorSize.tab,
            unselectedLabelColor: theme.hint,
            labelColor: theme.primaryText,
            indicatorColor: theme.accent,
            tabs: tabs.map((text) {
              return Tab(text: text);
            }).toList(),
          ),
        ),
        body: TabBarView(
          children: tabs.map((item) {
            return _buildTabItem(theme);
          }).toList(),
        ),
      ),
    );
  }

  /// Tab Item
  Widget _buildTabItem(AppTheme theme) {
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
            color: theme.appbar,
            onPressed: () {},
          ),
          SizedBox(height: 8),
        ],
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

  void log(String msg) => BuildConfig.showPageLog ? Log.p(msg, tag: _tag) : null;
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
    Log.p('build', tag: _tag);

    return Text(widget.text);
  }
}
