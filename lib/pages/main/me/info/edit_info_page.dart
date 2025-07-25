import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../entities/user.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/user.dart';

///
/// Created by a0010 on 2023/3/23 09:01
/// 编辑我的信息页面
class EditInfoPage extends StatefulWidget {
  const EditInfoPage({super.key});

  @override
  State<StatefulWidget> createState() => _EditInfoPageState();
}

class _EditInfoPageState extends State<EditInfoPage> {
  TextEditingController? _controller;
  UserEntity? _user;
  bool _disableButton = true;

  @override
  void initState() {
    super.initState();

    _getData();
  }

  Future<void> _getData() async {
    _user = context.read<UserModel>().user;
    String? oldText = _user?.username ?? '';
    _controller = TextEditingController(text: oldText);
    _controller?.addListener(() {
      setState(() => _disableButton = oldText == _controller?.text);
    });
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.read<LocalModel>().theme;
    return PopWrapper.custom(
      onPopInvoked: (didPop) async {
        var result = await PopWrapper.showPrompt(context);
        if (context.mounted && result) {
          // 为true点击确定，false点击取消
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        body: Container(
          color: theme.background,
          child: Column(children: [
            CommonBar(
              title: S.of(context).editProfile,
              centerTitle: true,
              actions: [
                if (!_disableButton)
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () => _disableButton ? null : _submit(),
                  ),
              ],
            ),
            SingleEditView(title: S.of(context).username, controller: _controller, maxLength: 16),
          ]),
        ),
      ),
    );
  }

  void _submit() {
    _user?.username = _controller?.text;
    context.read<UserModel>().user = _user!;
    Navigator.pop(context);
  }
}
