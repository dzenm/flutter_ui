import 'package:flutter/material.dart';

import '../../../../base/widgets/tap_layout.dart';
import '../../../../entities/collect_entity.dart';
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
  Future<void> getData({bool reset = false}) async {
    super.getData(reset: reset);
    await HttpManager.instance.getCollectArticleList(
      page: pageIndex,
      isShowDialog: false,
      success: (list, pageCount) {
        controller.loadComplete(); // 加载成功
        if (pageIndex >= (pageCount ?? 0)) {
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
