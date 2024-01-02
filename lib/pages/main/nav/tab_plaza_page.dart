import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../base/base.dart';
import '../../../entities/article_entity.dart';
import '../../../http/http_manager.dart';
import '../../routers.dart';
import 'nav_model.dart';
import 'tab_list_page_state.dart';

///
/// Created by a0010 on 2023/7/21 13:13
///
class TabPlazaPage extends StatefulWidget {
  const TabPlazaPage({super.key});

  @override
  State<StatefulWidget> createState() => _TabPlazaPageState();
}

class _TabPlazaPageState extends TabListPageState<TabPlazaPage> {

  @override
  Widget build(BuildContext context) {
    return Selector<NavModel, int>(
      builder: (context, len, child) {
        return buildContent(len);
      },
      selector: (context, model) => model.plazaArticles.length,
    );
  }

  @override
  Widget buildItem(int index) {
    AppTheme theme = context.watch<LocalModel>().theme;
    return Selector<NavModel, ArticleEntity>(
      selector: (_, model) => model.plazaArticles[index],
      builder: (c, project, w) {
        String name = project.title ?? '';
        String desc = project.desc ?? '';
        return TapLayout(
          onTap: () {
            String params = '?title=${project.title}&url=${project.link}';
            AppRouter.of(context).push(Routers.webView + params);
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
    await HttpManager().getPlazas(
      page: page,
      success: (pageCount) => updateState(pageCount),
      failed: (e) => updateFailedState(),
    );
  }
}
