import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../base/res/local_model.dart';
import '../../../base/res/theme/app_theme.dart';
import '../../../entities/article_entity.dart';
import '../../../models/article_model.dart';

///
/// Created by a0010 on 2023/2/10 11:59
///
class EditArticlePage extends StatefulWidget {
  const EditArticlePage({super.key});

  @override
  State<StatefulWidget> createState() => _EditArticlePageState();
}

class _EditArticlePageState extends State<EditArticlePage> {
  @override
  Widget build(BuildContext context) {
    AppTheme? theme = context.watch<LocalModel>().appTheme;
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
        ),
        title: Text('编辑文章信息', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MaterialButton(
              child: Text('修改数据'),
              textColor: theme.background,
              color: theme.toolbarBackground,
              onPressed: () {
                ArticleEntity? article = context.read<ArticleModel>().getArticle(1);
                if (article != null) {
                  article.title = '这是测试标题';
                  context.read<ArticleModel>().updateArticle(article);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
