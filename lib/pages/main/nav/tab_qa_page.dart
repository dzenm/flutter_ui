import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../base/res/app_theme.dart';
import '../../../base/res/local_model.dart';
import '../../../base/route/app_route_delegate.dart';
import '../../../base/widgets/state_view.dart';
import '../../../base/widgets/tap_layout.dart';
import '../../../entities/article_entity.dart';
import '../../../http/http_manager.dart';
import '../../routers.dart';
import 'nav_model.dart';

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
    return Selector<NavModel, int>(
      selector: (_, model) => model.qaArticles.length,
      builder: (c, len, w) {
        return RefreshIndicator(
          onRefresh: () => _getQuestions(),
          child: ListView.builder(
            controller: ScrollController(),
            itemCount: len,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) => _buildItem(index),
          ),
        );
      },
    );
  }

  Widget _buildItem(int index) {
    AppTheme theme = context.watch<LocalModel>().theme;
    return Selector<NavModel, ArticleEntity>(
      selector: (_, model) => model.qaArticles[index],
      builder: (c, project, w) {
        String name = project.title ?? '';
        String desc = project.desc ?? '';
        return TapLayout(
          onTap: () {
            String params = '?title=${project.title}&url=${project.link}';
            AppRouteDelegate.of(context).push(Routers.webView + params);
          },
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          background: theme.cardBackgroundDark,
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 1),
              blurRadius: 10.0,
              spreadRadius: 0.0,
              color: Color(0x0D000000),
            ),
            BoxShadow(
              offset: Offset(0, 4),
              blurRadius: 4.0,
              spreadRadius: 0.0,
              color: Color(0x14000000),
            ),
          ],
          alignment: null,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(color: theme.primaryText)),
              const SizedBox(height: 8),
              Text(desc, maxLines: 2, style: TextStyle(color: theme.secondaryText, fontSize: 12)),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getQuestions({bool isReset = false}) async {
    _page = isReset ? 0 : _page;
    await HttpManager.instance.getQuestions(
      page: _page,
      success: (list, pageCount) {
        _controller.loadComplete(); // 加载成功
        if (_page >= (pageCount ?? 0)) {
          _controller.loadEmpty(); // 加载完所有页面
        } else {
          // 加载数据成功，保存数据，下次加载下一页
          ++_page;
          _controller.loadMore();
        }
        setState(() {});
      },
    );
  }
}
