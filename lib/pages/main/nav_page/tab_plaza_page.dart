import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../base/res/app_theme.dart';
import '../../../base/res/local_model.dart';
import '../../../http/http_manager.dart';
import '../../../models/article_model.dart';

///
/// Created by a0010 on 2023/7/21 13:13
///
class TabPlazaPage extends StatefulWidget {
  const TabPlazaPage({super.key});

  @override
  State<StatefulWidget> createState() => _TabPlazaPageState();
}

class _TabPlazaPageState extends State<TabPlazaPage> {
  @override
  void initState() {
    super.initState();
    _getTopArticle();
  }

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch<LocalModel>().theme;
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
    await HttpManager.instance.getTopArticleList(
      isShowDialog: false,
      success: (list) {
        context.read<ArticleModel>().updateArticles(list);
      },
    );
  }
}
