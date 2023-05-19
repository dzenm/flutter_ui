import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../base/http/page_entity.dart';
import '../../../../base/widgets/tap_layout.dart';
import '../../../../entities/article_entity.dart';
import '../../../../entities/coin_entity.dart';
import '../../../../http/http_manager.dart';
import '../../../../models/user_model.dart';
import '../list_page_state.dart';

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
  String getTitle() => '我分享的文章';

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
  Future<void> getData({bool reset = false}) async {
    super.getData(reset: reset);
    await HttpManager.instance.getPrivateArticleList(
      page: pageIndex,
      isShowDialog: false,
      success: (data) {
        CoinEntity coin = CoinEntity.fromJson(data['coinInfo']);
        PageEntity page = PageEntity.fromJson(data['shareArticles']);
        List<dynamic> datas = (page.datas ?? []);
        List<ArticleEntity> list = datas.map((e) => ArticleEntity.fromJson(e)).toList();

        context.read<UserModel>().coin = coin;
        controller.loadComplete(); // 加载成功
        if (pageIndex >= (page.pageCount ?? 0)) {
          controller.loadEmpty(); // 加载完所有页面
        } else {
          // 加载数据成功，保存数据，下次加载下一页
          data = list;
          updatePage();
          controller.loadMore();
        }
        if (mounted) setState(() {});
      },
      failed: (error) => setState(() => controller.loadFailed()),
    );
  }
}
