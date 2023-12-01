import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../base/base.dart';
import '../../../entities/chapter_entity.dart';
import '../../../http/http_manager.dart';
import '../../routers.dart';
import 'nav_model.dart';

///
/// Created by a0010 on 2023/7/21 13:14
///
class TabTutorialPage extends StatefulWidget {
  const TabTutorialPage({super.key});

  @override
  State<StatefulWidget> createState() => _TabTutorialPageState();
}

class _TabTutorialPageState extends State<TabTutorialPage> {
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
                String params = '?title=${tool.name}&url=${tool.lisenseLink}';
                AppRouteDelegate.of(context).push(Routers.webView + params);
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
      selector: (_, model) => model.chapters,
    );
  }

  Future<void> _getData() async {
    await HttpManager().getChapters();
  }
}
