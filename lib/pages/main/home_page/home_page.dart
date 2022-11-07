import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/base/widgets/banner_view.dart';
import 'package:flutter_ui/base/widgets/common_dialog.dart';
import 'package:flutter_ui/http/http_manager.dart';
import 'package:flutter_ui/models/article_model.dart';
import 'package:flutter_ui/models/banner_model.dart';
import 'package:provider/provider.dart';

// 主页面
class HomePage extends StatefulWidget {
  final String title;

  HomePage({required this.title});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  static const String _TAG = 'HomePage';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Log.d('initState', tag: _TAG);

    _getData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Log.d('didChangeDependencies', tag: _TAG);
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    Log.d('didUpdateWidget', tag: _TAG);
  }

  @override
  void deactivate() {
    super.deactivate();
    Log.d('deactivate', tag: _TAG);
  }

  @override
  void dispose() {
    super.dispose();
    Log.d('dispose', tag: _TAG);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Log.d('build', tag: _TAG);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [Banner()],
          ),
        ),
      ),
    );
  }

  void _getData() async {
    await _getBanner();
    await _getArticle(1);
    await _getTopArticle();
  }

  Future<void> _getBanner() async {
    HttpManager.getInstance.banner(success: (list) {
      context.read<BannerModel>().updateBanner(list);
    });
  }

  Future<void> _getArticle(int number) async {
    HttpManager.getInstance.getArticleList(
      page: 0,
      success: (list, total) {
        context.read<ArticleModel>().updateArticles(list);
      },
    );
  }

  Future<void> _getTopArticle() async {
    HttpManager.getInstance.getLopArticleList(
      success: (list) {
        context.read<ArticleModel>().updateArticles(list);
      },
    );
  }
}

class Banner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Log.d('build', tag: 'Banner');

    List<String> titles = context.watch<BannerModel>().titles;
    List<String> images = context.watch<BannerModel>().images;
    return BannerView(
      titles: titles,
      children: images.map((value) => Image.network(value, fit: BoxFit.cover)).toList(),
      onTap: (index) {
        showToast(index.toString());
      },
    );
  }
}
