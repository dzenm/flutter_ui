import 'package:flutter/material.dart';

import '../../../../base/base.dart';
import '../../../../entities/coin_record_entity.dart';
import '../../../../generated/l10n.dart';
import '../../../../http/http_manager.dart';
import '../../../common/widgets/list_page_state.dart';

///
/// Created by a0010 on 2023/2/23 13:35
/// 我的积分页面
class CoinPage extends StatefulWidget {
  const CoinPage({super.key});

  @override
  State<StatefulWidget> createState() => _CoinPageState();
}

class _CoinPageState extends ListPageState<CoinRecordEntity, CoinPage> {
  @override
  String getTitle() => S.of(context).coinRecord;

  @override
  Widget buildItem(CoinRecordEntity data, int index) {
    String title = data.desc ?? '';
    return TapLayout(
      child: ListTile(
        title: Text(title),
      ),
    );
  }

  @override
  Future<void> getData(int pageIndex) async {
    await HttpManager.instance.getCoins(
      page: pageIndex,
      isShowDialog: false,
      success: (list, pageCount) => updateState(list, pageCount),
      failed: (error) => updateFailedState(),
    );
  }
}
