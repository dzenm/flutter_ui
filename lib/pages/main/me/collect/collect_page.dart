import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';

import '../../../../entities/collect.dart';
import '../../../../generated/l10n.dart';
import '../../../../http/http_manager.dart';
import '../../../common/widgets/list_page_state.dart';

///
/// Created by a0010 on 2023/2/23 13:35
/// 我的收藏页面
class CollectPage extends StatefulWidget {
  const CollectPage({super.key});

  @override
  State<StatefulWidget> createState() => _CollectPageState();
}

class _CollectPageState extends ListPageState<CollectEntity, CollectPage> {
  @override
  int get initialPageIndex => 0;

  @override
  String getTitle() => S.of(context).collect;

  @override
  Widget buildItem(CollectEntity data, int index) {
    String title = data.title ?? '';
    return TapLayout(
      child: ListTile(
        title: Text(title),
      ),
    );
  }

  @override
  Future<void> getData(int pageIndex) async {
    await HttpManager().getCollectArticles(
      page: pageIndex,
      isShowDialog: false,
      success: (list, pageCount) => updateState(list, pageCount),
      failed: (error) async => updateFailedState(),
    );
  }
}
