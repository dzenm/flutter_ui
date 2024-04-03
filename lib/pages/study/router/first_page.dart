import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../base/base.dart';
import 'router_page.dart';

///
/// Created by a0010 on 2023/2/3 16:59
///
class FirstPage extends StatelessWidget {
  final int type;
  final int index;

  const FirstPage({super.key,
    required this.type,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    List<String> list = RouterPage.list[type];
    bool last = index == list.length - 1;
    return Scaffold(
      appBar: AppBar(
        title: Text(list[0], style: const TextStyle(color: Colors.white)),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildNavigator(context, last),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigator(BuildContext context, bool last) {
    AppTheme appTheme = context.watch<LocalModel>().theme;
    String text = last ? '返回' : '下一个页面';
    return MaterialButton(
      textColor: Colors.white,
      color: appTheme.appbar,
      onPressed: () => navigator(context, last),
      child: _text(text),
    );
  }

  void navigator(BuildContext context, bool last) {
    if (!last) {
      // 直接进入下一个页面，例：A->B, 现在在A页面调用push进入B页面
      Navigator.push(
        context,
        AppRouterOldDelegate.of(context).createMaterialRoute(FirstPage(type: type, index: index + 1)),
      );
      return;
    }
    if (type == 0) {
      // 返回上一个页面，例：A->B->C->D, 现在在D页面调用pop回到C页面
      Navigator.pop(context);
    } else if (type == 1) {
      // 返回指定页面，例：A->B->C->D, 现在在D页面调用popUntil, 设置router.settings.name == 'A'，回到A页面
      Navigator.popUntil(context, (router) => router.settings.name == 'RouterPage');
    } else if (type == 2) {
      //
      Navigator.pushReplacement(
        context,
        AppRouterOldDelegate.of(context).createMaterialRoute(FirstPage(type: type, index: index)),
      );
    } else if (type == 3) {
      Navigator.pushAndRemoveUntil(
        context,
        AppRouterOldDelegate.of(context).createMaterialRoute(FirstPage(type: type, index: index)),
        (router) => router.settings.name == 'RouterPage',
      );
    }
  }

  Widget _text(String text) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(text)]);
  }
}
