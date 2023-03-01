import 'package:flutter/material.dart';
import 'package:flutter_ui/base/entities/page_entity.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';
import 'package:flutter_ui/entities/article_entity.dart';
import 'package:flutter_ui/entities/coin_entity.dart';
import 'package:flutter_ui/http/http_manager.dart';
import 'package:flutter_ui/models/user_model.dart';
import 'package:flutter_ui/pages/main/me_page/list_page_state.dart';
import 'package:provider/provider.dart';

///
/// Created by a0010 on 2023/2/23 13:35
/// 我分享的文章页面
class ArticlePage extends StatefulWidget {
  ArticlePage({Key? key}) : super(key: key);

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
    updatePageIndex(index: reset ? 1 : -1);
    await HttpManager.instance.getPrivateArticleList(
      page: pageIndex,
      isShowDialog: false,
      success: (data) {
        CoinEntity coin = CoinEntity.fromJson(data['coinInfo']);
        PageEntity page = PageEntity.fromJson(data['shareArticles']);
        List<dynamic> datas = (page.datas ?? []);
        List<ArticleEntity> list = datas.map((e) => ArticleEntity.fromJson(e)).toList();

        context.read<UserModel>().updateCoin(coin);
        controller.loadComplete(); // 加载成功
        if (pageIndex >= (page.pageCount ?? 0)) {
          controller.loadEmpty(); // 加载完所有页面
        } else {
          // 加载数据成功，保存数据，下次加载下一页
          updateData(list);
          updatePageIndex(add: true);
          controller.loadMore();
        }
        setState(() {});
      },
      failed: (error) => setState(() => controller.loadFailed()),
    );
  }
}
