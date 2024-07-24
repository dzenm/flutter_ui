import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../entities/article_entity.dart';
import '../../../http/http_manager.dart';
import '../../routers.dart';
import 'nav_model.dart';
import 'tab_list_page_state.dart';

///
/// Created by a0010 on 2023/7/21 13:12
///
class TabProjectPage extends StatefulWidget {
  const TabProjectPage({super.key});

  @override
  State<StatefulWidget> createState() => _TabProjectPageState();
}

class _TabProjectPageState extends TabListPageState<TabProjectPage> {
  @override
  Widget build(BuildContext context) {
    return Selector<NavModel, int>(
      builder: (context, len, child) {
        return buildContent(len);
      },
      selector: (context, model) => model.projectArticles.length,
    );
  }

  @override
  Widget buildItem(int index) {
    AppTheme theme = context.watch<LocalModel>().theme;
    return Selector<NavModel, ArticleEntity>(
      selector: (_, model) => model.projectArticles[index],
      builder: (c, project, w) {
        String name = project.title ?? '';
        String desc = project.desc ?? '';
        return TapLayout(
          onTap: () {
            context.pushNamed(
              Routers.webView,
              queryParameters: {
                'title': project.title,
                'url': project.link ?? '',
              },
            );
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

  @override
  Future<void> getData(int page) async {
    await HttpManager().getProjects(
      page: page,
      success: (pageCount) => updateState(pageCount),
      failed: (error) async => updateFailedState(),
    );
  }
}
