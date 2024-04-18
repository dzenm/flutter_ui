import 'package:flutter/material.dart';

import '../../../../base/base.dart';
import '../../../../entities/coin_entity.dart';
import '../../../../generated/l10n.dart';
import '../../../../http/http_manager.dart';
import '../../../common/widgets/list_page_state.dart';

///
/// Created by a0010 on 2023/2/23 13:35
/// 积分排行榜页面
class RankPage extends StatefulWidget {
  const RankPage({super.key});

  @override
  State<StatefulWidget> createState() => _RankPageState();
}

class _RankPageState extends ListPageState<CoinEntity, RankPage> {
  @override
  String getTitle() => S.of(context).integralRankingList;

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
  Future<void> getData(int pageIndex) async {
    await HttpManager().getRankCoins(
      page: pageIndex,
      isShowDialog: false,
      success: (list, pageCount) => updateState(list, pageCount),
      failed: (error) async => updateFailedState(),
    );
  }
}
