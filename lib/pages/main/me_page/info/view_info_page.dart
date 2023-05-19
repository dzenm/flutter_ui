import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../base/res/app_theme.dart';
import '../../../../base/res/local_model.dart';
import '../../../../base/widgets/common_bar.dart';
import '../../../../base/widgets/single_text_layout.dart';
import '../../../../base/widgets/tap_layout.dart';
import '../../../../models/user_model.dart';
import '../../../routers.dart';

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
    AppTheme theme = context.read<LocalModel>().appTheme;
    return Scaffold(
      body: Container(
        color: theme.white150,
        child: Column(children: [
          CommonBar(title: '我的信息', centerTitle: true, actions: [
            IconButton(
              icon: Icon(Icons.edit_sharp),
              onPressed: () => Navigator.pushNamed(context, Routers.editInfo),
            ),
          ]),
          Selector<UserModel, String>(
            builder: (context, value, widget) => TapLayout(
              onTap: () => {},
              height: 50,
              background: theme.white,
              padding: EdgeInsets.all(16),
              child: SingleTextLayout(title: '$value'),
            ),
            selector: (context, model) => model.user.username ?? '',
          )
        ]),
      ),
    );
  }
}
