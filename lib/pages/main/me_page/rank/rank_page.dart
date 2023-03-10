import 'package:flutter/material.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';
import 'package:flutter_ui/entities/coin_entity.dart';
import 'package:flutter_ui/http/http_manager.dart';

import '../list_page_state.dart';

///
/// Created by a0010 on 2023/2/23 13:35
/// 积分排行榜页面
class RankPage extends StatefulWidget {
  RankPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RankPageState();
}

class _RankPageState extends ListPageState<CoinEntity, RankPage> {
  @override
  String getTitle() => '积分排行榜';

  @override
  Widget buildItem(CoinEntity data, int index) {
    String title = data.username ?? '';
    return TapLayout(
      child: ListTile(
        title: Text(title),
      ),
    );
  }

  @override
  Future<void> getData({bool reset = false}) async {
    super.getData(reset: reset);
    pageIndex = -1;
    await HttpManager.instance.getRankCoinList(
      page: pageIndex,
      isShowDialog: false,
      success: (list, pageCount) {
        controller.loadComplete(); // 加载成功
        if (pageIndex >= (pageCount ?? 0)) {
          controller.loadEmpty(); // 加载完所有页面
        } else {
          // 加载数据成功，保存数据，下次加载下一页
          data = list;
          pageIndex = 0;
          controller.loadMore();
        }
        if (mounted) setState(() {});
      },
      failed: (error) => setState(() => controller.loadFailed()),
    );
  }
}