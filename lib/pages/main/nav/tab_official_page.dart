import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../base/a_router/misc/extensions.dart';
import '../../../base/base.dart';
import '../../../entities/chapter_entity.dart';
import '../../../http/http_manager.dart';
import '../../routers.dart';
import 'nav_model.dart';

///
/// Created by a0010 on 2023/7/21 13:15
///
class TabOfficialPage extends StatefulWidget {
  const TabOfficialPage({super.key});

  @override
  State<StatefulWidget> createState() => _TabOfficialPageState();
}

class _TabOfficialPageState extends State<TabOfficialPage> {
  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: RefreshIndicator(
        onRefresh: () => _getData(),
        child: SingleChildScrollView(
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    AppTheme theme = context.watch<LocalModel>().theme;
    return Selector<NavModel, List<ChapterEntity>>(
      builder: (c, tools, w) {
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: tools.map((tool) {
            String name = tool.name ?? '';
            return TapLayout(
              onTap: () {
                context.pushNamed(
                  Routers.webView,
                  queryParameters: {
                    'title': tool.name ?? '',
                    'url': tool.lisenseLink ?? '',
                  },
                );
              },
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              background: theme.primaryLight,
              alignment: null,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              child: Text(name),
            );
          }).toList(),
        );
      },
      selector: (_, model) => model.blogChapters,
    );
  }

  Future<void> _getData() async {
    await HttpManager().getBlogChapters();
  }
}
