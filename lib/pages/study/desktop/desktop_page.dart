import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../base/base.dart';
import '../study_router.dart';

///
/// Created by a0010 on 2024/4/7 14:16
///
class DesktopPage extends StatefulWidget {
  const DesktopPage({super.key});

  @override
  State<DesktopPage> createState() => _DesktopPageState();
}

class _DesktopPageState extends State<DesktopPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('桌面端', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(children: [
            _buildChildren(),
          ]),
        ),
      ),
    );
  }

  Widget _buildChildren() {
    AppTheme theme = context.watch<LocalModel>().theme;
    return MaterialButton(
      textColor: Colors.white,
      color: theme.button,
      onPressed: () => AppRouter.of(context).push(StudyRouter.screenCapture),
      child: _text('桌面端处理'),
    );
  }

  Widget _text(String text) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(text)]);
  }
}
