import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../base/base.dart';
import '../../../config/configs.dart';
import '../../../entities/tool_entity.dart';
import '../../../http/http_manager.dart';
import '../../routers.dart';
import 'nav_model.dart';

///
/// Created by a0010 on 2023/7/21 13:16
///
class TabToolPage extends StatefulWidget {
  const TabToolPage({super.key});

  @override
  State<StatefulWidget> createState() => _TabToolPageState();
}

class _TabToolPageState extends State<TabToolPage> {
  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<NavModel, int>(
      selector: (_, model) => model.tools.length,
      builder: (c, len, w) {
        return RefreshIndicator(
          onRefresh: () => _getData(),
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
    return Selector<NavModel, ToolEntity>(
      selector: (_, model) => model.tools[index],
      builder: (c, tool, w) {
        String name = tool.name ?? '';
        String icon = '${Configs.toolsImageUrlPrefix}${tool.icon}';
        String desc = tool.desc ?? '';
        return TapLayout(
          onTap: () {
            String params = '?title=${tool.name}&url=${tool.link}';
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
              Row(children: [
                ImageView(url: icon, width: 20, height: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(name, style: TextStyle(color: theme.primaryText))),
              ]),
              const SizedBox(height: 8),
              Text(desc, maxLines: 2, style: TextStyle(color: theme.secondaryText, fontSize: 12))
            ],
          ),
        );
      },
    );
  }

  Future<void> _getData() async {
    await HttpManager.instance.getTools();
  }
}
