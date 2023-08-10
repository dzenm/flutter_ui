import 'package:flutter/material.dart';
import 'package:flutter_ui/config/consts.dart';
import 'package:provider/provider.dart';

import '../../../base/res/app_theme.dart';
import '../../../base/res/local_model.dart';
import '../../../base/route/app_route_delegate.dart';
import '../../../base/widgets/tap_layout.dart';
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
    return Selector<NavModel, List<ToolEntity>>(
      builder: (c, tools, w) {
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: tools.map((tool) {
            String name = tool.name ?? '';
            String icon = '${Consts.toolsImageUrlPrefix}${tool.icon}';
            return TapLayout(
              onTap: () {
                String params = '?title=${tool.name}&url=${tool.link}';
                AppRouteDelegate.of(context).push(Routers.webView + params);
              },
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              background: theme.black150,
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
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Image.network(icon, width: 20, height: 20),
                const SizedBox(width: 4),
                Text(name),
              ]),
            );
          }).toList(),
        );
      },
      selector: (_, model) => model.tools,
    );
  }

  Future<void> _getData() async {
    await HttpManager.instance.getTools();
  }
}
