import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../base/base.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/user_model.dart';
import '../me_router.dart';

///
/// Created by a0010 on 2023/3/23 09:01
/// 查看我的信息页面
class ViewInfoPage extends StatefulWidget {
  const ViewInfoPage({super.key});

  @override
  State<StatefulWidget> createState() => _ViewInfoPageState();
}

class _ViewInfoPageState extends State<ViewInfoPage> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () => _getData());
  }

  Future<void> _getData() async {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.read<LocalModel>().theme;
    return Scaffold(
      body: Container(
        color: theme.background,
        child: Column(children: [
          CommonBar(
            title: S.of(context).profile,
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_sharp),
                onPressed: () => AppRouteDelegate.of(context).push(MeRouter.editInfo),
              ),
            ],
          ),
          Selector<UserModel, String>(
            builder: (context, value, widget) => TapLayout(
              onTap: () => {},
              height: 50,
              background: theme.white,
              padding: const EdgeInsets.all(16),
              child: SingleTextView(title: value),
            ),
            selector: (context, model) => model.user.username ?? '',
          )
        ]),
      ),
    );
  }
}
