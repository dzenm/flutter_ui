import 'package:contextual_menu/contextual_menu.dart';
import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  // late Connection connection;
  late ConnectionStateMachine machine;

  @override
  void initState() {
    super.initState();
    // connection = Connection();
    // machine = ConnectionStateMachine(connection);
    // machine.start();
  }

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch<LocalModel>().theme;
    return Scaffold(
      appBar: const CommonBar(
        title: '桌面端',
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(children: [
            _buildChildren(),
            // MaterialButton(
            //   textColor: Colors.white,
            //   color: theme.button,
            //   // onPressed: () => connection.isClosed = false,
            //   child: _text('关闭'),
            // ),
            // const SizedBox(height: 8),
            // MaterialButton(
            //   textColor: Colors.white,
            //   color: theme.button,
            //   // onPressed: () => connection.isAlive = true,
            //   child: _text('活跃'),
            // ),
            const SizedBox(height: 8),
            MaterialButton(
              textColor: Colors.white,
              color: theme.button,
              onPressed: () => _showContextMenu(),
              child: _text('桌面端多级菜单'),
            ),
          ]),
        ),
      ),
    );
  }

  void _showContextMenu() {
    Menu menu = Menu(
      items: [
        MenuItem(
          label: 'Copy',
          onClick: (_) {
            CommonDialog.showToast('Clicked Copy');
          },
        ),
        MenuItem(
          label: 'Disabled item',
          disabled: true,
        ),
        MenuItem.checkbox(
          key: 'checkbox1',
          label: 'Checkbox1',
          checked: true,
          onClick: (menuItem) {
            CommonDialog.showToast('Clicked Checkbox1');
            menuItem.checked = !(menuItem.checked == true);
          },
        ),
        MenuItem.separator(),
      ],
    );
    popUpContextualMenu(
      menu,
      placement: Placement.bottomLeft,
    );
  }

  Widget _buildChildren() {
    AppTheme theme = context.watch<LocalModel>().theme;
    return MaterialButton(
      textColor: Colors.white,
      color: theme.button,
      onPressed: () => context.pushNamed(StudyRouter.screenCapture),
      child: _text('桌面端处理'),
    );
  }

  Widget _text(String text) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(text)]);
  }
}
