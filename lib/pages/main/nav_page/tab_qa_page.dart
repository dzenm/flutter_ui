import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../base/widgets/state_view.dart';
import '../../../http/http_manager.dart';
import '../../../models/article_model.dart';
import '../home_page/home_page.dart';

///
/// Created by a0010 on 2023/7/21 13:14
///
class TabQAPage extends StatefulWidget {
  const TabQAPage({super.key});

  @override
  State<StatefulWidget> createState() => _TabQAPageState();
}

class _TabQAPageState extends State<TabQAPage> {
  final StateController _controller = StateController();
  int _page = 0; // 加载的页数

  @override
  void initState() {
    super.initState();

    _getQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return ArticleListView(controller: _controller, refresh: _onRefresh);
  }

  Future<void> _onRefresh(bool refresh) async => await _getQuestions(isReset: refresh);

  Future<void> _getQuestions({bool isReset = false}) async {
    _page = isReset ? 0 : _page;
    await HttpManager.instance.getQuestionsList(
      page: _page,
      isShowDialog: false,
      success: (list, pageCount) {
        _controller.loadComplete(); // 加载成功
        if (_page >= (pageCount ?? 0)) {
          _controller.loadEmpty(); // 加载完所有页面
        } else {
          // 加载数据成功，保存数据，下次加载下一页
          context.read<ArticleModel>().updateArticles(list);
          ++_page;
          _controller.loadMore();
        }
        setState(() {});
      },
    );
  }
}
