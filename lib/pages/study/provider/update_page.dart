import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../base/base.dart';
import '../study_model.dart';

///
/// Created by a0010 on 2023/8/31 17:00
///

class UpdatePage extends StatefulWidget {
  final int? id;

  const UpdatePage({super.key, required this.id});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = context.read<StudyModel>().getUser(widget.id);
    Log.d('获取user=${_user?.toJson()}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('修改数据', style: TextStyle(color: Colors.white)),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SingleEditView(
                  title: '用户名',
                  initialText: '${_user?.username}',
                  onChanged: (value) {
                    _user?.username = value;
                  },
                ),
                SingleEditView(
                  title: '年龄',
                  initialText: '${_user?.age}',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _user?.age = StrUtil.parseInt(value);
                  },
                ),
                TapLayout(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  onTap: () => PickerView.showList(
                    context,
                    list: ['男', '女'],
                    initialItem: _user?.sex == 1 ? '男' : '女',
                    onChanged: (value) {
                      _user?.sex = value == '男' ? 1 : 0;
                    },
                  ),
                  child: SingleTextView(
                    title: '性别',
                    fontSize: 16,
                    text: _user?.sex == 1 ? '男' : '女',
                  ),
                ),
                SingleEditView(
                  title: '地址',
                  initialText: '${_user?.address}',
                  onChanged: (value) {
                    _user?.address = value;
                  },
                ),
                SingleEditView(
                  title: '手机号',
                  initialText: '${_user?.phone}',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _user?.phone = value;
                  },
                ),
                MaterialButton(
                  textColor: Colors.white,
                  color: Colors.blue,
                  onPressed: () {
                    context.read<StudyModel>().updateUser(User.fromJson(_user!.toJson()));
                    AppRouter.of(context).pop(context);
                  },
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('保存'),
                  ]),
                ),
              ]),
            )
          ]),
        ),
      ),
    );
  }
}
