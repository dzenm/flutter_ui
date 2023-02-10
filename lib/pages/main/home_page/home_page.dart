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

class _HomePageState extends State<HomePage> {
  static const String _tag = 'HomePage';

  @override
  void initState() {
    super.initState();
    Log.i('initState', tag: _tag);

    _getData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Log.i('didChangeDependencies', tag: _tag);
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
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
    Log.d('开始加载网络数据...', tag: _tag);
    await Future.wait([
      _getBanner(),
      _getArticle(1),
      _getTopArticle(),
    ]).then((value) {
      Log.d('网络数据执行完成...', tag: _tag);
    });
    Log.d('结束加载网络数据...', tag: _tag);
  }

  Future<void> _getBanner() async {
    await HttpManager.getInstance.banner(success: (list) {
      context.read<BannerModel>().updateBanner(list);
    });
  }

  Future<void> _getArticle(int number) async {
    await HttpManager.getInstance.getArticleList(
      page: 0,
      success: (list, total) {
        context.read<ArticleModel>().updateArticles(list);
      },
    );
  }

  Future<void> _getTopArticle() async {
    await HttpManager.getInstance.getLopArticleList(
      success: (list) {
        context.read<ArticleModel>().updateArticles(list);
      },
    );
  }
}

class Banner extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BannerState();
}

class _BannerState extends State<Banner> {
  static const String _tag = 'Banner';

  @override
  Widget build(BuildContext context) {
    Log.i('build', tag: _tag);

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
