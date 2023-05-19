import 'package:flutter/material.dart';

import '../../../../base/widgets/tap_layout.dart';
import '../../../../entities/coin_record_entity.dart';
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
  String getTitle() => '积分获取记录列表';

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
  Future<void> getData({bool reset = false}) async {
    super.getData(reset: reset);
    await HttpManager.instance.getCoinList(
      page: pageIndex,
      isShowDialog: false,
      success: (list, pageCount) {
        controller.loadComplete(); // 加载成功
        if (pageIndex >= (pageCount ?? 0)) {
          controller.loadEmpty(); // 加载完所有页面
        } else {
          // 加载数据成功，保存数据，下次加载下一页
          updatePage();
          data = list;
          controller.loadMore();
        }
        if (mounted) setState(() {});
      },
      failed: (error) => setState(() => controller.loadFailed()),
    );
  }
}
