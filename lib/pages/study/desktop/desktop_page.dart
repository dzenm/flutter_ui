import 'package:flutter/material.dart';
import 'package:flutter_ui/http/connection/connection.dart';
import 'package:provider/provider.dart';

import '../../../base/base.dart';
import '../../../http/connection/state.dart';
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
  late Connection connection;
  late ConnectionStateMachine machine;

  @override
  void initState() {
    super.initState();
    connection = Connection();
    machine = ConnectionStateMachine(connection);
    machine.start();
  }

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch<LocalModel>().theme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('桌面端', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(children: [
            _buildChildren(),
            MaterialButton(
              textColor: Colors.white,
              color: theme.button,
              onPressed: () => connection.isClosed = true,
              child: _text('关闭'),
            ),
            MaterialButton(
              textColor: Colors.white,
              color: theme.button,
              onPressed: () => connection.isAlive = true,
              child: _text('活跃'),
            ),

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
