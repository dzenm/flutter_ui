import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../base/base.dart';
import '../../../../entities/article_entity.dart';
import '../../../../entities/coin_entity.dart';
import '../../../../generated/l10n.dart';
import '../../../../http/http_manager.dart';
import '../../../../models/user_model.dart';
import '../../../common/widgets/list_page_state.dart';

///
/// Created by a0010 on 2023/2/23 13:35
/// 我分享的文章页面
class ArticlePage extends StatefulWidget {
  const ArticlePage({super.key});

  @override
  State<StatefulWidget> createState() => _ArticlePageState();
}

class _ArticlePageState extends ListPageState<ArticleEntity, ArticlePage> {
  @override
  String getTitle() => S.of(context).sharedArticle;

  @override
  Widget buildItem(ArticleEntity data, int index) {
    String title = data.title ?? '';
    return TapLayout(
      child: ListTile(
        title: Text(title),
      ),
    );
  }

  @override
  Future<void> getData(int pageIndex) async {
    await HttpManager().getPrivateArticles(
      page: pageIndex,
      isShowDialog: false,
      success: (data) async {
        CoinEntity coin = CoinEntity.fromJson(data['coinInfo']);
        PageEntity page = PageEntity.fromJson(data['shareArticles']);
        List<dynamic> datas = (page.datas ?? []);
        List<ArticleEntity> list = datas.map((e) => ArticleEntity.fromJson(e)).toList();

        context.read<UserModel>().coin = coin;
        updateState(list, page.pageCount);
      },
      failed: (error) async => updateFailedState(),
    );
  }
}
